FROM debian:bookworm
ARG DEBIAN_FRONTEND=noninteractive

#Essentials
RUN apt update
RUN apt install -y build-essential git cmake
RUN apt install -y gnuradio python3-packaging

#gr-foo for the wireshark module
WORKDIR /app
RUN git clone https://github.com/bastibl/gr-foo.git
WORKDIR /app/gr-foo
RUN git checkout maint-3.10
RUN pwd
RUN mkdir build
RUN ls -l
WORKDIR /app/gr-foo/build
RUN pwd
RUN cmake ..
RUN make -j4
RUN make install
RUN ldconfig

#gr-ieee802-15-4 for the PHY
WORKDIR /app
RUN git clone https://github.com/bastibl/gr-ieee802-15-4.git
WORKDIR /app/gr-ieee802-15-4
RUN git checkout maint-3.10
RUN pwd
RUN mkdir build
RUN ls -l
WORKDIR /app/gr-ieee802-15-4/build
RUN pwd
RUN cmake ..
RUN make -j4
RUN make install
RUN ldconfig

WORKDIR /app
RUN apt install -y cmake g++ libpython3-dev python3-numpy swig
RUN apt install -y soapysdr-module-all libsoapysdr-dev python3-distutils python3-apt
#maybe better as we dont need to build?
#RUN git clone https://github.com/pothosware/SoapySDR.git
#WORKDIR /app/SoapySDR
#RUN mkdir build
#WORKDIR /app/SoapySDR/build
#RUN cmake ..
#RUN make -j4
#RUN make install
#RUN ldconfig #needed on debian systems
#RUN SoapySDRUtil --info

#Pluto driver
WORKDIR /app
RUN apt install -y libiio-dev libad9361-dev libusb-1.0-0-dev 
RUN git clone https://github.com/pothosware/SoapyPlutoSDR.git
WORKDIR /app/SoapyPlutoSDR
RUN mkdir build
WORKDIR /app/SoapyPlutoSDR/build
RUN cmake ..
RUN make -j4
RUN make install
RUN ldconfig #needed on debian systems
RUN SoapySDRUtil --info

#setup user to run gnuradio
RUN useradd --create-home --shell /bin/bash -G sudo gnuradio
RUN echo 'gnuradio:gnuradio' | chpasswd

#fix permissions
RUN find /app -type d -exec chmod g+rwx {} +

# else it will output an error about Gtk namespace not found
RUN apt install -y gir1.2-gtk-3.0 sudo

USER gnuradio

WORKDIR /home/gnuradio
RUN grcc /app/gr-ieee802-15-4/examples/ieee802_15_4_OQPSK_PHY.grc -u #the actual phy needed for our radio.grc flowgraph

#the actual scripts
COPY radio.grc radio.grc
RUN grcc radio.grc #build the graph

COPY entrypoint.sh entrypoint.sh
USER root

#fix permissions
RUN find /home/gnuradio -type d,f -exec chown -R gnuradio:gnuradio {} +

USER gnuradio
ENTRYPOINT ["/bin/sh", "entrypoint.sh"]

CMD ["./radio.py", "--filename", "/home/gnuradio/persistent/output.pcap"]




