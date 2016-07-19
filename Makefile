.DEFAULT_GOAL := dist/dit4c-helper-listener-ngrok2-CHECKSUM

CLIENT_INSTALLER_URL=https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip
BUILDROOT_VERSION=2016.05
ACBUILD_VERSION=0.3.1
DOCKER2ACI_VERSION=0.12.0
ACBUILD=build/acbuild
NGROK_REGIONS=ap au eu us
IMAGES=$(foreach region, $(NGROK_REGIONS), dist/dit4c-helper-listener-ngrok2-$(region).linux.amd64.aci)

dist/dit4c-helper-listener-ngrok2-CHECKSUM: dist/dit4c-helper-listener-ngrok2.linux.amd64.aci $(IMAGES)
	sha512sum --tag $^ | sed -e 's/dist\///' > dist/dit4c-helper-listener-ngrok2-CHECKSUM

dist/dit4c-helper-listener-ngrok2-%.linux.amd64.aci: dist/dit4c-helper-listener-ngrok2.linux.amd64.aci
	rm -rf .acbuild
	$(ACBUILD) --debug begin ./dist/dit4c-helper-listener-ngrok2.linux.amd64.aci
	$(ACBUILD) environment add NGROK_REGION $*
	$(ACBUILD) set-name dit4c-helper-listener-ngrok2-$*
	$(ACBUILD) write --overwrite dist/dit4c-helper-listener-ngrok2-$*.linux.amd64.aci
	$(ACBUILD) end

dist/dit4c-helper-listener-ngrok2.linux.amd64.aci: build/acbuild build/rootfs.tar build/ngrok | dist
	rm -rf .acbuild
	$(ACBUILD) --debug begin ./build/rootfs.tar
	$(ACBUILD) copy build/ngrok /usr/bin/ngrok
	$(ACBUILD) copy jwt /usr/bin/jwt
	$(ACBUILD) environment add DIT4C_INSTANCE_PRIVATE_KEY ""
	$(ACBUILD) environment add DIT4C_INSTANCE_JWT_KID ""
	$(ACBUILD) environment add DIT4C_INSTANCE_JWT_ISS ""
	$(ACBUILD) environment add DIT4C_INSTANCE_HELPER_AUTH_HOST ""
	$(ACBUILD) environment add DIT4C_INSTANCE_HELPER_AUTH_PORT ""
	$(ACBUILD) environment add NGROK_REGION ""
	$(ACBUILD) copy build/ngrok /usr/bin/ngrok
	$(ACBUILD) copy ngrok2.conf /etc/ngrok2.conf
	$(ACBUILD) copy run.sh /opt/bin/run.sh
	$(ACBUILD) copy listen_for_url.sh /opt/bin/listen_for_url.sh
	$(ACBUILD) copy notify_portal.sh /opt/bin/notify_portal.sh
	$(ACBUILD) set-name dit4c-helper-listener-ngrok2
	$(ACBUILD) set-user nobody
	$(ACBUILD) set-group nobody
	$(ACBUILD) set-exec -- /opt/bin/run.sh
	$(ACBUILD) write --overwrite dist/dit4c-helper-listener-ngrok2.linux.amd64.aci
	$(ACBUILD) end

dist:
	mkdir -p dist

build:
	mkdir -p build

build/rootfs.tar: build/buildroot
	cp buildroot.config build/buildroot/.config
	sh -c "cd build/buildroot && make -s"
	mv build/buildroot/output/images/rootfs.tar build/

build/buildroot: | build
	curl -sL https://buildroot.org/downloads/buildroot-${BUILDROOT_VERSION}.tar.gz | tar xz -C build
	mv build/buildroot-${BUILDROOT_VERSION} build/buildroot

build/acbuild: | build
	curl -sL https://github.com/appc/acbuild/releases/download/v${ACBUILD_VERSION}/acbuild-v${ACBUILD_VERSION}.tar.gz | tar xz -C build
	mv build/acbuild-v${ACBUILD_VERSION}/acbuild build/acbuild
	rm -rf build/acbuild-v${ACBUILD_VERSION}

build/ngrok: | build
	curl -sL https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip > build/ngrok.zip
	unzip -d build build/ngrok.zip
	rm build/ngrok.zip

clean:
	-rm -rf build .acbuild dist
