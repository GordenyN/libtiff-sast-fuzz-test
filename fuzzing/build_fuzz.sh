#!/usr/bin/env bash
# Скрипт верификации сборки с AFL-инструментацией
# Выводит подтверждение наличия AFL-маркеров в бинаре

set -euo pipefail

INSTALL_DIR="/fuzz/install"
TARGET="${INSTALL_DIR}/bin/tiffinfo"

echo "=============================================="
echo " Верификация AFL-инструментации"
echo "=============================================="

if [[ ! -f "${TARGET}" ]]; then
    echo "[ERROR] Бинарь ${TARGET} не найден!"
    exit 1
fi

echo "[*] Бинарь: ${TARGET}"
echo "[*] Размер: $(du -sh "${TARGET}" | cut -f1)"

# Проверка 1: наличие AFL-символов
AFL_SYMBOLS=$(strings "${TARGET}" | grep -c "__afl_" 2>/dev/null || echo 0)
echo "[*] AFL-символов найдено: ${AFL_SYMBOLS}"

# Проверка 2: наличие ASan-символов (если собирали с -fsanitize=address)
ASAN_SYMBOLS=$(strings "${TARGET}" | grep -c "__asan_" 2>/dev/null || echo 0)
echo "[*] ASan-символов найдено: ${ASAN_SYMBOLS}"

# Проверка 3: file type
echo "[*] Тип файла: $(file "${TARGET}")"

if [[ "${AFL_SYMBOLS}" -gt 0 ]]; then
    echo ""
    echo "[+] ПОДТВЕРЖДЕНО: бинарь собран с AFL-инструментацией"
else
    echo ""
    echo "[!] ВНИМАНИЕ: AFL-символы не найдены в бинаре"
    exit 1
fi

echo ""
echo "[*] Инструментация подтверждена. Готово к фаззингу."
