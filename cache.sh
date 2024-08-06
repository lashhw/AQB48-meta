#!/bin/bash
set -e

for i in bathroom bmw classroom house kitchen staircase teapot; do
    cd AQB48-baseline-catapult/data
    rm -rf -- *.bin
    ../../AQB48-baseline/data/rtcore/generate "../../scene/${i}.ply" "../../scene/${i}.ray"

    cd ../work
    make clean
    make c_sim
    ../../AQB48-baseline/util/cache_stats_unified trace.txt 128 4 2048 8 64 16 > "${i}.cache"
    mv "${i}.cache" ../../

    cd ../../
done