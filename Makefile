mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
current_dir := $(dir ${mkfile_path})
.DEFAULT_GOAL := all

envsetup:
	@echo "make: envsetup"
	bin/myenv.sh ${current_dir}tools/util/setup_env.sh

raspbian_initfs:
	@echo "make: raspbian_initfs"
	bin/myenv.sh "${current_dir}recipes/raspbian_initfs"

raspbian_rootfs:
	@echo "make: raspbian_rootfs"
	bin/myenv.sh "${current_dir}recipes/raspbian_rootfs"

raspbian_all:
	@echo "make: raspbian_all"
	bin/myenv.sh "${current_dir}recipes/raspbian_all"

copy_initfs_to_sdcard:
	@echo "make: copy_initfs_to_sdcard"
	bin/myenv.sh "${current_dir}recipes/copy_initfs_to_sdcard"

localapi_run:
	@echo "make: localapi_run"
	bin/myenv.sh "${current_dir}recipes/localapi_run"

localapi_test:
	@echo "make: localapi_test"
	bin/myenv.sh "${current_dir}recipes/localapi_test"

clean:
	@echo "make: clean"
	@rm -rf ${current_dir}builder/*

all: clean raspbian_all

