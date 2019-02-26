#!/bin/bash
VENVDIR=$TOPDIR"/tools/venv"
CFGDIR=$TOPDIR"/tools/cfg"

PYTHON=$(type -p python)
if [[ -z "${PYTHON}" ]]; then
    echo "'python' is not installed on this system, can't continue..."
    exit 1
fi
PYTHON_VERSION=$(python -c "import sys; print('{0[0]}'.format(sys.version_info))")
if [ ${PYTHON_VERSION} -ne "3" ];
then
    echo "found python version ${PYTHON_VERSION}"
    echo "python3 is required for cattlepi. please install/fix and try again..."
    exit 1
fi

VIRTUALENV=$(type -p virtualenv)
if [[ -z "${VIRTUALENV}" ]]; then
    echo "'virtualenv' is not installed on this system, can't continue..."
    exit 1
fi

mkdir -p $TOPDIR"/builder/latest"

if [[ -r $VENVDIR/bin/activate ]]; then
    echo "environment already setup. skipping (make clean to force env rebuild)"
else
    rm -rf $VENVDIR/*
    $VIRTUALENV $VENVDIR
    # do a grep instead of cp to address: https://github.com/cattlepi/cattlepi/issues/29
    grep -v "pkg-resources==0.0.0" $CFGDIR"/requirements.txt" > $VENVDIR"/requirements.txt"
    source $VENVDIR/bin/activate
    cd $VENVDIR && pip install -r requirements.txt
    deactivate
fi
