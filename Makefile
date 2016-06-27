ANSIBLE_FLAGS ?= -b -i hosts -e "ansible_python_interpreter=/usr/bin/python"
SCALEIO_COMMON_FILE_INSTALL_FILE_LOCATION ?= ../scaleio-files

.PHONY:
changelog:
	git log --oneline > Changelog.txt

.PHONY:
test-ubuntu-trusty: 
	cd test/ubuntu/14.04 && vagrant up && vagrant ssh-config > ssh-config
	cd ../../
	ansible-playbook $(ANSIBLE_FLAGS) \
	--ssh-common-args="-F test/ubuntu/14.04/ssh-config" \
	-e "scaleio_interface=eth1" \
    	-e "scaleio_gateway_is_redundant=true" \
	-e "scaleio_gateway_virtual_ip=192.168.33.49" \
	-e "scaleio_gateway_virtual_interface=eth1" \
	-e "scaleio_common_file_install_file_location=$(SCALEIO_COMMON_FILE_INSTALL_FILE_LOCATION)/2.0/Ubuntu/14.04" \
	-e "scaleio_sdc_driver_sync_emc_public_gpg_key_src=$(SCALEIO_COMMON_FILE_INSTALL_FILE_LOCATION)/2.0/common/RPM-GPG-KEY-ScaleIO_2.0.6035.0" \
	site.yml

.PHONY:
test-centos-7: clean
	cd test/centos/7 && vagrant up && vagrant ssh-config > ssh-config
	cd ../../
	ansible-playbook $(ANSIBLE_FLAGS) \
	--ssh-common-args="-F test/centos/7/ssh-config" \
	-e "scaleio_interface=enp0s8" \
    	-e "scaleio_gateway_is_redundant=true" \
    	-e "scaleio_gateway_virtual_ip=192.168.33.49" \
    	-e "scaleio_gateway_virtual_interface=enp0s8" \
	-e "scaleio_common_file_install_file_location=$(SCALEIO_COMMON_FILE_INSTALL_FILE_LOCATION)/2.0/RHEL/7" \
	-e "scaleio_sdc_driver_sync_emc_public_gpg_key_src=$(SCALEIO_COMMON_FILE_INSTALL_FILE_LOCATION)/2.0/common/RPM-GPG-KEY-ScaleIO_2.0.6035.0" \
	site.yml

.PHONY:
test: test-ubuntu-trusty test-centos-7

.PHONY:
clean:
	rm -f site.retry
	cd test/ubuntu/14.04 && vagrant destroy -f
	cd test/centos/7 && vagrant destroy -f
	find . -type f -name ssh-config -exec rm {} \;
