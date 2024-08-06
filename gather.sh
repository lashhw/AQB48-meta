#!/bin/bash
set -e

for i in bathroom bmw classroom house kitchen staircase teapot; do
    cd AQB48-baseline-catapult/data
    rm -rf *.bin
    ../../AQB48-baseline/data/rtcore/generate "../../scene/${i}.ply" "../../scene-small/${i}_100000.ray"

    cd ../work
    make clean

    make c_sim

    make syn
    mv syn.log "../../${i}.syn"

    make gate_sim
    mv transcript "../../${i}.transcript"

    make pwr
    mv pwr.log "../../${i}.pwr"

    cd ../../
done