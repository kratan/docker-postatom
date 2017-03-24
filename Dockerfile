FROM nvidia/cuda:8.0-runtime-ubuntu16.04 
LABEL maintainer "NVIDIA CORPORATION <cudatools@nvidia.com>, andreas.kratzer@kit.edu" 

RUN apt-get update && apt-get install -y --no-install-recommends \ 
	cuda-core-$CUDA_PKG_VERSION \ 
	cuda-misc-headers-$CUDA_PKG_VERSION \ 
	cuda-command-line-tools-$CUDA_PKG_VERSION \ 
	cuda-nvrtc-dev-$CUDA_PKG_VERSION \ 
	cuda-nvml-dev-$CUDA_PKG_VERSION \ 
	cuda-nvgraph-dev-$CUDA_PKG_VERSION \ 
	cuda-cusolver-dev-$CUDA_PKG_VERSION \ 
	cuda-cublas-dev-$CUDA_PKG_VERSION \ 
	cuda-cufft-dev-$CUDA_PKG_VERSION \ 
	cuda-curand-dev-$CUDA_PKG_VERSION \ 
	cuda-cusparse-dev-$CUDA_PKG_VERSION \ 
	cuda-npp-dev-$CUDA_PKG_VERSION \ 
	cuda-cudart-dev-$CUDA_PKG_VERSION \ 
	cuda-driver-dev-$CUDA_PKG_VERSION && \ 
	rm -rf /var/lib/apt/lists/* 

ENV LIBRARY_PATH /usr/local/cuda/lib64/stubs:${LIBRARY_PATH}

#Non interactive stuff
ENV DEBIAN_FRONTEND noninteractive
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

#Prevent initramfs from trying to do bootloader stuff
ENV INITRD no

ENV NVIDIA_VER 375.39
ENV NVIDIA_INSTALL http://us.download.nvidia.com/XFree86/Linux-x86_64/${NVIDIA_VER}/NVIDIA-Linux-x86_64-${NVIDIA_VER}.run

ENV VGL_VER 2.5.2
ENV VGL_INSTALL https://netcologne.dl.sourceforge.net/project/virtualgl/${VGL_VER}/virtualgl_${VGL_VER}_amd64.deb


# Install main Stuff
RUN apt-get update  && apt install --no-install-recommends -y x-window-system \
        binutils \
        mesa-utils \
        module-init-tools \
        mesa-utils \
	git \
	gnupg2 \
	build-essential \
	curl \
#	openssh-server \
	pkg-config \
	ca-certificates \
	python-cryptography \
	python-netifaces
	

#Get xpra latest
RUN curl https://winswitch.org/gpg.asc | apt-key add - \
    && echo "deb http://winswitch.org/ xenial main" > /etc/apt/sources.list.d/winswitch.list \
    && apt-get update 

#Spielwiese specified
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

#Install virtualgl
RUN curl -o /tmp/virtualgl.deb ${VGL_INSTALL} \
	&& dpkg -i /tmp/virtualgl.deb \
	&& rm -f /tmp/virtualgl.deb


#Add nvidia driver to current image
RUN curl -o /tmp/NVIDIA-Linux-x86_64-${NVIDIA_DRIVER}.run ${NVIDIA_INSTALL} \
	&& sh /tmp/NVIDIA-Linux-x86_64-${NVIDIA_DRIVER}.run -a -N --ui=none --no-kernel-module


#Get postAtom from bit
RUN git clone https://bitbucket.org/TobiasRp/spielwiese.git postAtom
RUN mkdir -p /postAtom/build
WORKDIR "/postAtom/build"
RUN cmake -DCMAKE_BUILD_TYPE=Release .. && make -i && make clean && make && mv /postAtom/build/postAtom .. && rm -Rf /postAtom/build/*


# Create the directory needed to run the dbus daemon and Xpra
RUN mkdir /var/run/dbus && mkdir /var/run/xpra && chown -R root:xpra /var/run/xpra && chmod 0775 -R /var/run/xpra


#cleanup
RUN apt-get clean -y && \
	apt-get autoclean -y && \
	apt-get autoremove -y && \
	rm -rf /usr/share/locale/* && \
	rm -rf /var/cache/debconf/*-old && \
	rm -rf /var/lib/apt/lists/* && \
	rm -rf /usr/share/doc/* && \
	rm -rf /tmp/*

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR "/postAtom"


CMD ["/entrypoint.sh"]
