# Dockerfile для статического анализа libtiff 4.4.0 с помощью Cppcheck
# Базовый образ: ALT Linux Sisyphus (x86_64)
# Исходный код: репозиторий Sisyphus — git.altlinux.org/gears/l/libtiff.git

FROM registry.altlinux.org/alt/alt:p11

LABEL maintainer="sast-engineer"
LABEL description="Static analysis of libtiff 4.4.0 using Cppcheck"
LABEL libtiff.version="4.4.0"
LABEL base.image="altlinux/sisyphus"

# Установка зависимостей через apt-get (ALT Linux использует apt-rpm / apt-get)
RUN apt-get update && apt-get install -y \
    cppcheck \
    git \
    ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /analysis

# Клонировать репозиторий libtiff из Sisyphus (ALT Linux gear-репозиторий)
# Репозиторий содержит upstream-исходники + ALT-специфичные патчи и spec-файл
RUN git clone \
    https://git.altlinux.org/gears/l/libtiff.git \
    libtiff-sisyphus

# Переключиться на тег версии 4.4.0
# В gear-репозитории upstream-тарболл распакован в ветку или доступен через git archive
# Пробуем сначала тег, затем ветку с upstream-исходниками
RUN cd libtiff-sisyphus && \
    git tag | grep -i "4.4.0" || echo "Доступные теги:" && \
    git tag | head -20

# Получить upstream-исходники через gear-команду или из .gear/
# В Sisyphus gear-репозитории upstream tarball хранится в ветке upstream/
# или собирается через gear. Используем git archive из ветки upstream:
RUN cd libtiff-sisyphus && \
    if git branch -a | grep -q "upstream"; then \
        git archive upstream -- . | tar -x -C /analysis/libtiff-src/; \
    else \
        # Fallback: использовать содержимое репозитория напрямую \
        mkdir -p /analysis/libtiff-src && \
        cp -r . /analysis/libtiff-src/; \
    fi

# Зафиксировать версии инструментов
RUN cppcheck --version | tee /analysis/cppcheck_version.txt && \
    git -C libtiff-sisyphus log --oneline -5 | tee /analysis/libtiff_git_log.txt

COPY run_analysis.sh /analysis/run_analysis.sh
RUN chmod +x /analysis/run_analysis.sh

VOLUME ["/output"]

ENTRYPOINT ["/analysis/run_analysis.sh"]
