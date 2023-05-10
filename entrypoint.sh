#!/bin/sh

sudo chown -R gnuradio:gnuradio /home/gnuradio/persistent
exec "$@"
