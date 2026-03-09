# libtiff 4.4.0 — SAST & Fuzzing

Тестовое задание: статический анализ (Cppcheck) и фаззинг (AFL++) проекта libtiff 4.4.0.

## Структура репозитория

```
.
├── README.md
├── sast/
│   ├── Dockerfile              # Образ ALT Linux p11 + Cppcheck
│   ├── run_analysis.sh         # Скрипт запуска анализа
│   └── results/
│       ├── cppcheck_report.xml # Результаты анализа (XML)
│       └── cppcheck_report.txt # Результаты анализа (текст)
├── fuzzing/
│   ├── Dockerfile              # Образ ALT Linux p11 + AFL++
│   ├── build_fuzz.sh           # Верификация AFL-инструментации
│   ├── run_fuzzer.sh           # Скрипт запуска фаззера
│   ├── gen_seed.py             # Генератор seed TIFF-файлов
│   ├── seeds/                  # Начальные TIFF-файлы для фаззинга
│   └── results/
│       ├── afl_run.log         # Лог запуска AFL++
│       ├── fuzzer_stats.txt    # Статистика фаззера
│       └── fuzz_summary.md     # Резюме запуска фаззинга
├── reports/
│   └── findings.md             # Разметка 3 сработок (Задача 2)
└── scripts/
    └── build_all.sh            # Сборка всех образов
```

## Версии

| Компонент     | Версия                            |
|---------------|-----------------------------------|
| libtiff       | из Sisyphus ALT Linux             |
| Cppcheck      | 2.16.1                            |
| AFL++         | 4.36a                             |
| Базовый образ | registry.altlinux.org/alt/alt:p11 |

## Об источнике исходного кода

Исходный код libtiff берётся из репозитория проекта Sisyphus на git.altlinux.org:

```
https://git.altlinux.org/gears/l/libtiff.git
```

Это gear-репозиторий ALT Linux. Его структура:

```
libtiff.git/
├── .gear/              ← правила сборки gear (rules, tags)
├── libtiff.spec        ← RPM spec-файл с версией и патчами
├── *.patch             ← ALT-специфичные патчи поверх upstream
└── (ветка upstream/)   ← нетронутые upstream-исходники
```

Upstream-исходники находятся в ветке `upstream` внутри gear-репозитория. Dockerfile автоматически переключается на неё и извлекает исходники для анализа/сборки.

## Быстрый старт

### Требования

- Podman или Docker
- x86_64 (ALT Linux p11)
- Интернет-доступ

### 1. Клонировать репозиторий

```bash
git clone https://github.com/GordenyN/libtiff-sast-fuzz.git
cd libtiff-sast-fuzz
```

### 2. Собрать образы

```bash
podman build --network host --tag libtiff-sast:latest ./sast/
podman build --network host --tag libtiff-fuzz:latest ./fuzzing/
```

### 3. Запустить статический анализ

```bash
mkdir -p sast/results
podman run --rm \
  -v "$(pwd)/sast/results:/output:Z" \
  libtiff-sast
```

Результаты сохраняются в `sast/results/cppcheck_report.xml` и `cppcheck_report.txt`.

### 4. Запустить фаззинг

```bash
mkdir -p fuzzing/results
podman run --rm \
  --privileged \
  --ipc=host \
  -e FUZZ_DURATION=300 \
  -v "$(pwd)/fuzzing/results:/fuzz/output:Z" \
  libtiff-fuzz
```

`--privileged` и `--ipc=host` обязательны для работы AFL++.  
`FUZZ_DURATION` — время работы фаззера в секундах (по умолчанию 60).

## Результаты статического анализа

| Уровень     | Количество |
|-------------|------------|
| error       | 36         |
| warning     | 7          |
| portability | 25         |
| style       | 279        |
| information | 127        |

## Результаты фаззинга

| Параметр           | Значение        |
|--------------------|-----------------|
| Таргет             | tiffinfo -i -D  |
| Инструмент         | AFL++ 4.36a     |
| Время работы       | 297 секунд      |
| Итераций           | 45 103          |
| Скорость           | ~151 ит/сек     |
| Новых corpus items | 394             |
| Крэшей             | 0               |
| Зависаний          | 0               |

## Описание задач

| Задача   | Описание |
|----------|----------|
| Задача 1 | Статический анализ libtiff через Cppcheck в контейнере ALT Linux p11 |
| Задача 2 | Разметка 3 сработок `error`-уровня → `reports/findings.md` |
| Задача 3 | Сборка с `afl-clang-fast`, фаззинг утилиты `tiffinfo` |
