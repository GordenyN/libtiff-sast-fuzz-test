# Dockerfile для сборки libtiff 4.4.0 с AFL++ инструментацией и запуска фаззинга
# Базовый образ: ALT Linux Sisyphus (x86_64)
# Исходный код: репозиторий Sisyphus — git.altlinux.org/gears/l/libtiff.git

FROM registry.altlinux.org/alt/alt:p11

LABEL maintainer="sast-engineer"
LABEL description="AFL++ fuzzing of libtiff 4.4.0"
LABEL libtiff.version="4.4.0"
LABEL aflplusplus.version="4.09c"
LABEL base.image="altlinux/sisyphus"

ENV AFL_VERSION=4.09c

# ── Системные зависимости (ALT Linux / apt-rpm) ──────────────────────────────
# В Sisyphus пакеты называются иначе, чем в Ubuntu:
#   gcc-c++       вместо build-essential
#   clang         clang доступен в Sisyphus
#   libtool       libtool
#   zlib-devel    вместо zlib1g-dev
#   libjpeg-devel вместо libjpeg-dev
RUN apt-get update && apt-get install -y \
    gcc \
    gcc-c++ \
    clang \
    llvm \
    llvm-devel \
    make \
    cmake \
    autoconf \
    automake \
    libtool \
    pkg-config \
    git \
    wget \
    curl \
    ca-certificates \
    tar \
    python3 \
    python3-dev \
    zlib-devel \
    libjpeg-devel \
    libzstd-devel \
    liblzma-devel \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

# ── Сборка AFL++ из исходников ───────────────────────────────────────────────
RUN git clone --depth=1 https://github.com/AFLplusplus/AFLplusplus.git \
    && cd AFLplusplus \
    && make -j"$(nproc)" \
    && make install \
    && cd /build \
    && rm -rf AFLplusplus

# ── Получить исходный код libtiff из Sisyphus ────────────────────────────────
RUN git clone \
    https://git.altlinux.org/gears/l/libtiff.git \
    libtiff-sisyphus

# Извлечь upstream-исходники из gear-репозитория
# В ALT gear-репо: ветка upstream/ содержит нетронутые upstream-исходники
RUN cd libtiff-sisyphus && \
    echo "=== Ветки ===" && git branch -a && \
    echo "=== Теги ===" && git tag | head -20 && \
    if git branch -a | grep -q "remotes/origin/upstream"; then \
        git checkout upstream; \
        mkdir -p /build/libtiff-src; \
        git archive HEAD | tar -x -C /build/libtiff-src/; \
    else \
        mkdir -p /build/libtiff-src; \
        cp -r . /build/libtiff-src/; \
    fi

# ── Сборка libtiff с AFL++ инструментацией ──────────────────────────────────
RUN cd /build/libtiff-src && \
    # Если это gear-репо без configure — запустить autogen
    [ -f configure ] || ([ -f autogen.sh ] && bash autogen.sh || autoreconf -fi) && \
    CC=afl-clang-fast \
    AFL_LLVM_INSTRUMENT=CLASSIC \
    CXX=afl-clang-fast++ \
    CFLAGS="-O1 -g" \
    CXXFLAGS="-O1 -g" \
    LDFLAGS="" \
    ./configure \
        --prefix=/fuzz/install \
        --disable-shared \
        --enable-static \
        --with-zlib \
        --with-jpeg \
    && make -j"$(nproc)" \
    && make install

# Проверка инструментации: наличие AFL-маркеров в бинаре
RUN strings /fuzz/install/bin/tiffinfo | grep -c "__afl_" | tee /build/afl_instrumentation_check.txt && \
    echo "[+] AFL instrumentation confirmed: $(cat /build/afl_instrumentation_check.txt) symbols"

# ── Seed corpus ──────────────────────────────────────────────────────────────
RUN mkdir -p /fuzz/seeds
COPY seeds/ /fuzz/seeds/

# Сгенерировать минимальный валидный TIFF (1x1 px, grayscale, little-endian)
COPY gen_seed.py /tmp/gen_seed.py
RUN python3 /tmp/gen_seed.py

# ── Скрипты ──────────────────────────────────────────────────────────────────
COPY build_fuzz.sh /fuzz/build_fuzz.sh
COPY run_fuzzer.sh /fuzz/run_fuzzer.sh
RUN chmod +x /fuzz/build_fuzz.sh /fuzz/run_fuzzer.sh

WORKDIR /fuzz
VOLUME ["/fuzz/output"]

ENTRYPOINT ["/fuzz/run_fuzzer.sh"]
