# AFL++ Fuzzing Summary

**Дата:** 2026-03-07 17:15:49 UTC
**Таргет:** /fuzz/install/bin/tiffinfo
**Аргументы:** -D "$INPUT"
**Длительность:** 300 секунд
**Корпус seed-файлов:** 4 файл(ов)

## Статистика
```
start_time        : 1772903450
last_update       : 1772903747
run_time          : 297
fuzzer_pid        : 21
cycles_done       : 0
cycles_wo_finds   : 0
time_wo_finds     : 20
fuzz_time         : 260
calibration_time  : 31
cmplog_time       : 0
sync_time         : 0
trim_time         : 5
execs_done        : 45103
execs_per_sec     : 151.52
execs_ps_last_min : 159.67
corpus_count      : 398
corpus_favored    : 175
corpus_found      : 394
corpus_imported   : 0
corpus_variable   : 0
max_depth         : 3
cur_item          : 48
pending_favs      : 165
pending_total     : 382
stability         : 100.00%
bitmap_cvg        : 0.02%
saved_crashes     : 0
saved_hangs       : 0
total_tmout       : 0
last_find         : 1772903744
last_crash        : 0
last_hang         : 0
execs_since_crash : 45103
exec_timeout      : 5000
slowest_exec_ms   : 0
peak_rss_mb       : 0
cpu_affinity      : 0
edges_found       : 1324
total_edges       : 8388608
var_byte_count    : 0
havoc_expansion   : 0
auto_dict_entries : 0
testcache_size    : 52722
testcache_count   : 398
testcache_evict   : 0
afl_banner        : /fuzz/install/bin/tiffinfo
afl_version       : ++4.36a
target_mode       : no_fsrv persistent shmem_testcase deferred 
command_line      : afl-fuzz -i /fuzz/seeds -o /fuzz/output/afl_out -t 5000 -m none -- /fuzz/install/bin/tiffinfo -i -D @@
```

## Результат
✅ Крэшей не обнаружено за время работы фаззера.
