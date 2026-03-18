#!/bin/bash

if [[ "$OSTYPE" == "darwin"* ]]; then
        # Mac OSX
    export CFLAGS="$CFLAGS -Xpreprocessor -fopenmp"
    export CXXFLAGS="$CXXFLAGS -Xpreprocessor -fopenmp"
    export LDFLAGS="$LDFLAGS -lomp"
fi

if [[ $build_platform != $target_platform ]]; then
    # write to separate cross-file to not interfere with default cross-python activation, c.f.
    # https://github.com/conda-forge/cross-python-feedstock/blob/91d3c9cf/recipe/activate-cross-python.sh#L111-L125
    echo "[binaries]"                                   >> $SRC_DIR/refnx_cross_file.txt
    echo "cc=arm64-apple-darwin20.0.0-clang"            >> $SRC_DIR/refnx_cross_file.txt
    echo "cpp=arm64-apple-darwin20.0.0-clang++"         >> $SRC_DIR/refnx_cross_file.txt

    echo "[host_machine]"                               >> $SRC_DIR/refnx_cross_file.txt
    echo "cpu=arm64"                                    >> $SRC_DIR/refnx_cross_file.txt
    echo "system='darwin'"                              >> $SRC_DIR/refnx_cross_file.txt
    echo "cpu_family='arm'"                             >> $SRC_DIR/refnx_cross_file.txt

    echo "[properties]"                                 >> $SRC_DIR/refnx_cross_file.txt
    echo "c_args = ['-target', 'arm64-apple-darwin']"   >> $SRC_DIR/refnx_cross_file.txt
    echo "cpp_args = ['-target', 'arm64-apple-darwin']" >> $SRC_DIR/refnx_cross_file.txt
    export MESON_ARGS="$MESON_ARGS --cross-file=$SRC_DIR/refnx_cross_file.txt"
    $PYTHON -m pip uninstall ninja
fi

mkdir builddir

# -wnx flags mean: --wheel --no-isolation --skip-dependency-check
$PYTHON -m build -w -n -v -x \
    -Cbuilddir=builddir \
    -Csetup-args=${MESON_ARGS// / -Csetup-args=} \
    || (cat builddir/meson-logs/meson-log.txt && exit 1)

$PYTHON -m pip install dist/refnx*.whl


# Copy the [de]activate scripts to $PREFIX/etc/conda/[de]activate.d.
# This will allow them to be run on environment activation.
for CHANGE in "activate" "deactivate"
do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    cp "${RECIPE_DIR}/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/refnx_${CHANGE}.sh"
done
