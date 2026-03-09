#!/usr/bin/env bash
# Скрипт сборки всех Docker-образов
# Использование: bash scripts/build_all.sh [docker|podman]

set -euo pipefail

CONTAINER_TOOL="${1:-docker}"

echo "=============================================="
echo " Сборка образов libtiff SAST & Fuzzing"
echo " Инструмент: ${CONTAINER_TOOL}"
echo " Дата: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
echo "=============================================="

# Проверка наличия инструмента
if ! command -v "${CONTAINER_TOOL}" &>/dev/null; then
    echo "[ERROR] ${CONTAINER_TOOL} не найден. Установите Docker или Podman."
    exit 1
fi

echo ""
echo "[1/2] Сборка образа для статического анализа (libtiff-sast)..."
"${CONTAINER_TOOL}" build \
    --tag libtiff-sast:latest \
    --tag libtiff-sast:1.0.0 \
    ./sast/

echo ""
echo "[2/2] Сборка образа для фаззинга (libtiff-fuzz)..."
"${CONTAINER_TOOL}" build \
    --tag libtiff-fuzz:latest \
    --tag libtiff-fuzz:1.0.0 \
    ./fuzzing/

echo ""
echo "=============================================="
echo " Образы успешно собраны:"
"${CONTAINER_TOOL}" images | grep -E "^(libtiff-sast|libtiff-fuzz)"
echo "=============================================="
echo ""
echo "Следующие шаги:"
echo ""
echo "  Статический анализ:"
echo "    ${CONTAINER_TOOL} run --rm \\"
echo "      -v \"\$(pwd)/sast/results:/output\" \\"
echo "      libtiff-sast"
echo ""
echo "  Фаззинг:"
echo "    ${CONTAINER_TOOL} run --rm \\"
echo "      --privileged \\"
echo "      -e FUZZ_DURATION=300 \\"
echo "      -v \"\$(pwd)/fuzzing/results:/fuzz/output\" \\"
echo "      libtiff-fuzz"
