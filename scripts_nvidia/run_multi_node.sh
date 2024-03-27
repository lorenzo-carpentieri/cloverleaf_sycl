#!/bin/bash

# Create an array with the specified numbers
NUM_NODES=(1 1 2 4)
NUM_GPUS=(2 4 8 16)
PATH_TO_CLOVERLEAF_REPO=$1
NUM_RUNS=$2
EXECUTABLES=("clover_leaf_per_app" "clover_leaf_per_kernel" "clover_leaf_per_phase_hiding" "clover_leaf_per_phase_no_hiding")
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

./generate_executables.sh

for ((i=0; i<${NUM_RUNS}; i++)); do
    for ((i=0; i<${#NUM_NODES[@]}; i++)); do
        for exe in "${EXECUTABLES[@]}"; do
            ${SCRIPT_DIR}/slurm_run.sh "${NUM_GPUS[i]}" "${NUM_NODES[i]}"  ${exe} ${PATH_TO_CLOVERLEAF_REPO} ${NUM_RUNS}
        done
    done
done