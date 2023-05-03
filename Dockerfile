FROM ubuntu:focal
ARG DEBIAN_FRONTEND=noninteractive

#PPA
RUN apt update
RUN apt install -y software-properties-common

#Essentials
RUN apt install -y build-essential git cmake

#GNU Radio
RUN add-apt-repository -y ppa:gnuradio/gnuradio-releases
RUN apt update
RUN apt install -y gnuradio python3-packaging

#gr-foo for the wireshark module
WORKDIR /app
RUN git clone https://github.com/bastibl/gr-foo.git
WORKDIR /app/gr-foo
RUN pwd
RUN mkdir build
RUN ls -l
WORKDIR /app/gr-foo/build
RUN pwd
RUN cmake ..
RUN make
RUN make install
RUN ldconfig

#gr-ieee802-15-4 for the PHY
WORKDIR /app
RUN git clone https://github.com/bastibl/gr-ieee802-15-4.git
WORKDIR /app/gr-ieee802-15-4
RUN pwd
RUN mkdir build
RUN ls -l
WORKDIR /app/gr-ieee802-15-4/build
RUN pwd
RUN cmake ..
RUN make
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

#the actual scripts
WORKDIR /app
COPY radio.py radio.py
COPY ieee802_15_4_oqpsk_phy.py ieee802_15_4_oqpsk_phy.py 
#CMD ["/bin/bash"]
#write output.pcap to a folder accesible from host
RUN mkdir /docker-volume
CMD ["./radio.py", "--filename", "/docker-volume/output.pcap"]
#todo persistency of output.pcap mount docker volume




