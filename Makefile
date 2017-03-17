NAME=ngrok2-relay
BASE_DIR=.
BUILD_DIR=$(BASE_DIR)/build
OUT_DIR=$(BASE_DIR)/dist
TARGET_IMAGE=$(OUT_DIR)/$(NAME).linux.amd64.aci

.DEFAULT_GOAL := $(TARGET_IMAGE)
.PHONY: clean test deploy

GPG=gpg2
CLIENT_INSTALLER_URL=https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip
BUILDROOT_VERSION=2017.02
ACBUILD_VERSION=0.4.0
RKT_VERSION=1.25.0
ACBUILD=build/acbuild

deploy: $(TARGET_IMAGE) $(TARGET_IMAGE).asc

$(OUT_DIR)/%.aci.asc: dist/%.aci signing.key
	$(eval TMP_PUBLIC_KEYRING := $(shell mktemp -p ./build))
	$(eval TMP_SECRET_KEYRING := $(shell mktemp -p ./build))
	$(eval GPG_FLAGS := --batch --no-default-keyring --keyring $(TMP_PUBLIC_KEYRING) --secret-keyring $(TMP_SECRET_KEYRING) )
	$(GPG) $(GPG_FLAGS) --import signing.key
	rm -f $@
	$(GPG) $(GPG_FLAGS) --armour --detach-sign $<
	rm $(TMP_PUBLIC_KEYRING) $(TMP_SECRET_KEYRING)

$(OUT_DIR)/$(NAME)-%.linux.amd64.aci: $(TARGET_IMAGE) | $(OUT_DIR)
	sudo rm -rf .acbuild
	sudo $(ACBUILD) --debug begin $(TARGET_IMAGE)
	sudo $(ACBUILD) environment add NGROK_REGION $*
	sudo $(ACBUILD) set-name $(NAME)-$*
	sudo $(ACBUILD) write --overwrite $@
	sudo $(ACBUILD) end

$(TARGET_IMAGE): $(BUILD_DIR)/acbuild $(BUILD_DIR)/rootfs.tar $(BUILD_DIR)/ngrok *.sh | $(OUT_DIR)
	sudo rm -rf .acbuild
	sudo $(ACBUILD) --debug begin ./build/rootfs.tar
	sudo $(ACBUILD) copy build/ngrok /usr/bin/ngrok
	sudo $(ACBUILD) environment add NGROK_REGION ""
	sudo $(ACBUILD) environment add TARGET_HOST ""
	sudo $(ACBUILD) environment add TARGET_PORT ""
	sudo $(ACBUILD) environment add NOTIFY_URL ""
	sudo $(ACBUILD) copy build/ngrok /usr/bin/ngrok
	sudo $(ACBUILD) copy ngrok2.conf /etc/ngrok2.conf
	sudo $(ACBUILD) copy-to-dir run.sh listen_for_url.sh notify.sh /opt/bin/
	sudo $(ACBUILD) set-name $(NAME)
	sudo $(ACBUILD) set-user 99
	sudo $(ACBUILD) set-group 99
	sudo $(ACBUILD) set-exec -- /opt/bin/run.sh
	sudo $(ACBUILD) write --overwrite $@
	sudo $(ACBUILD) end

$(OUT_DIR):
	mkdir -p dist

$(BUILD_DIR):
	mkdir -p build

$(BUILD_DIR)/rootfs.tar: build/buildroot
	cp buildroot.config build/buildroot/.config
	sh -c "cd build/buildroot && make -s"
	mv build/buildroot/output/images/rootfs.tar build/

$(BUILD_DIR)/buildroot: | $(BUILD_DIR)
	curl -sL https://buildroot.org/downloads/buildroot-${BUILDROOT_VERSION}.tar.gz | tar xz -C build
	mv build/buildroot-${BUILDROOT_VERSION} build/buildroot

$(BUILD_DIR)/acbuild: | $(BUILD_DIR)
	curl -sL https://github.com/appc/acbuild/releases/download/v${ACBUILD_VERSION}/acbuild-v${ACBUILD_VERSION}.tar.gz | tar xz -C build
	mv build/acbuild-v${ACBUILD_VERSION}/acbuild build/acbuild
	-rm -rf build/acbuild-v${ACBUILD_VERSION}

$(BUILD_DIR)/ngrok: | $(BUILD_DIR)
	curl -sL https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip > build/ngrok.zip
	unzip -d build build/ngrok.zip
	rm build/ngrok.zip

$(BUILD_DIR)/bats: | $(BUILD_DIR)
	curl -sL https://github.com/sstephenson/bats/archive/master.zip > build/bats.zip
	unzip -d build build/bats.zip
	mv build/bats-master build/bats
	rm build/bats.zip

$(BUILD_DIR)/rkt: | $(BUILD_DIR)
	curl -sL https://github.com/coreos/rkt/releases/download/v${RKT_VERSION}/rkt-v${RKT_VERSION}.tar.gz | tar xz -C build
	mv build/rkt-v${RKT_VERSION} build/rkt

test: $(BUILD_DIR)/bats $(BUILD_DIR)/rkt $(TARGET_IMAGE)
	sudo -v && echo "" && build/bats/bin/bats --pretty test

clean:
	-rm -rf $(BUILD_DIR) $(OUT_DIR)
