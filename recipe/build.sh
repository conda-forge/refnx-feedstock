#!/bin/bash

if [[ "$OSTYPE" == "darwin"* ]]; then
        # Mac OSX
    export CFLAGS="$CFLAGS -Xpreprocessor -fopenmp"
    export CXXFLAGS="$CXXFLAGS -Xpreprocessor -fopenmp"
    export LDFLAGS="$LDFLAGS -lomp"
fi

mkdir builddir

# -wnx flags mean: --wheel --no-isolation --skip-dependency-check
$PYTHON -m build -w -n -x \
    -Cbuilddir=builddir \
    -Csetup-args=${MESON_ARGS// / -Csetup-args=} \
    || (cat builddir/meson-logs/meson-log.txt && exit 1)

$python -m pip install dist/refnx*.whl


# Copy the [de]activate scripts to $PREFIX/etc/conda/[de]activate.d.
# This will allow them to be run on environment activation.
for CHANGE in "activate" "deactivate"
do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    cp "${RECIPE_DIR}/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/refnx_${CHANGE}.sh"
done
