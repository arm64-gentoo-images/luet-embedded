FROM quay.io/necrose99/funtoo-arm64
WORKDIR /

ADD https://raw.githubusercontent.com/necrose99/arm64-portage/master/repos.conf/sabayon-repos.conf /etc/repos.conf/
#
ADD https://raw.githubusercontent.com/necrose99/arm64-portage/master/repos.conf/pentoo.conf /etc/repos.conf/
# sabayon and mudlers dev-ops.. 
ADD https://raw.githubusercontent.com/necrose99/arm64-portage/master/repos.conf/mottainai.conf /etc/repos.conf/
#
# sakaki's tools. 
ADD https://raw.githubusercontent.com/necrose99/arm64-portage/master/repos.conf/sakaki-tools.conf  /etc/repos.conf/
ADD https://raw.githubusercontent.com/necrose99/arm64-portage/master/repos.conf/genpi64.conf  /etc/repos.conf/
## stuff for pinebook pro/rock64 
ADD https://raw.githubusercontent.com/necrose99/arm64-portage/master/repos.conf/pinebookpro-overlay.conf  /etc/repos.conf/


# emu kit. '
ADD https://github.com/arm64-gentoo-images/funtoo-base-arm64/raw/main/do-repos/bin.tar.xz /usr/bin/
## qemu lutris resin/balena xbuild recompiled for arm64. 

# test cmd. 
ENTRYPOINT  [ "/usr/bin/qemu-aarch64-static", "/bin/sh", "-c", "ln -s resin-xbuild /usr/bin/cross-build-start; ln -s resin-xbuild /usr/bin/cross-build-end; ln /bin/sh /bin/sh.real" ]
# RUN ego sync && emerge dev-util/mottainai-agent  dev-util/mottainai-cli dev-util/mottainai-server  dev-util/replicant dev-util/simplestreams-builder 
