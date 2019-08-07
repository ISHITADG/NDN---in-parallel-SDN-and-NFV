#!/usr/local/bin/python
"""
Author:            Parikshit Juluri
Contact:           pjuluri@umkc.edu
Testing:
    import dash_client
    mpd_file = <MPD_FILE>
    dash_client.playback_duration(mpd_file, 'http://198.248.242.16:8005/')
    From commandline:
    python dash_client.py -m "http://198.248.242.16:8006/media/mpd/x4ukwHdACDw.mpd" -p "all"
    python dash_client.py -m "http://127.0.0.1:8000/media/mpd/x4ukwHdACDw.mpd" -p "basic"
"""
from __future__ import division
import read_mpd
import urlparse
import urllib2
import subprocess
from subprocess import Popen, PIPE
import urllib3
import Queue
from urllib3 import HTTPConnectionPool
from contextlib import closing
import io
import httplib2
import urlparse
import random
import os
import csv
import sys
import errno
import timeit
from string import ascii_letters, digits
from argparse import ArgumentParser
from collections import defaultdict
from adaptation import basic_dash, basic_dash2, weighted_dash, netflix_dash, dash_bola
from adaptation.adaptation import WeightedMean
import config_dash
import dash_buffer
import requests
from configure_log_file import configure_log_file, write_json
import time
from threading import Thread
import threading
#from multiprocessing import Lock, Process, Queue
import multiprocessing
#from pathos.multiprocessing import ProcessingPool as Pool


try:
    WindowsError
except NameError:
    from shutil import WindowsError


# Constants
DEFAULT_PLAYBACK = 'BASIC'
DOWNLOAD_CHUNK = 15000
BUFFER_THRESHOLD_UPPER = 0.6
BUFFER_THRESHOLD_LOWER = 0.4
RETRANS_THRESHOLD_UPPER = 0.6
RETRANS_THRESHOLD_LOWER = 0.4

# Globals for arg parser with the default values
# Not sure if this is the correct way ....
MPD = None
LIST = False
PLAYBACK = DEFAULT_PLAYBACK
DOWNLOAD = False
SEGMENT_LIMIT = None

connection = requests.Session()
bola_buffer_log_file = config_dash.BOLA_BUFFER_LOG_FILENAME

class BOLAObject(object):
    """Object to handel audio and video stream """
    def __init__(self):
        self.state = config_dash.BOLA_STATE_STARTUP
        self.utility = list()
        self.Vp = 0.0
        self.gp = 0.0
        self.bandwidthSafetyFactor = 0.0
        self.safetyGuarantee = False
        self.virtualBuffer = 0
        self.throughputCount=0
        self.bitrates = list()
        self.video_segment_duration=0
        self.bolaBufferTarget=0
        self.bufferMax=0
        self.bufferTarget=0
        self.vid_length=0
        self.lastQuality=0
        self.bufferlen = 0.0
        

class DashPlayback:
    """
    Audio[bandwidth] : {duration, url_list}
    Video[bandwidth] : {duration, url_list}
    """
    def __init__(self):

        self.min_buffer_time = None
        self.playback_duration = None
        self.audio = dict()
        self.video = dict()


def get_mpd(url):
    """ Module to download the MPD from the URL and save it to file"""
    global connection

    quic_cmd="/ndnperf/c++/client/bin/ndnperf -p ndn:/edu/umass -d "+url+" -w 16"
    config_dash.LOG.info(quic_cmd)
    log = open('out.txt', 'w')
    log.flush()
    proc = Popen(quic_cmd, stdout=log, stderr=log, shell=True)
    mpd_file = url.split('/')[-1]

    #mpd_file_handle = open(mpd_file, 'wb')
    #mpd_file_handle.writelines(stream[:len(stream)])
    #mpd_file_handle.close()
    #mpd_conn.close()
    #mpd_conn.release_conn()
    #config_dash.LOG.info(mpd_conn.data)
    config_dash.LOG.info("Downloaded the MPD file {}".format(mpd_file))
    return mpd_file

def get_bandwidth(data, duration):
    """ Module to determine the bandwidth for a segment
    download"""
    return data * 8/duration


def get_domain_name(url):
    """ Module to obtain the domain name from the URL
        From : http://stackoverflow.com/questions/9626535/get-domain-name-from-url
    """
    parsed_uri = urlparse.urlparse(url)
    domain = '{uri.scheme}://{uri.netloc}/'.format(uri=parsed_uri)
    return domain


def id_generator(id_size=6):
    """ Module to create a random string with uppercase 
        and digits.
    """
    return 'TEMP_' + ''.join(random.choice(ascii_letters+digits) for _ in range(id_size))


def make_sure_path_exists(path):
    """ Module to make sure the path exists if not create it
    """
    try:
        os.makedirs(path)
    except OSError as exception:
        if exception.errno != errno.EEXIST:
            raise


def print_representations(dp_object):
    """ Module to print the representations"""
    print "The DASH media has the following video representations/bitrates"
    for bandwidth in dp_object.video:
        print bandwidth



def clean_files(folder_path):
    """
    :param folder_path: Local Folder to be deleted
    """
    if os.path.exists(folder_path):
        try:
            for video_file in os.listdir(folder_path):
                file_path = os.path.join(folder_path, video_file)
                if os.path.isfile(file_path):
                    os.unlink(file_path)
            os.rmdir(folder_path)
        except (WindowsError, OSError), e:
            config_dash.LOG.info("Unable to delete the folder {}. {}".format(folder_path, e))
        config_dash.LOG.info("Deleted the folder '{}' and its contents".format(folder_path))


def create_arguments(parser):
    """ Adding arguments to the parser """
    parser.add_argument('-m', '--MPD',                   
                        help="Url to the MPD File")
    parser.add_argument('-l', '--LIST', action='store_true',
                        help="List all the representations")
    parser.add_argument('-p', '--PLAYBACK',
                        default=DEFAULT_PLAYBACK,
                        help="Playback type (basic, sara, netflix, or all)")
    parser.add_argument('-n', '--SEGMENT_LIMIT',
                        default=SEGMENT_LIMIT,
                        help="The Segment number limit")
    parser.add_argument('-d', '--DOWNLOAD', action='store_true',
                        default=False,
                        help="Keep the video files after playback")
    parser.add_argument('-r', '--RETRANS', action='store_true',
                        default=False,
                        help="enable retransmission")


def main():
    """ Main Program wrapper """
    # configure the log file
    # Create arguments
    parser = ArgumentParser(description='Process Client parameters')
    create_arguments(parser)
    args = parser.parse_args()
    globals().update(vars(args))
    configure_log_file(playback_type=PLAYBACK.lower())
    config_dash.JSON_HANDLE['playback_type'] = PLAYBACK.lower()
    if not MPD:
        print "ERROR: Please provide the URL to the MPD file. Try Again.."
        return None
    config_dash.LOG.info('Downloading MPD file %s' % MPD)
    # Retrieve the MPD files for the video
    mpd_file = get_mpd(MPD)
    domain = get_domain_name(MPD)
    dp_object = DashPlayback()
    # Reading the MPD file created
    dp_object, video_segment_duration = read_mpd.read_mpd(mpd_file, dp_object)
    config_dash.LOG.info("The DASH media has %d video representations" % len(dp_object.video))
    

if __name__ == "__main__":
    sys.exit(main())
