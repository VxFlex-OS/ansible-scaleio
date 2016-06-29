#ANSIBLE_FLAGS ?= -b -i hosts -e "ansible_python_interpreter=/usr/bin/python"
ANSIBLE_FLAGS ?= -b -i hosts ansible_python_interpreter: "/usr/bin/python"
SCALEIO_COMMON_FILE_INSTALL_FILE_LOCATION ?= ../scaleio-files
TRITON_EXEC=$(HOME)/node_modules/triton/bin/triton
TRITON_NETWORK=e1c9d08b
TRITON_UBUNTU_IMG=37d3b920
TRITON_PACKAGE=34b8cc69
SSH_CONFIG=test/triton/ssh-config

.PHONY:
changelog:
	git log --oneline > Changelog.txt

.PHONY:
test-ubuntu-trusty: prep-ubuntu-env
	ansible-playbook $(ANSIBLE_FLAGS) \
	--ssh-common-args="-F $(SSH_CONFIG)" \
	-e "scaleio_interface=eth0" \
    	-e "scaleio_gateway_is_redundant=false" \
	-e "scaleio_gateway_virtual_ip=192.168.33.49" \
	-e "scaleio_gateway_virtual_interface=eth0" \
	-e "scaleio_common_file_install_file_location=$(SCALEIO_COMMON_FILE_INSTALL_FILE_LOCATION)/2.0/Ubuntu/14.04" \
	-e "scaleio_sdc_driver_sync_emc_public_gpg_key_src=$(SCALEIO_COMMON_FILE_INSTALL_FILE_LOCATION)/2.0/common/RPM-GPG-KEY-ScaleIO_2.0.6035.0" \
	site.yml

.PHONY:
test-centos-7: clean
	ansible-playbook $(ANSIBLE_FLAGS) \
	--ssh-common-args="-F $(SSH_CONFIG)" \
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
prep-ubuntu-env: clean-ubuntu-env
	touch ssh-config
	for node in node0 node1 node2 node3 node4 ; do \
		$(TRITON_EXEC) inst create -w -n $$node -t scaleio=ubuntu -M "user-script=test/triton/user-script.sh" -N $(TRITON_NETWORK) $(TRITON_UBUNTU_IMG) $(TRITON_PACKAGE) ; \
		echo "Host $$node" >> $(SSH_CONFIG) ; \
  		echo "HostName `$(TRITON_EXEC) inst ip $$node`" >> $(SSH_CONFIG) ; \
  		echo "User ubuntu" >> $(SSH_CONFIG) ; \
  		echo "Port 22" >> $(SSH_CONFIG) ; \
  		echo "UserKnownHostsFile /dev/null" >> $(SSH_CONFIG) ; \
  		echo "StrictHostKeyChecking no" >> $(SSH_CONFIG) ; \
  		echo "PasswordAuthentication no" >> $(SSH_CONFIG) ; \
  		echo "IdentitiesOnly yes" >> $(SSH_CONFIG) ; \
  		echo "LogLevel FATAL" >> $(SSH_CONFIG) ; \
	done
	sleep 10


.PHONY:
clean-ubuntu-env:
	for node in `$(TRITON_EXEC) inst ls -Ho id`; do \
		$(TRITON_EXEC) inst rm -w $$node ; \
	done
	if [ -f $(SSH_CONFIG) ]; then rm $(SSH_CONFIG) ; fi
	

.PHONY:
clean:
	rm -f site.retry
	cd test/ubuntu/14.04 && vagrant destroy -f
	cd test/centos/7 && vagrant destroy -f
	find . -type f -name ssh-config -exec rm {} \;
