#!/usr/bin/env bash
set -euo pipefail

SRC_DIR="/analysis/libtiff-src"
OUTPUT_DIR="/output"

mkdir -p "${OUTPUT_DIR}"
mkdir -p /tmp/cppcheck-build

echo "=== Статический анализ libtiff ==="
echo "Инструмент: $(cppcheck --version)"
echo "Дата: $(date -u)"

cppcheck --enable=all --inconclusive --force --std=c99 --xml --xml-version=2 --cppcheck-build-dir=/tmp/cppcheck-build --suppress=missingIncludeSystem "${SRC_DIR}/libtiff" "${SRC_DIR}/tools" 2>"${OUTPUT_DIR}/cppcheck_report.xml"

cppcheck --enable=all --inconclusive --force --std=c99 --cppcheck-build-dir=/tmp/cppcheck-build --suppress=missingIncludeSystem "${SRC_DIR}/libtiff" "${SRC_DIR}/tools" 2>"${OUTPUT_DIR}/cppcheck_report.txt" || true

echo "[+] Готово. Результаты в: ${OUTPUT_DIR}/"
