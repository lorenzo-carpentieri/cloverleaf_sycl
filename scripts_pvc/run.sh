CXX_COMPILER=$1
# num of runs
NUM_RUNS=1
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


## APP
rm -rf $BUILD_DIR/*
cd $BUILD_DIR
${SCRIPT_DIR}/compile.sh APP 0 $CXX_COMPILER
make -j 

for ((i=0; i<$NUM_RUNS;i++));
do
    echo Run $i 
    mpirun -n 4 ./clover_leaf  --file ../input_file/${INPUT_FILE_CLOVERLEAF} 2>> ../${LOG_DIR}/clover_leaf_per_app.log
    intel_gpu_frequency -d
done

## KERNEL
rm -rf $BUILD_DIR/*
cd $BUILD_DIR
${SCRIPT_DIR}/compile.sh KERNEL 0 $CXX_COMPILER
make -j 
for ((i=0; i<$NUM_RUNS;i++));
do
    echo Run $i 
    mpirun -n 4 ./clover_leaf --file ../input_file/${INPUT_FILE_CLOVERLEAF} 2>> ../${LOG_DIR}/clover_leaf_per_kernel.log
    intel_gpu_frequency -d
done


## NO_HIDING
rm -rf $BUILD_DIR/*
cd $BUILD_DIR
${SCRIPT_DIR}/compile.sh PHASE 0 $CXX_COMPILER
make -j 
for ((i=0; i<$NUM_RUNS;i++));
do
    echo Run $i 
    mpirun -n 4 ./clover_leaf  --file ../input_file/${INPUT_FILE_CLOVERLEAF} 2>> ../${LOG_DIR}/clover_leaf_no_hiding.log
    intel_gpu_frequency -d
done

## HIDING
rm -rf $BUILD_DIR/*
cd $BUILD_DIR
${SCRIPT_DIR}/compile.sh PHASE 1 $CXX_COMPILER
make -j 
for ((i=0; i<$NUM_RUNS;i++));
do
    echo Run $i 
    mpirun -n 4 ./clover_leaf  --file ../input_file/${INPUT_FILE_CLOVERLEAF} 2>> ../${LOG_DIR}/clover_leaf_hiding.log
    intel_gpu_frequency -d
done




