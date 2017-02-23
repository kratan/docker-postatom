FROM ubuntu:yakkety-20170104

#Non interactive stuff
ENV DEBIAN_FRONTEND noninteractive
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

#Prevent initramfs from trying to do bootloader stuff
ENV INITRD no

ENV NVIDIA_DRIVER 378.13
ENV NVIDIA_INSTALL http://us.download.nvidia.com/XFree86/Linux-x86_64/${NVIDIA_DRIVER}/NVIDIA-Linux-x86_64-${NVIDIA_DRIVER}.run


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
	supervisor \
	pkg-config \
	ca-certificates 
	

#Get xpra latest
RUN curl https://winswitch.org/gpg.asc | apt-key add - \
    && echo "deb http://winswitch.org/ yakkety main" > /etc/apt/sources.list.d/winswitch.list \
    && apt-get update

#Spielwiese specified
RUN apt-get install --no-install-recommends -y libhdf5-dev \
        liblz4-dev \
        qt5-default \
	libqt5opengl5-dev \	
	cmake \
	xpra \
	python-dbus \
	dbus

#Install virtualgl
#RUN curl -o /tmp/virtualgl.deb  https://kent.dl.sourceforge.net/project/virtualgl/2.5.1/virtualgl_2.5.1_amd64.deb \
#		&& dpkg -i /tmp/virtualgl.deb \
#		&& rm -f /tmp/virtualgl.deb


#Add nvidia driver to current image
RUN curl -o /tmp/NVIDIA-Linux-x86_64-${NVIDIA_DRIVER}.run ${NVIDIA_INSTALL}
RUN sh /tmp/NVIDIA-Linux-x86_64-${NVIDIA_DRIVER}.run -a -N --ui=none --no-kernel-module


#Run Xorg to make an working conf
RUN rm -f /root/*

#Copy Supervisord.conf and xorg conf (with BUSID !!) to container
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY xorg.conf /etc/X11/xorg.conf

#get spielwiese from bit
WORKDIR "/"
RUN git clone https://bitbucket.org/TobiasRp/spielwiese.git
WORKDIR "/spielwiese"
RUN mkdir build
WORKDIR "/spielwiese/build"
RUN cmake -DCMAKE_BUILD_TYPE=Release .. && make
RUN mv postAtom ..
RUN rm -Rf /spielwiese/build/*

# Create the directory needed to run the dbus daemon 
RUN mkdir /var/run/dbus


#cleanup
RUN apt-get clean -y && \
	apt-get autoclean -y && \
	apt-get autoremove -y && \
	rm -rf /usr/share/locale/* && \
	rm -rf /var/cache/debconf/*-old && \
	rm -rf /var/lib/apt/lists/* && \
	rm -rf /usr/share/doc/* && \
	rm -rf /tmp/*



WORKDIR "/spielwiese"

EXPOSE 10000
CMD ["/usr/bin/supervisord"]
