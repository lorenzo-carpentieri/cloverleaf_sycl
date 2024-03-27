
# Specify the number of GPUs and the number of nodes  and num of runs for each benchmark
NUM_GPUS=$1
NUM_NODES=$2
# num of runs
NUM_RUNS=$3
# create the path to build directory
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
BUILD_DIR=$SCRIPT_DIR/../build
LOG_DIR=logs_all_${NUM_RUNS}runs
INPUT_FILE_CLOVERLEAF="clover_bm8_short.in"

if [ ! -d "$SCRIPT_DIR/../${LOG_DIR}" ]; then
    # Create the directory
    mkdir -p "$SCRIPT_DIR/../${LOG_DIR}"
    echo "Directory created: $SCRIPT_DIR/../${LOG_DIR}"
else
    echo "Directory already exists: $SCRIPT_DIR/../${LOG_DIR}"
    rm -rf $SCRIPT_DIR/../${LOG_DIR}/*
fi

#TODO: set with the Per app frequency
memfreq=0
corefreq=0

## APP
rm -rf $BUILD_DIR/*
cd $BUILD_DIR
${SCRIPT_DIR}/compile.sh APP 0
make -j 

for ((i=0; i<$NUM_RUNS;i++));
do
    echo Run $i 
    mpirun -n ${NUM_GPUS} ./clover_leaf  --file ../input_file/${INPUT_FILE_CLOVERLEAF} 2>> ../${LOG_DIR}/clover_leaf_per_app.log
    nvidia-smi -ac $memfreq,$corefreq 
done

## KERNEL
rm -rf $BUILD_DIR/*
cd $BUILD_DIR
${SCRIPT_DIR}/compile.sh KERNEL 0
make -j 
for ((i=0; i<$NUM_RUNS;i++));
do
    echo Run $i 
    mpirun -n ${NUM_GPUS} ./clover_leaf --file ../input_file/${INPUT_FILE_CLOVERLEAF} 2>> ../${LOG_DIR}/clover_leaf_per_kernel.log
    nvidia-smi -gc
    nvidia-smi -ac
done


## NO_HIDING
rm -rf $BUILD_DIR/*
cd $BUILD_DIR
${SCRIPT_DIR}/compile.sh PHASE 0
make -j 
for ((i=0; i<$NUM_RUNS;i++));
do
    echo Run $i 
    mpirun -n ${NUM_GPUS} ./clover_leaf  --file ../input_file/${INPUT_FILE_CLOVERLEAF} 2>> ../${LOG_DIR}/clover_leaf_no_hiding.log
    nvidia-smi -gc
    nvidia-smi -ac
done

## HIDING
rm -rf $BUILD_DIR/*
cd $BUILD_DIR
${SCRIPT_DIR}/compile.sh PHASE 1
make -j 
for ((i=0; i<$NUM_RUNS;i++));
do
    echo Run $i 
    mpirun -n ${NUM_GPUS} ./clover_leaf  --file ../input_file/${INPUT_FILE_CLOVERLEAF} 2>> ../${LOG_DIR}/clover_leaf_hiding.log
    nvidia-smi -gc
    nvidia-smi -ac
done




