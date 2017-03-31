FROM ubuntu:xenial-20170214 
LABEL maintainer="andreas.kratzer@kit.edu"
 

#Environmental Stuff
ENV DEBIAN_FRONTEND=noninteractive 
ENV INITRD=no PATH=/usr/local/cuda/bin:${PATH}

ENV NVIDIA_VER=375.39 
ENV NVIDIA_INSTALL=http://us.download.nvidia.com/XFree86/Linux-x86_64/${NVIDIA_VER}/NVIDIA-Linux-x86_64-${NVIDIA_VER}.run

# Install main Stuff
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections \
    && apt-get update \
    && apt install --no-install-recommends -y x-window-system \
	binutils \
	mesa-utils \
        module-init-tools \
	git \
	gnupg2 \
	build-essential \
	curl \
	pkg-config \
	ca-certificates \
	python-netifaces \
	wget
	

#Get xpra latest
RUN curl https://winswitch.org/gpg.asc | apt-key add - \
	&& echo "deb http://winswitch.org/beta/ xenial main" > /etc/apt/sources.list.d/winswitch.list \
	&& echo "deb http://winswitch.org/ xenial main" > /etc/apt/sources.list.d/winswitch.list \
	&& apt-get update \
	&& apt-get upgrade --no-install-recommends -y
	

#PostAtom specified
RUN apt-get install --no-install-recommends -y libhdf5-dev \
        liblz4-dev \
        qt5-default \
	libqt5opengl5-dev \	
	cmake \
	xpra \
	websockify \
	python-dbus \
	dbus \
	dbus-x11


#Add nvidia driver to current image
RUN echo /tmp/NVIDIA-Linux-x86_64-${NVIDIA_DRIVER}.run ${NVIDIA_INSTALL}
RUN curl -o /tmp/NVIDIA-Linux-x86_64-${NVIDIA_DRIVER}.run ${NVIDIA_INSTALL} \
	&& sh /tmp/NVIDIA-Linux-x86_64-${NVIDIA_DRIVER}.run -a -N --ui=none --no-kernel-module


#Get postAtom from bit
RUN git clone https://bitbucket.org/TobiasRp/spielwiese.git postAtom
RUN mkdir -p /postAtom/build
WORKDIR "/postAtom/build"
RUN cmake -DCMAKE_BUILD_TYPE=Release .. \
	&& make -i && make clean \
	&& make \
	&& mv /postAtom/build/postAtom .. \
	&& rm -Rf /postAtom/build/*


# Create the directory needed to run the dbus daemon and Xpra
RUN mkdir /var/run/dbus && mkdir /var/run/xpra \
	&& chown -R root:xpra /var/run/xpra && chmod 0775 -R /var/run/xpra


#cleanup
RUN apt-get clean -y \
	&& apt-get autoclean -y \
	&& apt-get autoremove -y \
	&& rm -rf /usr/share/locale/*  \
	&& rm -rf /var/cache/debconf/*-old \
	&& rm -rf /var/lib/apt/lists/* \
	&& rm -rf /usr/share/doc/* \
	rm -rf /tmp/*

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR "/postAtom/build"

CMD ["/entrypoint.sh"]
