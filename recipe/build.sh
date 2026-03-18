#!/bin/bash
set -ex

mkdir builddir

if [[ $build_platform != $target_platform ]]; then
    # write to separate cross-file to not interfere with default cross-python activation, c.f.
    # https://github.com/conda-forge/cross-python-feedstock/blob/91d3c9cf/recipe/activate-cross-python.sh#L111-L125
    echo "[binaries]"                                   > $SRC_DIR/refnx_cross_file.txt
    # Forces use of --free-threading for f2py, which otherwise goes missing in cross compilation; see #314
    echo "numpy-config = '${PREFIX}/bin/numpy-config'" >> $SRC_DIR/refnx_cross_file.txt
    export MESON_ARGS="$MESON_ARGS --cross-file=$SRC_DIR/refnx_cross_file.txt"
fi

# -wnx flags mean: --wheel --no-isolation --skip-dependency-check
$PYTHON -m build -w -n -vv -x \
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
