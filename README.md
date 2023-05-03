# Gnuradio + soapy docker
This repo contains a [Dockerfile](Dockerfile) that builds a Gnuradio image with SoapySDR support.
Included is a sample script `radio.py` that can sniff Zigbee traffic. To check the source code of the script open the grc in gnu radio companion.
[ieee802_15_4_oqpsk_ph.py](ieee802_15_4_oqpsk_phy.py) is provided by the excelent [gr-ieee802-15-4](https://github.com/bastibl/gr-ieee802-15-4) and is used to decode the Zigbee traffic (its under examples).

## Usage
### Build
```bash
docker build -t gnuradio-soapy .
```

### Run
To run the sample script:
```bash
docker run --rm -it gnuradio-soapy
```
Using the default params in the `radio.py`

If you want to use a different driver you can pass the `--device` flag to the script:
```bash
docker run --rm -it gnuradio-soapy ./radio.py --device=hackrf
```

#### Included drivers
```bash
######################################################
##     Soapy SDR -- the SDR abstraction library     ##
######################################################

Lib Version: v0.7.2-1
API Version: v0.7.1
ABI Version: v0.7
Install root: /usr
Search path:  /usr/lib/x86_64-linux-gnu/SoapySDR/modules0.7
Search path:  /usr/local/lib/x86_64-linux-gnu/SoapySDR/modules0.7                (missing)
Search path:  /usr/local/lib/SoapySDR/modules0.7
Module found: /usr/lib/x86_64-linux-gnu/SoapySDR/modules0.7/libHackRFSupport.so  (0.3.3)
Module found: /usr/lib/x86_64-linux-gnu/SoapySDR/modules0.7/libLMS7Support.so    (20.01.0)
Module found: /usr/lib/x86_64-linux-gnu/SoapySDR/modules0.7/libRedPitaya.so      (0.1.1)
Module found: /usr/lib/x86_64-linux-gnu/SoapySDR/modules0.7/libairspySupport.so  (0.1.2)
Module found: /usr/lib/x86_64-linux-gnu/SoapySDR/modules0.7/libaudioSupport.so   (0.1.1)
Module found: /usr/lib/x86_64-linux-gnu/SoapySDR/modules0.7/libbladeRFSupport.so (0.4.1)
Module found: /usr/lib/x86_64-linux-gnu/SoapySDR/modules0.7/libosmosdrSupport.so (0.2.5)
Module found: /usr/lib/x86_64-linux-gnu/SoapySDR/modules0.7/libremoteSupport.so  (0.5.1)
Module found: /usr/lib/x86_64-linux-gnu/SoapySDR/modules0.7/librtlsdrSupport.so  (0.3.0)
Module found: /usr/lib/x86_64-linux-gnu/SoapySDR/modules0.7/libuhdSupport.so     (0.3.6)
Module found: /usr/local/lib/SoapySDR/modules0.7/libPlutoSDRSupport.so           (0.2.1-a07c372)
Available factories... airspy, audio, bladerf, hackrf, lime, osmosdr, plutosdr, redpitaya, remote, rtlsdr, uhd
Available converters...
 -  CF32 -> [CF32, CS16, CS8, CU16, CU8]
 -  CS16 -> [CF32, CS16, CS8, CU16, CU8]
 -  CS32 -> [CS32]
 -   CS8 -> [CF32, CS16, CS8, CU16, CU8]
 -  CU16 -> [CF32, CS16, CS8]
 -   CU8 -> [CF32, CS16, CS8]
 -   F32 -> [F32, S16, S8, U16, U8]
 -   S16 -> [F32, S16, S8, U16, U8]
 -   S32 -> [S32]
 -    S8 -> [F32, S16, S8, U16, U8]
 -   U16 -> [F32, S16, S8]
 -    U8 -> [F32, S16, S8]
```

If you want to use the docker container with an SDR that does not provide a network interface you should run the docker container in priviliged mode:
```bash
docker run --rm -it --privileged gnuradio-soapy
```

## Zigbee sniffing
```bash
./radio.py --help
usage: radio.py [-h] [--arguments ARGUMENTS] [--channel CHANNEL] [--device DEVICE] [--filename FILENAME]

IEEE 802.15.4 Radio RxFlow

optional arguments:
  -h, --help            show this help message and exit
  --arguments ARGUMENTS
                        Set arguments [default='uri=ip:192.168.2.1']
  --channel CHANNEL     Set channel [default=11]
  --device DEVICE       Set device [default='plutosdr']
  --filename FILENAME   Set filename [default='/tmp/sensors.pcap']

```

If you want to open the pcap file in wireshark you need to get it out of your container. You can do this by mounting a volume:
```bash
docker run --rm -it --privileged -v /tmp:/docker-volume gnuradio-soapy
```


## Todo
- [ ] Add persistence to the container (output.pcap)
- [ ] Split up the repo in the radio.py script and dockerfile
- [ ] Figure out a way to build the ieee802_15_4_OQPSK_PHY.grc from the gr-ieee802-15-4 repo in the dockerfile. Gnuradio doesn't have the `--compile` flag anymore. Maybe we can use the `grcc` command? and make it part of the build process?

