#!/bin/bash
SELFDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TOPDIR="$(dirname $(dirname ${SELFDIR}))"

OUTPUT_FILE=${TOPDIR}/Makefile
OUTPUT_FILE_TMP=${OUTPUT_FILE}.tmp

cat <<"EOF" > ${OUTPUT_FILE_TMP}
mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
current_dir := $(dir ${mkfile_path})
.DEFAULT_GOAL := all

envsetup:
	@echo "make: envsetup"
	export TOPDIR=${current_dir} && ${current_dir}tools/util/setup_env.sh

clean:
	@echo "make: clean"
	@rm -rf ${current_dir}builder/*
	@rm -rf ${current_dir}tools/venv/*

all: clean raspbian_cattlepi

EOF

for RECIPE in $(ls -1 ${TOPDIR}/recipes)
do
cat <<EOF >> ${OUTPUT_FILE_TMP}
${RECIPE%.*}: envsetup
	@echo "make: ${RECIPE%.*}"
	bin/myenv.sh "\${current_dir}recipes/${RECIPE}"

EOF
done

diff -q ${OUTPUT_FILE_TMP} ${OUTPUT_FILE} || mv ${OUTPUT_FILE_TMP} ${OUTPUT_FILE}


