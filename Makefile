mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
current_dir := $(dir ${mkfile_path})

clean: 
	@rm -rf ${current_dir}/builder/*

