#!/usr/bin/env python3
# -*- coding: utf-8 -*-

#
# SPDX-License-Identifier: GPL-3.0
#
# GNU Radio Python Flow Graph
# Title: Sniffer Flow
# Description: IEEE 802.15.4 Radio RxFlow
# GNU Radio version: 3.10.5.1

import os
import sys
sys.path.append(os.environ.get('GRC_HIER_PATH', os.path.expanduser('~/.grc_gnuradio')))

from gnuradio import blocks
from gnuradio import gr
from gnuradio.filter import firdes
from gnuradio.fft import window
import signal
from argparse import ArgumentParser
from gnuradio.eng_arg import eng_float, intx
from gnuradio import eng_notation
from gnuradio import soapy
from ieee802_15_4_oqpsk_phy import ieee802_15_4_oqpsk_phy  # grc-generated hier_block
import foo




class radio(gr.top_block):

    def __init__(self, arguments='uri=ip:192.168.2.1', channel=11, device='plutosdr', filename='/tmp/sensors.pcap'):
        gr.top_block.__init__(self, "Sniffer Flow", catch_exceptions=True)

        ##################################################
        # Parameters
        ##################################################
        self.arguments = arguments
        self.channel = channel
        self.device = device
        self.filename = filename

        ##################################################
        # Variables
        ##################################################
        self.samp_rate = samp_rate = 4e6
        self.processor = processor = True
        self.freq = freq = 1000000 * (2400 + 5 * (channel - 10))

        ##################################################
        # Blocks
        ##################################################

        self.soapy_custom_source_0 = None
        dev = 'driver=' + device
        stream_args = ''
        tune_args = ['']
        settings = ['']
        self.soapy_custom_source_0 = soapy.source(dev, "fc32",
                                  1, arguments,
                                  stream_args, tune_args, settings)
        self.soapy_custom_source_0.set_sample_rate(0, samp_rate)
        self.soapy_custom_source_0.set_bandwidth(0, 0)
        self.soapy_custom_source_0.set_antenna(0, 'A_BALANCED')
        self.soapy_custom_source_0.set_frequency(0, freq)
        self.soapy_custom_source_0.set_frequency_correction(0, 0)
        self.soapy_custom_source_0.set_gain_mode(0, True)
        self.soapy_custom_source_0.set_gain(0, 10)
        self.soapy_custom_source_0.set_dc_offset_mode(0, False)
        self.soapy_custom_source_0.set_dc_offset(0, 0)
        self.soapy_custom_source_0.set_iq_balance(0, 0)
        self.ieee802_15_4_oqpsk_phy_0 = ieee802_15_4_oqpsk_phy()
        self.foo_wireshark_connector_0 = foo.wireshark_connector(195, False)
        self.blocks_null_sink_0 = blocks.null_sink(gr.sizeof_gr_complex*1)
        self.blocks_file_sink_0 = blocks.file_sink(gr.sizeof_char*1, filename, False)
        self.blocks_file_sink_0.set_unbuffered(False)


        ##################################################
        # Connections
        ##################################################
        self.msg_connect((self.ieee802_15_4_oqpsk_phy_0, 'rxout'), (self.foo_wireshark_connector_0, 'in'))
        self.connect((self.foo_wireshark_connector_0, 0), (self.blocks_file_sink_0, 0))
        self.connect((self.ieee802_15_4_oqpsk_phy_0, 0), (self.blocks_null_sink_0, 0))
        self.connect((self.soapy_custom_source_0, 0), (self.ieee802_15_4_oqpsk_phy_0, 0))


    def get_arguments(self):
        return self.arguments

    def set_arguments(self, arguments):
        self.arguments = arguments

    def get_channel(self):
        return self.channel

    def set_channel(self, channel):
        self.channel = channel
        self.set_freq(1000000 * (2400 + 5 * (self.channel - 10)))

    def get_device(self):
        return self.device

    def set_device(self, device):
        self.device = device

    def get_filename(self):
        return self.filename

    def set_filename(self, filename):
        self.filename = filename
        self.blocks_file_sink_0.open(self.filename)

    def get_samp_rate(self):
        return self.samp_rate

    def set_samp_rate(self, samp_rate):
        self.samp_rate = samp_rate

    def get_processor(self):
        return self.processor

    def set_processor(self, processor):
        self.processor = processor

    def get_freq(self):
        return self.freq

    def set_freq(self, freq):
        self.freq = freq
        self.soapy_custom_source_0.set_frequency(0, self.freq)



def argument_parser():
    description = 'IEEE 802.15.4 Radio RxFlow'
    parser = ArgumentParser(description=description)
    parser.add_argument(
        "--arguments", dest="arguments", type=str, default='uri=ip:192.168.2.1',
        help="Set arguments [default=%(default)r]")
    parser.add_argument(
        "--channel", dest="channel", type=intx, default=11,
        help="Set channel [default=%(default)r]")
    parser.add_argument(
        "--device", dest="device", type=str, default='plutosdr',
        help="Set device [default=%(default)r]")
    parser.add_argument(
        "--filename", dest="filename", type=str, default='/tmp/sensors.pcap',
        help="Set filename [default=%(default)r]")
    return parser


def main(top_block_cls=radio, options=None):
    if options is None:
        options = argument_parser().parse_args()
    if gr.enable_realtime_scheduling() != gr.RT_OK:
        print("Error: failed to enable real-time scheduling.")
    tb = top_block_cls(arguments=options.arguments, channel=options.channel, device=options.device, filename=options.filename)

    def sig_handler(sig=None, frame=None):
        tb.stop()
        tb.wait()

        sys.exit(0)

    signal.signal(signal.SIGINT, sig_handler)
    signal.signal(signal.SIGTERM, sig_handler)

    tb.start()

    try:
        input('Press Enter to quit: ')
    except EOFError:
        pass
    tb.stop()
    tb.wait()


if __name__ == '__main__':
    main()
