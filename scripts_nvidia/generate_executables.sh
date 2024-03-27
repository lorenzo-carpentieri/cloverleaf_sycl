
CXX_COMPILER=$1
# create the path to build directory
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
BUILD_DIR=$SCRIPT_DIR/../build
LOG_DIR=logs_${NUM_GPUS}gpus_${NUM_NODES}nodes_${NUM_RUNS}runs
INPUT_FILE_CLOVERLEAF="clover_bm8_short.in"
EXECUTABLE_DIR="executables"

if [ ! -d "$SCRIPT_DIR/../${LOG_DIR}" ]; then
    # Create the directory
    mkdir -p "$SCRIPT_DIR/../${LOG_DIR}"
    echo "Directory created: $SCRIPT_DIR/../${LOG_DIR}"
else
    echo "Directory already exists: $SCRIPT_DIR/../${LOG_DIR}"
    rm -rf $SCRIPT_DIR/../${LOG_DIR}/*
fi

# Create the directory with all the executables for the different approach 
if [ ! -d "$SCRIPT_DIR/../${EXECUTABLE_DIR}" ]; then
    # Create the directory
    mkdir -p "$SCRIPT_DIR/../${EXECUTABLE_DIR}"
    echo "Directory created: $SCRIPT_DIR/../${EXECUTABLE_DIR}"
else
    echo "Directory already exists: $SCRIPT_DIR/../${EXECUTABLE_DIR}"
    rm -rf $SCRIPT_DIR/../${EXECUTABLE_DIR}/*
fi

## APP
rm -rf $BUILD_DIR/*
cd $BUILD_DIR
${SCRIPT_DIR}/compile.sh APP 0 $CXX_COMPILER
make -j 
mv ./clover_leaf ../${EXECUTABLE_DIR}/clover_leaf_per_app

# for ((i=0; i<$NUM_RUNS;i++));
# do
#     echo Run $i 
#     mpirun -n ${NUM_GPUS} ./clover_leaf  --file ../input_file/${INPUT_FILE_CLOVERLEAF} 2>> ../${LOG_DIR}/clover_leaf_per_app.log
#     nvidia-smi -ac $memfreq,$corefreq 
# done

## KERNEL
rm -rf $BUILD_DIR/*
cd $BUILD_DIR
${SCRIPT_DIR}/compile.sh KERNEL 0 $CXX_COMPILER
make -j 
mv ./clover_leaf ../${EXECUTABLE_DIR}/clover_leaf_per_kernel

# for ((i=0; i<$NUM_RUNS;i++));
# do
#     echo Run $i 
#     mpirun -n ${NUM_GPUS} ./clover_leaf --file ../input_file/${INPUT_FILE_CLOVERLEAF} 2>> ../${LOG_DIR}/clover_leaf_per_kernel.log
#     nvidia-smi -gc
#     nvidia-smi -ac
# done


## NO_HIDING
rm -rf $BUILD_DIR/*
cd $BUILD_DIR
${SCRIPT_DIR}/compile.sh PHASE 0 $CXX_COMPILER
make -j 
mv ./clover_leaf ../${EXECUTABLE_DIR}/clover_leaf_per_phase_no_hiding

# for ((i=0; i<$NUM_RUNS;i++));
# do
#     echo Run $i 
#     mpirun -n ${NUM_GPUS} ./clover_leaf  --file ../input_file/${INPUT_FILE_CLOVERLEAF} 2>> ../${LOG_DIR}/clover_leaf_no_hiding.log
#     nvidia-smi -gc
#     nvidia-smi -ac
# done

## HIDING
rm -rf $BUILD_DIR/*
cd $BUILD_DIR
${SCRIPT_DIR}/compile.sh PHASE 1 $CXX_COMPILER
make -j 
mv ./clover_leaf ../${EXECUTABLE_DIR}/clover_leaf_per_phase_hiding

# for ((i=0; i<$NUM_RUNS;i++));
# do
#     echo Run $i 
#     mpirun -n ${NUM_GPUS} ./clover_leaf  --file ../input_file/${INPUT_FILE_CLOVERLEAF} 2>> ../${LOG_DIR}/clover_leaf_hiding.log
#     nvidia-smi -gc
#     nvidia-smi -ac
# done




