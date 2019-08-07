#!/usr/local/bin/python
from subprocess import Popen, PIPE

quic_cmd="ndnping /edu/umass -c 10"
log = open('out.txt', 'w')
log.flush()
proc = Popen(quic_cmd, stdout=log, stderr=log, shell=True)
