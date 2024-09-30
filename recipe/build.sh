#!/bin/bash

if [[ "$OSTYPE" == "darwin"* ]]; then
        # Mac OSX
    export CFLAGS="$CFLAGS -Xpreprocessor -fopenmp"
    export CXXFLAGS="$CXXFLAGS -Xpreprocessor -fopenmp"
    export LDFLAGS="$LDFLAGS -lomp"
fi


python setup.py install --single-version-externally-managed --record=record.txt

# Copy the [de]activate scripts to $PREFIX/etc/conda/[de]activate.d.
# This will allow them to be run on environment activation.
for CHANGE in "activate" "deactivate"
do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    cp "${RECIPE_DIR}/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/refnx_${CHANGE}.sh"
done
