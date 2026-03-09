#!/usr/bin/env bash
# Скрипт запуска AFL++ фаззинга libtiff 4.4.0
# Таргет: tiffinfo — утилита отображения метаданных TIFF-файлов

set -euo pipefail

INSTALL_DIR="/fuzz/install"
TARGET="${INSTALL_DIR}/bin/tiffinfo"
SEEDS_DIR="/fuzz/seeds"
OUTPUT_DIR="/fuzz/output"
FUZZ_DURATION="${FUZZ_DURATION:-60}"   # Длительность в секундах (по умолчанию 60)

mkdir -p "${OUTPUT_DIR}"

echo "=============================================="
echo " AFL++ Fuzzing: libtiff 4.4.0 / tiffinfo"
echo " AFL версия: $(afl-fuzz --version 2>&1 | head -1)"
echo " Дата запуска: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
echo " Длительность: ${FUZZ_DURATION} секунд"
echo "=============================================="

# Верификация инструментации
echo ""
echo "[*] Проверка AFL-инструментации..."
/fuzz/build_fuzz.sh

echo ""
echo "[*] Содержимое корпуса seed-файлов:"
ls -la "${SEEDS_DIR}/"

# Настройка системы для AFL (требуется --privileged)
echo core > /proc/sys/kernel/core_pattern 2>/dev/null || \
    echo "[!] Не удалось установить core_pattern (запустите с --privileged)"

# Переменные окружения AFL
export AFL_SKIP_CPUFREQ=1
export AFL_NO_FORKSRV=1          # Пропустить проверку CPU frequency
export AFL_NO_UI=0                  # Включить UI
export AFL_AUTORESUME=0             # Возобновить если есть прошлые данные
export ASAN_OPTIONS="abort_on_error=1:detect_leaks=0:symbolize=0"

echo ""
echo "[*] Запуск afl-fuzz..."
echo "[*] Таргет: ${TARGET} -D @@"
echo ""

# Запуск фаззера с таймаутом
# -i: директория с seed-файлами
# -o: директория для результатов
# -t: таймаут на один тест-кейс (мс)
# -m none: без ограничения памяти (ASan требует много памяти)
# @@: placeholder для входного файла
timeout "${FUZZ_DURATION}" \
    afl-fuzz \
        -i "${SEEDS_DIR}" \
        -o "${OUTPUT_DIR}/afl_out" \
        -t 5000 \
        -m none \
        -- "${TARGET}" -i -D "@@" \
    2>&1 | tee "${OUTPUT_DIR}/afl_run.log" || true

echo ""
echo "=============================================="
echo " Результаты фаззинга"
echo "=============================================="

# Сбор статистики из fuzzer_stats
STATS_FILE="${OUTPUT_DIR}/afl_out/default/fuzzer_stats"
if [[ -f "${STATS_FILE}" ]]; then
    echo "[+] Статистика AFL:"
    grep -E "^(start_time|last_update|run_time|cycles_done|execs_done|execs_per_sec|paths_total|paths_found|unique_crashes|unique_hangs|corpus_count)" \
         "${STATS_FILE}" | while IFS=': ' read -r key val; do
        printf "    %-25s: %s\n" "${key}" "${val}"
    done
    cp "${STATS_FILE}" "${OUTPUT_DIR}/fuzzer_stats.txt"
else
    echo "[!] fuzzer_stats не найден — фаззер не успел сохранить статистику"
fi

# Проверка крэшей
CRASH_DIR="${OUTPUT_DIR}/afl_out/default/crashes"
if [[ -d "${CRASH_DIR}" ]]; then
    CRASH_COUNT=$(find "${CRASH_DIR}" -name "id:*" | wc -l)
    echo ""
    echo "[*] Найдено уникальных крэшей: ${CRASH_COUNT}"
    if [[ "${CRASH_COUNT}" -gt 0 ]]; then
        echo "[!] Крэши сохранены в: ${CRASH_DIR}"
        ls -la "${CRASH_DIR}/"
    fi
else
    echo "[*] Директория крэшей не создана (крэшей не обнаружено)"
fi

# Проверка зависаний
HANG_DIR="${OUTPUT_DIR}/afl_out/default/hangs"
if [[ -d "${HANG_DIR}" ]]; then
    HANG_COUNT=$(find "${HANG_DIR}" -name "id:*" | wc -l)
    echo "[*] Найдено уникальных зависаний: ${HANG_COUNT}"
fi

# Сохранить итоговое резюме
{
    echo "# AFL++ Fuzzing Summary"
    echo ""
    echo "**Дата:** $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
    echo "**Таргет:** ${TARGET}"
    echo "**Аргументы:** -D \"\$INPUT\""
    echo "**Длительность:** ${FUZZ_DURATION} секунд"
    echo "**Корпус seed-файлов:** $(ls "${SEEDS_DIR}" | wc -l) файл(ов)"
    echo ""
    if [[ -f "${STATS_FILE}" ]]; then
        echo "## Статистика"
        echo "\`\`\`"
        cat "${STATS_FILE}"
        echo "\`\`\`"
    fi
    echo ""
    echo "## Результат"
    CRASH_COUNT=$(find "${CRASH_DIR:-/dev/null}" -name "id:*" 2>/dev/null | wc -l || echo 0)
    if [[ "${CRASH_COUNT}" -gt 0 ]]; then
        echo "⚠️ **Обнаружено крэшей: ${CRASH_COUNT}**"
    else
        echo "✅ Крэшей не обнаружено за время работы фаззера."
    fi
} > "${OUTPUT_DIR}/fuzz_summary.md"

echo ""
echo "[+] Резюме сохранено: ${OUTPUT_DIR}/fuzz_summary.md"
echo "[+] Все результаты в: ${OUTPUT_DIR}/"
