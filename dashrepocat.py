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
    print("ishita: url: "+url)
    quic_cmd="ndncatchunks -qTD /edu/umass/"+url+" > "+url
    #quic_cmd="python3 ../../../getfile.py -r bigbuckbunny -n /edu/umass/"+url
    config_dash.LOG.info(quic_cmd)
    stream=subprocess.Popen(quic_cmd, shell=True, stdin=None, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    out,err=stream.communicate()
    #config_dash.LOG.info(url+" :NDNCAT OUTPUT:\n"+out)
    #config_dash.LOG.info(url+" :NDNCAT ERROR:\n"+err)
    #stream=os.popen(quic_cmd)
    mpd_file = url.split('/')[-1]
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

def download_segment_bola(domain, dp_list, segment_number, segment_url, dash_folder, bolaObj, dash_player, last_requests_tput, start_time, seg_sizes):
                    """ Module to download the segment """
    		    abandonReq=False
    		    parsed_uri = urlparse.urlparse(segment_url)
                    segment_path = '{uri.path}'.format(uri=parsed_uri)
                    config_dash.LOG.info(segment_path)
		    while segment_path.startswith('/'):
        		segment_path = segment_path[1:]        
    		    segment_filename = os.path.join(dash_folder, os.path.basename(segment_path))
    		    make_sure_path_exists(os.path.dirname(segment_filename))
    #segment_file_handle = open(segment_filename, 'wb')
                    chunk_dl_rates = []
                    segment_size = 0
    		    '''
    try:
        #print segment_url
        total_data_dl_time = 0
        
        chunk_number = 0
        chunk_start_time = timeit.default_timer()
        with closing(connection.get(segment_url, stream=True)) as seg_conn:
            with open(segment_filename,'wb') as segment_file_handle:
                for segment_data in seg_conn.iter_content(DOWNLOAD_CHUNK):
                    if segment_data is None:
                        break
                    segment_file_handle.write(segment_data)
                    segment_size += len(segment_data)
                    if len(segment_data) < DOWNLOAD_CHUNK:
                        timenow = timeit.default_timer()
                        chunk_dl_time = timenow - chunk_start_time
                        chunk_number += 1
                        total_data_dl_time += chunk_dl_time
                        current_chunk_dl_rate = segment_size * 8 / total_data_dl_time
                        chunk_dl_rates.append(current_chunk_dl_rate)
                        with open('chunk-test.txt', 'a') as chk:
                            chk.write("%s\n" % chunk_dl_rates)
                        #print chunk_dl_rates
                        #print "-----------------"
                        #print segment_w_chunks
                        #print "!!!!!!!!!!!!!!!!!"
                        #segment_w_chunks.append(chunk_dl_rates)
                        #print segment_w_chunks
                        #print "##################"
                        break
                    
                    
                    timenow = timeit.default_timer()
                    chunk_dl_time = timenow - chunk_start_time
                    total_data_dl_time += chunk_dl_time
                    current_chunk_dl_rate = segment_size * 8 / total_data_dl_time
                    chunk_start_time = timenow
                    chunk_number += 1
                    chunk_dl_rates.append(current_chunk_dl_rate)
                    bolaObj.bufferlen=((segment_size * 8)/seg_sizes[bolaObj.lastQuality])
                    #config_dash.LOG.info("Start_Abandonment_Logic")
                    start_abandon = timeit.default_timer()
                    '''             
                    
		    segment_url=segment_url.strip("://")
                    config_dash.LOG.info("ishita checks segment_url"+segment_url)
                    #quic_cmd="python3 ../../../getfile.py -r bigbuckbunny -n /edu/umass/"+segment_url
                    segmentname=os.path.basename(segment_url)
                    quic_cmd="ndncatchunks -vTD /edu/umass/"+segment_url+" > "+segmentname+" 2>eror"
                    config_dash.LOG.info("Starting system call for"+segment_url)
                    chunk_start_time = timeit.default_timer()
                    #stream=os.system(quic_cmd)
                    streams=subprocess.Popen(quic_cmd, shell=True, stdin=None, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
                    outs,errs=streams.communicate()
                    timenow = timeit.default_timer()
                    #config_dash.LOG.info(segmentname+" :NDNCAT OUTPUT:\n"+out)
                    #config_dash.LOG.info(segmentname+" :NDNCAT ERROR:\n"+err)
                    config_dash.LOG.info("Ending system call for"+segmentname)
                    chunk_dl_time = timenow - chunk_start_time
                    segment_filename=segment_url.split('/')[-1]
                    #segment_file_handle = open(segment_filename, 'wb')
                    segment_size+=os.stat(segment_filename).st_size
                    config_dash.LOG.info(segment_size)
                    #segment_file_handle.write(stream)

                    #segment_file_handle.close()
                    current_chunk_dl_rate = segment_size * 8 / chunk_dl_time
                    chunk_dl_rates.append(current_chunk_dl_rate)

                    segment_w_chunks.append(chunk_dl_rates)
                    '''
                    abandonReq, bolaObj = dash_bola.bola_abandon(dash_player.buffer.__len__(), current_chunk_dl_rate, last_requests_tput, bolaObj, chunk_start_time, timenow, segment_size, seg_sizes, chunk_dl_time)
                    #config_dash.LOG.info("Abandonment_Exec_Time %f"%(timeit.default_timer()-start_abandon))
                    if abandonReq == True:
                        segment_file_handle.close()
                        segment_file_handle = open(segment_filename,"w")
                        segment_file_handle.close()
                        break
                       
                
                    if abandonReq == True:
                    
                      config_dash.LOG.info("BOLA_ABANDONED SEGMENT %s and BOLA last quality %d"%(segment_url, bolaObj.lastQuality))
                      segment_path = dp_list[segment_number][bolaObj.lastQuality]
                      segment_url = urlparse.urljoin(domain, segment_path)
                      segment_size, segment_filename=download_segment(segment_url, dash_folder)
                    '''
                    #if segment_file_handle:
        	      #	segment_file_handle.close()

   		    return segment_size, segment_filename, bolaObj


def download_segment(segment_url, dash_folder):
    """ Module to download the segment """
    #parse_url = urlparse.urlparse(segment_url)
    #connection = HTTPConnectionPool(parse_url.netloc)
    #chunk_dl_rates = []
    parsed_uri = urlparse.urlparse(segment_url)
    segment_path = '{uri.path}'.format(uri=parsed_uri)
    while segment_path.startswith('/'):
        segment_path = segment_path[1:]        
    segment_filename = os.path.join(dash_folder, os.path.basename(segment_path))
    make_sure_path_exists(os.path.dirname(segment_filename))
    #segment_file_handle = open(segment_filename, 'wb')
    chunk_dl_rates = []
    segment_size = 0
    try:
        #print segment_url
        total_data_dl_time = 0
        
        chunk_number = 0
        chunk_start_time = timeit.default_timer()
        with closing(connection.get(segment_url, stream=True)) as seg_conn:
            with open(segment_filename,'wb') as segment_file_handle:
                for segment_data in seg_conn.iter_content(DOWNLOAD_CHUNK):
                    if segment_data is None:
                        break
                    segment_file_handle.write(segment_data)
                    segment_size += len(segment_data)
                    if len(segment_data) < DOWNLOAD_CHUNK:
                        timenow = timeit.default_timer()
                        chunk_dl_time = timenow - chunk_start_time
                        chunk_number += 1
                        total_data_dl_time += chunk_dl_time
                        current_chunk_dl_rate = segment_size * 8 / total_data_dl_time
                        chunk_dl_rates.append(current_chunk_dl_rate)
                        with open('chunk-test.txt', 'a') as chk:
                            chk.write("%s\n" % chunk_dl_rates)
                        #print chunk_dl_rates
                        #print "-----------------"
                        #print segment_w_chunks
                        #print "!!!!!!!!!!!!!!!!!"
                        #segment_w_chunks.append(chunk_dl_rates)
                        #print segment_w_chunks
                        #print "##################"
                        break
                    
                    timenow = timeit.default_timer()
                    chunk_dl_time = timenow - chunk_start_time
                    total_data_dl_time += chunk_dl_time
                    current_chunk_dl_rate = segment_size * 8 / total_data_dl_time
                    chunk_start_time = timenow
                    chunk_number += 1
                    chunk_dl_rates.append(current_chunk_dl_rate)
                
    except urllib2.HTTPError, error:
        config_dash.LOG.error("Unable to download DASH Segment {} HTTP Error:{} ".format(segment_url, str(error.code)))
        return None
    #except requests.exceptions.ResponseNotChunked:
     #   return None
    
    
    #connection.close()
    #seg_conn.release_conn()
    seg_conn.close()
    segment_file_handle.close()

    return segment_size, segment_filename

def download_segment_queue(segment_url, dash_folder, q1, q2, q3):
    """ Module to download the segment """
    #parse_url = urlparse.urlparse(segment_url)
    #connection = HTTPConnectionPool(parse_url.netloc)
    #chunk_dl_rates = []
    parsed_uri = urlparse.urlparse(segment_url)
    segment_path = '{uri.path}'.format(uri=parsed_uri)
    while segment_path.startswith('/'):
        segment_path = segment_path[1:]        
    segment_filename = os.path.join(dash_folder, os.path.basename(segment_path))
    make_sure_path_exists(os.path.dirname(segment_filename))
    #segment_file_handle = open(segment_filename, 'wb')
    chunk_dl_rates = []
    segment_size = 0
    try:
        #print segment_url
        total_data_dl_time = 0
        chunk_number = 0
        chunk_start_time = timeit.default_timer()
        with closing(connection.get(segment_url, stream=True)) as seg_conn:
            with open(segment_filename,'wb') as segment_file_handle:
                for segment_data in seg_conn.iter_content(DOWNLOAD_CHUNK):
                    if segment_data is None:
                        break
                    segment_file_handle.write(segment_data)
                    segment_size += len(segment_data)
                    if len(segment_data) < DOWNLOAD_CHUNK:
                        timenow = timeit.default_timer()
                        chunk_dl_time = timenow - chunk_start_time
                        chunk_number += 1
                        total_data_dl_time += chunk_dl_time
                        current_chunk_dl_rate = segment_size * 8 / total_data_dl_time
                        chunk_dl_rates.append(current_chunk_dl_rate)
                        with open('chunk-test.txt', 'a') as chk:
                            chk.write("%s\n" % chunk_dl_rates)
                        #print chunk_dl_rates
                        #print "-----------------"
                        #print segment_w_chunks
                        #print "!!!!!!!!!!!!!!!!!"
                        segment_w_chunks.append(chunk_dl_rates)
                        #print segment_w_chunks
                        #print "##################"
                        break
                    timenow = timeit.default_timer()
                    chunk_dl_time = timenow - chunk_start_time
                    total_data_dl_time += chunk_dl_time
                    current_chunk_dl_rate = segment_size * 8 / total_data_dl_time
                    chunk_start_time = timenow
                    chunk_number += 1
                    chunk_dl_rates.append(current_chunk_dl_rate)

    except urllib2.HTTPError, error:
        config_dash.LOG.error("Unable to download DASH Segment {} HTTP Error:{} ".format(segment_url, str(error.code)))
        return None
    #except requests.exceptions.ResponseNotChunked:
     #   return None
    
    
    #connection.close()
    #seg_conn.release_conn()
    seg_conn.close()
    segment_file_handle.close()

    q1.put(segment_size)
    q2.put(segment_filename)
    q3.put(segment_w_chunks)

def get_media_all(domain, media_info, file_identifier, done_queue):
    """ Download the media from the list of URL's in media
    """
    bandwidth, media_dict = media_info
    media = media_dict[bandwidth]
    media_start_time = timeit.default_timer()
    for segment in [media.initialization] + media.url_list:
        start_time = timeit.default_timer()
        segment_url = urlparse.urljoin(domain, segment)
        _, segment_file, _ = download_segment(segment_url, file_identifier)
        elapsed = timeit.default_timer() - start_time
        if segment_file:
            done_queue.put((bandwidth, segment_url, elapsed))
    media_download_time = timeit.default_timer() - media_start_time
    done_queue.put((bandwidth, 'STOP', media_download_time))
    return None


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


def start_playback_smart(dp_object, domain, playback_type=None, download=False, video_segment_duration=None, retrans=False):
    """ Module that downloads the MPD-FIle and download
        all the representations of the Module to download
        the MPEG-DASH media.
        Example: start_playback_smart(dp_object, domain, "SMART", DOWNLOAD, video_segment_duration)
        :param dp_object:       The DASH-playback object
        :param domain:          The domain name of the server (The segment URLS are domain + relative_address)
        :param playback_type:   The type of playback
                                1. 'BASIC' - The basic adapataion scheme
                                2. 'SARA' - Segment Aware Rate Adaptation
                                3. 'NETFLIX' - Buffer based adaptation used by Netflix
                                4. 'VLC' - VLC adaptation scheme
        :param download: Set to True if the segments are to be stored locally (Boolean). Default False
        :param video_segment_duration: Playback duratoin of each segment
        :return:
    """
    # Initialize the DASH buffer
    video_segment_duration = 2
    bola_init_state = False
    #timer_cmd="../../../ndnperf/c++/client/bin/ndnperf -p ndn:/edu/umass -d ishita.txt -w 16"
    #stream=os.system(timer_cmd)
    f_timer=open("ishita.txt",'r')
    for line in f_timer.readlines():
        print int(line)
    segment_number = int(line)
    dash_player = dash_buffer.DashPlayer((dp_object.playback_duration - (segment_number*video_segment_duration)), video_segment_duration)
    dash_player.start()
    # A folder to save the segments in
    file_identifier = id_generator()
    config_dash.LOG.info("The segments are stored in %s" % file_identifier)
    dp_list = defaultdict(defaultdict)
    # Creating a Dictionary of all that has the URLs for each segment and different bitrates
    for bitrate in dp_object.video:
        # Getting the URL list for each bitrate
        dp_object.video[bitrate] = read_mpd.get_url_list(dp_object.video[bitrate], video_segment_duration,
                                                         dp_object.playback_duration, bitrate)
        if "$Bandwidth$" in dp_object.video[bitrate].initialization:
            dp_object.video[bitrate].initialization = dp_object.video[bitrate].initialization.replace(
                "$Bandwidth$", str(bitrate))
        media_urls = [dp_object.video[bitrate].initialization] + dp_object.video[bitrate].url_list
        for segment_count, segment_url in enumerate(media_urls, dp_object.video[bitrate].start):
            # segment_duration = dp_object.video[bitrate].segment_duration
            dp_list[segment_count][bitrate] = segment_url
            #config_dash.LOG.info("DP_LIST:SEG_CNT %d"%segment_count)
    bitrates = dp_object.video.keys()
    bitrates.sort()
    average_dwn_time = 0
    segment_files = []
    # For basic adaptation
    global segment_w_chunks
    segment_w_chunks = []
    previous_segment_times = []
    #BOLA lists
    last_requests_start = []
    last_requests_finish = []
    last_requests_tput = []
    recent_download_sizes = []
    bitrate_history = []
    #segment_dl_rates = []
    weighted_mean_object = None
    current_bitrate = bitrates[0]
    decision_rate = 0
    previous_bitrate = None
    total_downloaded = 0
    bitrate_holder = 0
    dl_rate_history = [] 
    bolaObj = BOLAObject()
    # Delay in terms of the number of segments
    delay = 0
    segment_duration = 0
    segment_size = segment_download_time = None
    # Netflix Variables
    average_segment_sizes = netflix_rate_map = None
    netflix_state = "INITIAL"
    state=config_dash.BOLA_STATE_STARTUP
    RETRANSMISSION_SWITCH = False
    retransmission_delay = 0
    retransmission_delay_switch = False
    # Start playback of all the segments
    #for segment_number, segment in enumerate(dp_list, dp_object.video[current_bitrate].start):
    #for segment_number in dp_list:s
    original_segment_number = 1
    start_dload_time = timeit.default_timer()
    init_dl_start_time = timeit.default_timer() 
    while segment_number < len(dp_list):

        #print len(dp_list)
        #print "dp_list"
        #print segment
        #print segment_number
        #print "++++++++++++"
        config_dash.LOG.info(" {}: Processing the segment {}".format(playback_type.upper(), segment_number))
        write_json()
        if not previous_bitrate:
            previous_bitrate = current_bitrate
        if SEGMENT_LIMIT:
            if not dash_player.segment_limit:
                dash_player.segment_limit = int(SEGMENT_LIMIT)
            if segment_number > int(SEGMENT_LIMIT):
                config_dash.LOG.info("Segment limit reached")
                break
        if segment_number == dp_object.video[bitrate].start:
            current_bitrate = bitrates[0]
        else:
            if playback_type.upper() == "BASIC":
                current_bitrate, average_dwn_time = basic_dash2.basic_dash2(segment_number, bitrates, average_dwn_time,
                                                                            recent_download_sizes,
                                                                            previous_segment_times, current_bitrate)

                # if dash_player.buffer.qsize() > config_dash.BASIC_THRESHOLD:
                if dash_player.buffer.__len__() > config_dash.BASIC_THRESHOLD: #MZ
                    # delay = dash_player.buffer.qsize() - config_dash.BASIC_THRESHOLD
                    delay = dash_player.buffer.__len__() - config_dash.BASIC_THRESHOLD #MZ
                config_dash.LOG.info("Basic-DASH: Selected {} for the segment {}".format(current_bitrate,
                                                                                         segment_number + 1))
            elif playback_type.upper() == "SMART":
                if not weighted_mean_object:
                    weighted_mean_object = WeightedMean(config_dash.SARA_SAMPLE_COUNT)
                    config_dash.LOG.debug("Initializing the weighted Mean object")
                # Checking the segment number is in acceptable range
                segment_download_rate = segment_size / segment_download_time
                if segment_number < len(dp_list) - 1 + dp_object.video[bitrate].start:
                    try:
                        current_bitrate, delay = weighted_dash.weighted_dash(bitrates, dash_player,
                                                                             weighted_mean_object.weighted_mean_rate,
                                                                             current_bitrate, segment_number, segment_size, segment_download_time,
                                                                             get_segment_sizes(dp_object,
                                                                                               segment_number+1))
                    except IndexError, e:
                        config_dash.LOG.error(e)
                with open('sara-dash-chosen-rate.txt', 'a') as sara:
                    sara.write(str(current_bitrate) + '\t' + str(segment_download_rate) + '\n')
            elif playback_type.upper() == "NETFLIX":
                config_dash.LOG.info("Playback is NETFLIX")
                # Calculate the average segment sizes for each bitrate
                if not average_segment_sizes:
                    average_segment_sizes = get_average_segment_sizes(dp_object)
                if segment_number < len(dp_list) - 1 + dp_object.video[bitrate].start:
                    try:
                        if segment_size and segment_download_time:
                            segment_download_rate = segment_size / segment_download_time
                        else:
                            segment_download_rate = 0
                        current_bitrate, netflix_rate_map, netflix_state = netflix_dash.netflix_dash(
                            bitrates, dash_player, segment_download_rate, current_bitrate, average_segment_sizes,
                            netflix_rate_map, netflix_state)
                        config_dash.LOG.info("NETFLIX: Next bitrate = {}".format(current_bitrate))
                    except IndexError, e:
                        config_dash.LOG.error(e)
                else:
                    config_dash.LOG.critical("Completed segment playback for Netflix")
                    break

                # If the buffer is full wait till it gets empty
                # if dash_player.buffer.qsize() >= config_dash.NETFLIX_BUFFER_SIZE:
                if dash_player.buffer.__len__() >= config_dash.NETFLIX_BUFFER_SIZE: #MZ
                    # delay = (dash_player.buffer.qsize() - config_dash.NETFLIX_BUFFER_SIZE + 1) * segment_duration
                    delay = (dash_player.buffer.__len__() - config_dash.NETFLIX_BUFFER_SIZE + 1) * segment_duration #MZ
                    config_dash.LOG.info("NETFLIX: delay = {} seconds".format(delay))
            elif playback_type.upper() == "BOLA":
                config_dash.LOG.info("Playback is BOLA")
                # Calculate the average segment sizes for each bitrate
                #if not average_segment_sizes:
                    #average_segment_sizes = get_average_segment_sizes(dp_object)
                if segment_number < len(dp_list) - 1 + dp_object.video[bitrate].start:
                    try:
                        if segment_download_time:
                            segment_download_rate = (segment_size*8) / segment_download_time
                            last_requests_tput.append(segment_download_rate)
                        else:
                            segment_download_rate = 0
                            last_requests_tput.append(segment_download_rate)
                        
                        #current_bitrate, netflix_rate_map, netflix_state = dash_bola.bola_dash(
                            #bitrates, dash_player, segment_download_rate, current_bitrate, average_segment_sizes,
                            #netflix_rate_map, netflix_state)
                        bolaObj.vid_length=len(dp_list) - 1 + dp_object.video[bitrate].start
                        
                        bolaObj.bitrates=bitrates
                        bolaObj.video_segment_duration=video_segment_duration
                        if bola_init_state == False:
                            bolaObj, delay = dash_bola.calculateInitialState(segment_download_rate, current_bitrate, bolaObj)
                            bola_init_state = True
                        bolaObj, delay = dash_bola.bola_dash(dash_player.buffer.__len__(), segment_download_rate, current_bitrate, last_requests_start, last_requests_finish, last_requests_tput,bolaObj)
                        current_bitrate=bolaObj.lastQuality
                        config_dash.LOG.info("SEGMENTURLBitrate1: %d"%current_bitrate)
                        
                        if not os.path.exists(bola_buffer_log_file):
                            header_row = "EpochTime, CurrentBufferSize, Bitrate, DownloadRate, state".split(",")
                            stats = (timeit.default_timer()-start_dload_time, str(dash_player.buffer.__len__()), current_bitrate, (segment_download_rate/8.0), bolaObj.state)
                        else:
                            header_row=None
                            stats = (timeit.default_timer()-start_dload_time, str(dash_player.buffer.__len__()), current_bitrate, (segment_download_rate/8.0), bolaObj.state)
                        str_stats = [str(i) for i in stats]
                        with open(bola_buffer_log_file, "ab") as log_file_handle:
                            result_writer = csv.writer(log_file_handle, delimiter=",")
                            if header_row:
                                result_writer.writerow(header_row)
                            result_writer.writerow(str_stats)
                        config_dash.LOG.info("BOLA: Next bitrate = {}".format(current_bitrate))
                    except IndexError, e:
                        config_dash.LOG.error(e)
                else:
                    config_dash.LOG.critical("Completed segment playback for BOLA")
                    break
                
                if dash_player.buffer.__len__() >= config_dash.BOLA_BUFFER_SIZE: 
                   delay = max((dash_player.buffer.__len__()-config_dash.BOLA_BUFFER_SIZE + 1),0)
                   #delay=1
                   config_dash.LOG.info("BOLA : delay = {} seconds".format(delay))
                
                # If the buffer is full wait till it gets empty
                #if dash_player.buffer.__len__() >= config_dash.NETFLIX_BUFFER_SIZE:
                    #delay = (dash_player.buffer.__len__() - config_dash.NETFLIX_BUFFER_SIZE + 1) * segment_duration

            elif playback_type.upper() == "VLC" :
                config_dash.LOG.info("Unknown playback type:{}. Continuing with basic playback".format(playback_type))
                config_dash.LOG.info("VLC: Current Bitrate %d"%current_bitrate)
                # current_bitrate = basic_dash.basic_dash(segment_number, bitrates, segment_download_time, current_bitrate, dash_player.buffer.qsize(), segment_size)
                current_bitrate = basic_dash.basic_dash(segment_number, bitrates, segment_download_time, current_bitrate, dash_player.buffer.__len__(), segment_size) #MZ
                with open('vlc-dash-chosen-rate.txt', 'a') as vlc:
                    vlc.write(str(current_bitrate) + '\n')
                # if dash_player.buffer.qsize() >= (config_dash.NETFLIX_BUFFER_SIZE):
                if dash_player.buffer.__len__() >= (config_dash.NETFLIX_BUFFER_SIZE): #MZ
                    delay = 1
                else:
                    delay = 0

            elif playback_type.upper() == "EMPIRICAL" :
                buffer_upper = config_dash.NETFLIX_BUFFER_SIZE * BUFFER_THRESHOLD_UPPER
                buffer_lower = config_dash.NETFLIX_BUFFER_SIZE * BUFFER_THRESHOLD_LOWER
                #segment_sizes_test = get_segment_sizes(dp_object,segment_number)
                #print "================"
                #print segment_sizes_test
                #print segment_number
                #print "================"
                if segment_size == 0:
                    curr_rate = 0
                else:
                    curr_rate = (segment_size*8)/segment_download_time
                #segment_dl_rates.append(curr_rate)
                average_segment_sizes = get_average_segment_sizes(dp_object)
                dl_rate_history.append(curr_rate)
                #print "-----------!!!!!!!!"
                #print dl_rate_history
                #print "!!!!!!!------------"
                if len(dl_rate_history) > 10:
                    dl_rate_history.pop(0)
                # current_bitrate = empirical_dash.empirical_dash(average_segment_sizes, segment_number, bitrates, segment_download_time, current_bitrate, dash_player.buffer.qsize(), segment_size, get_segment_sizes(dp_object,segment_number-2), video_segment_duration, dl_rate_history, bitrate_history, segment_w_chunks, DOWNLOAD_CHUNK)
                current_bitrate, decision_rate = empirical_dash.empirical_dash(average_segment_sizes, segment_number, bitrates, segment_download_time, current_bitrate, dash_player.buffer.__len__(), segment_size, get_segment_sizes(dp_object,segment_number-2), video_segment_duration, dl_rate_history, bitrate_history, segment_w_chunks, DOWNLOAD_CHUNK) #MZ
                bitrates = [float(i) for i in bitrates]
                
                if len(segment_w_chunks) > 10:
                    #segment_w_chunks = numpy.delete(segment_w_chunks, (0), axis=0)
                    segment_w_chunks.pop(0)
                # if dash_player.buffer.qsize() >= buffer_upper and segment_number > 10:
                if dash_player.buffer.__len__() >= buffer_upper and segment_number > 10: #MZ
                    with open('empirical-buffer-holder.txt', 'a') as buh:
                        buh.write(str(segment_number) + '\t' + '1' + '\n')
                    if bitrate_holder == 1:
                        current_bitrate = bitrate_history[-1]
                    elif current_bitrate < bitrates[int(bitrates.index(bitrate_history[-1]) - 2)]:
                        print "current_rate! : " + str(current_bitrate)
#                        current_bitrate = bitrate_history[-1]                  
                        next_bitrate = int(round(bitrate_history[-1] + current_bitrate) / 2) 
                        current_bitrate = min(bitrates, key=lambda x:abs(x - next_bitrate))
                        #next_q_layer = int(round((bitrates.index(bitrate_history[-1]) + bitrates.index(current_bitrate)) / 2))                        
                        #print "next_q_layer! : " + str(next_q_layer)
                        #current_bitrate = bitrates[next_q_layer]
                        print "changed current_rate! : " + str(current_bitrate)
                        bitrate_holder = 1
                    elif bitrate_holder == 0:
                        print "go ahead!"
                else:
                    bitrate_holder = 0
                #if (bitrates.index(current_bitrate) - bitrates.index(bitrate_history[-1])) <= 2 and (bitrates.index(current_bitrate) - bitrates.index(bitrate_history[-1])) >= 0:
                #    current_bitrate = bitrate_history[-1]
                            #current_bitrate = bitrates[bitrates.index(bitrate_history[-1])/2]
                print "---------------current_bitrate: " +  str(current_bitrate)
                bitrate_actual_time = timeit.default_timer() - init_dl_start_time
                # if dash_player.buffer.qsize() >= (config_dash.NETFLIX_BUFFER_SIZE):
                if segment_size and segment_download_time:
                    segment_download_rate = segment_size / segment_download_time
                else:
                    segment_download_rate = 0
                RETRANS_OFFSET = False
                #original_segment_number = segment_number
                if segment_number > 10 and retrans:
                    print '++++++++++++++++++++++++++'
                    print dash_player.buffer.__len__()
                    print (RETRANS_THRESHOLD_UPPER * config_dash.NETFLIX_BUFFER_SIZE)
                    print RETRANSMISSION_SWITCH
                    print '++++++++++++++++++++++++++'
                    if curr_rate > current_bitrate or RETRANSMISSION_SWITCH:
                        with open('empirical-retrans.txt', 'a') as retrans:
                            retrans.write(str(segment_number) + '\t' + '2' + '\n')
                        with open('empirical-debug.txt', 'a') as emp:
                            emp.write("!!!!!!!RETRANSMISSION!!!!!!!!" + '\n')
                        print "!!!!!!!RETRANSMISSION!!!!!!!!"
                        RETRANSMISSION_SWITCH = True
                        original_segment_number = segment_number
                        original_current_bitrate = current_bitrate
                        new_current_bitrate, new_segment_number = retransmission.retransmission(dp_object, current_bitrate, segment_number, dash_player.buffer, bitrates, segment_download_rate, config_dash.NETFLIX_BUFFER_SIZE, video_segment_duration)
                        #if dash_player.buffer.__len__() < (RETRANS_THRESHOLD_LOWER * config_dash.NETFLIX_BUFFER_SIZE):
                        #    RETRANSMISSION_SWITCH = False
                        #if decision_rate < original_current_bitrate:
                        #    RETRANSMISSION_SWITCH = False
                        if curr_rate - current_bitrate >= original_current_bitrate:
                            current_bitrate = new_current_bitrate
                            segment_number = new_segment_number
                            RETRANSMISSION_SWITCH = False
                        #dl_rate based retransmission:
                        #if segment_number != original_segment_number and (curr_rate - current_bitrate >= original_current_bitrate):
                        if segment_number != original_segment_number:
                            retransmission_delay_switch = True
                        seg_num_offset = - (original_segment_number - segment_number + 1)
                        bitrate_history.pop(seg_num_offset)
                        bitrate_history.insert(seg_num_offset, current_bitrate)
                        RETRANS_OFFSET = True
                        retransmission_delay += 1
                        with open('empirical-debug.txt', 'a') as emp:
                            emp.write('\n' + str(segment_number) + '\t' + str(bitrate_actual_time) + '\t' + str(current_bitrate) + '\t' + str(dash_player.buffer.__len__()) + 'retr' + '\n')
                with open('empirical-dash-chosen-rate.txt', 'a') as emp:
                    emp.write(str(segment_number) + '\t' + str(bitrate_actual_time) + '\t' + str(segment_download_rate * 8) + '\t' + str(decision_rate) + '\t' + str(current_bitrate) + '\t' + str(dash_player.buffer.__len__()) + '\n')
                if dash_player.buffer.__len__() >= (config_dash.NETFLIX_BUFFER_SIZE): #MZ
                    delay = 1
                else:
                    delay = 0
                #print segment_number
                #print "=============="
                #print dp_object.video[current_bitrate]
                #print "=============="
                if RETRANS_OFFSET == False:
                    bitrate_history.append(current_bitrate)
                    #segment_number -= retransmission_delay
                    #retransmission_delay_done = True
                print "-------------+++++++++++++"
                print segment
                print dp_list[segment][current_bitrate]
                print urlparse.urljoin(domain, segment_path)
                print "-------------+++++++++++++"
        
        segment_path = dp_list[segment_number][current_bitrate]
        segment_url = urlparse.urljoin(domain, segment_path)
        config_dash.LOG.info("URL Domain%s and Segment Path %s"%(domain,segment_path))
	config_dash.LOG.info("SEGMENTURLBitrate2: %d"%current_bitrate)
        if retransmission_delay_switch:
            original_segment_path = dp_list[original_segment_number][original_current_bitrate]
            original_segment_url = urlparse.urljoin(domain, original_segment_path)
        #print "+++++++++++++"
        #print segment_path
        #print segment_url
        #print file_identifier
        #print "+++++++++++++"
        config_dash.LOG.info("{}: Segment URL = {}".format(playback_type.upper(), segment_url))
        
        if delay:
            delay_start = time.time()
            config_dash.LOG.info("SLEEPING for {}seconds ".format(delay*segment_duration))
            while time.time() - delay_start < (delay * segment_duration):
                time.sleep(1)
            delay = 0
            config_dash.LOG.debug("SLEPT for {}seconds ".format(time.time() - delay_start))
        

        #try:
        #    config_dash.LOG.info("{}: Started downloading segment {}".format(playback_type.upper(), segment_url))
        #    segment_size, segment_filename, segment_w_chunks = download_segment(segment_url, file_identifier)
        #    config_dash.LOG.info("{}: Finished Downloaded segment {}".format(playback_type.upper(), segment_url))
        #except IOError, e:
        #    config_dash.LOG.error("Unable to save segment %s" % e)
        #    return None
        #if RETRANSMISSION_SWITCH:
        #pool = workerpool.WorkerPool(size=2)do
        #pool.map(download_segment, segment_url, file_identifier)
        #pool.shutdown()
        #pool.wait()
#        threads = []
        
        if segment_number > 10 and retransmission_delay_switch:
            try:
                print "________________________________________________________________"
                config_dash.LOG.info("{}: Started downloading segment {}".format(playback_type.upper(), segment_url))
                config_dash.LOG.info("{}: Started downloading original segment {}".format(playback_type.upper(), original_segment_url))
                q1 = multiprocessing.Queue()
                q2 = multiprocessing.Queue()
                q3 = multiprocessing.Queue()
                q4 = multiprocessing.Queue()
                q5 = multiprocessing.Queue()
                q6 = multiprocessing.Queue()
                p1 = multiprocessing.Process(target=download_segment_queue, timeout=15, args=(original_segment_url, file_identifier, q1, q2, q3))
                p2 = multiprocessing.Process(target=download_segment_queue, timeout=15, args=(segment_url, file_identifier, q4, q5, q6))
                p1.start()
                p1.join()
                p2.start()
                p2.join()
                retrans_segment_size = q1.get()
                retrans_segment_filename = q2.get()
                retrans_segment_w_chunks = q3.get()
                segment_size = q4.get()
                segment_filename = q5.get()
                segment_w_chunks = q6.get()

                #segment_size, segment_filename, segment_w_chunks = download_segment(original_segment_url, file_identifier)
                #retrans_segment_size, retrans_segment_filename, retrans_segment_w_chunks = download_segment(segment_url, file_identifier)
                #res = Pool().map(download_segment,[segment_url, original_segment_url], [file_identifier, file_identifier])
                #retrans_segment_size = res[0][0]
                #retrans_segment_filename = [1][0]
                #retrans_segment_w_chunks = [2][0]
                #segment_size = res[0][1]
                #segment_filename = [1][1]
                #segment_w_chunks = [2][1]
                #print "________res________"
                #print res
                #print "________res________"
                #p1 = Process(target=download_segment, args=(segment_url, file_identifier))
                #p2 = Process(target=download_segment, args=(original_segment_url, file_identifier))
                #p1.start()
                #p2.start()
                #p1.join()
                #p2.join()
                config_dash.LOG.info("{}: Finished Downloaded segment {}".format(playback_type.upper(), segment_url))
                config_dash.LOG.info("{}: Finished Downloaded segment {}".format(playback_type.upper(), original_segment_url))
            except IOError, e:
                config_dash.LOG.error("Unable to save segment %s" % e)
                return None
        else:
            try:
                
                config_dash.LOG.info("{}: Started downloading segment {} with segment number {} and DP_LIST length {}".format(playback_type.upper(), segment_url, segment_number, len(dp_list)))
                if playback_type.upper()=="BOLA":
                  start_time = timeit.default_timer()
                  if segment_number < len(dp_list) - 1:
                    bola_seg_size = get_segment_sizes(dp_object,(segment_number))
                    segment_size, segment_filename, bolaObj = download_segment_bola(domain, dp_list,segment_number,segment_url, file_identifier, bolaObj, dash_player, last_requests_tput, start_time, bola_seg_size)
                    bolaObj.bufferlen=0.0
                    if bolaObj.lastQuality!=0:
                        current_bitrate=bolaObj.lastQuality
                    
                config_dash.LOG.info("{}: Finished Downloaded segment {}".format(playback_type.upper(), segment_url))
            except IOError, e:
                config_dash.LOG.error("Unable to save segment %s" % e)
                return None
        finish_time=timeit.default_timer()
        segment_download_time = finish_time - start_time
        last_requests_start.append(start_time)
        last_requests_finish.append(finish_time)
        previous_segment_times.append(segment_download_time)
        recent_download_sizes.append(segment_size)
        # Updating the JSON information
        segment_name = os.path.split(segment_url)[1]
        if "segment_info" not in config_dash.JSON_HANDLE:
            config_dash.JSON_HANDLE["segment_info"] = list()
        config_dash.JSON_HANDLE["segment_info"].append((segment_name, current_bitrate, segment_size,
                                                        segment_download_time))
        total_downloaded += segment_size
        config_dash.LOG.info("{} : The total downloaded = {}, segment_size = {}, segment_number = {} segment_download_time = {}".format(
            playback_type.upper(),
            total_downloaded, segment_size, segment_number, segment_download_time))
        if playback_type.upper() == "SMART" and weighted_mean_object:
            weighted_mean_object.update_weighted_mean(segment_size, segment_download_time)

        if retransmission_delay_switch:
            segment_info = {'playback_length': video_segment_duration,
                            'size': segment_size,
                            'bitrate': current_bitrate,
                            'data': segment_filename,
                            'URI': original_segment_url,
                            'segment_number': segment_number,
                            'segment_layer': bitrates.index(current_bitrate)}
            segment_info_retrans = {'playback_length': video_segment_duration,
                            'size': retrans_segment_size,
                            'bitrate': new_current_bitrate,
                            'data': retrans_segment_filename,
                            'URI': segment_url,
                            'segment_number': new_segment_number,
                            'segment_layer': bitrates.index(new_current_bitrate)}
        else:
            segment_info = {'playback_length': video_segment_duration,
                            'size': segment_size,
                            'bitrate': current_bitrate,
                            'data': segment_filename,
                            'URI': segment_url,
                            'segment_number': segment_number,
                            'segment_layer': bitrates.index(current_bitrate)}
        segment_duration = segment_info['playback_length']
        dash_player.write(segment_info)
        if retransmission_delay_switch:
            dash_player.write(segment_info_retrans)
            segment_files.append(retrans_segment_filename)
        segment_files.append(segment_filename)
        segment_number += 1
        if retransmission_delay_switch == True:
            segment_number = original_segment_number #+ 1
        #if segment_number > 10:
        #    if original_segment_number != segment_number:
        #        print "!!!!!!!!! not equal !!!!!!!!!!!!"
        #        print "segment_number " + str(segment_number)
        #        print "original segment number : " + str(original_segment_number)
        #        retransmission_delay_switch = True
        #        #original_segment_number += 1
        config_dash.LOG.info("Download info: segment URL: %s. Size = %s in %s seconds" % (
            segment_url, segment_size, str(segment_download_time)))
        if previous_bitrate:
            if previous_bitrate < current_bitrate:
                config_dash.JSON_HANDLE['playback_info']['up_shifts'] += 1
            elif previous_bitrate > current_bitrate:
                config_dash.JSON_HANDLE['playback_info']['down_shifts'] += 1
            previous_bitrate = current_bitrate
    # waiting for the player to finish playing
    while dash_player.playback_state not in dash_buffer.EXIT_STATES:
        time.sleep(1)
    write_json()
    if not download:
        clean_files(file_identifier)



def get_segment_sizes(dp_object, segment_number):
    """ Module to get the segment sizes for the segment_number
    :param dp_object:
    :param segment_number:
    :return:
    """
    #for bitrate in dp_object.video:
    #    print "hellohello-------------"
    #    print dp_object.video[bitrate].segment_sizes[segment_number]
    #    print bitrate
    #    print segment_number
    #    print "+++++++++++++++++"
    #    segment_sizes = dict([(bitrate, dp_object.video[bitrate].segment_sizes[segment_number]))
    segment_sizes = dict([(bitrate, dp_object.video[bitrate].segment_sizes[segment_number]) for bitrate in dp_object.video])
    #print "hellohello-------------segment_size"
    #print segment_sizes
    #print "+++++++++++++++++"
    config_dash.LOG.debug("The segment sizes of {} are {}".format(segment_number, segment_sizes))
    return segment_sizes


def get_average_segment_sizes(dp_object):
    """
    Module to get the avearge segment sizes for each bitrate
    :param dp_object:
    :return: A dictionary of aveage segment sizes for each bitrate
    """
    average_segment_sizes = dict()
    for bitrate in dp_object.video:
        segment_sizes = dp_object.video[bitrate].segment_sizes
        segment_sizes = [float(i) for i in segment_sizes]
        average_segment_sizes[bitrate] = sum(segment_sizes)/len(segment_sizes)
    config_dash.LOG.info("The avearge segment size for is {}".format(average_segment_sizes.items()))
    return average_segment_sizes


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


def start_playback_all(dp_object, domain):
    """ Module that downloads the MPD-FIle and download all the representations of 
        the Module to download the MPEG-DASH media.
    """
    # audio_done_queue = Queue()
    video_done_queue = Queue()
    processes = []
    file_identifier = id_generator(6)
    config_dash.LOG.info("File Segments are in %s" % file_identifier)
    # for bitrate in dp_object.audio:
    #     # Get the list of URL's (relative location) for the audio
    #     dp_object.audio[bitrate] = read_mpd.get_url_list(bitrate, dp_object.audio[bitrate],
    #                                                      dp_object.playback_duration)
    #     # Create a new process to download the audio stream.
    #     # The domain + URL from the above list gives the
    #     # complete path
    #     # The fil-identifier is a random string used to
    #     # create  a temporary folder for current session
    #     # Audio-done queue is used to exchange information
    #     # between the process and the calling function.
    #     # 'STOP' is added to the queue to indicate the end
    #     # of the download of the sesson
    #     process = Process(target=get_media_all, args=(domain, (bitrate, dp_object.audio),
    #                                                   file_identifier, audio_done_queue))
    #     process.start()
    #     processes.append(process)

    for bitrate in dp_object.video:
        dp_object.video[bitrate] = read_mpd.get_url_list(bitrate, dp_object.video[bitrate],
                                                         dp_object.playback_duration,
                                                         dp_object.video[bitrate].segment_duration)
        # Same as download audio
        process = Process(target=get_media_all, args=(domain, (bitrate, dp_object.video),
                                                      file_identifier, video_done_queue))
        process.start()
        processes.append(process)
    for process in processes:
        process.join()
    count = 0
    for queue_values in iter(video_done_queue.get, None):
        bitrate, status, elapsed = queue_values
        if status == 'STOP':
            config_dash.LOG.critical("Completed download of %s in %f " % (bitrate, elapsed))
            count += 1
            if count == len(dp_object.video):
                # If the download of all the videos is done the stop the
                config_dash.LOG.critical("Finished download of all video segments")
                break


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
    if LIST:
        # Print the representations and EXIT
        print_representations(dp_object)
        return None
    if "all" in PLAYBACK.lower():
        if mpd_file:
            config_dash.LOG.critical("Start ALL Parallel PLayback")
            start_playback_all(dp_object, domain)
    elif "basic" in PLAYBACK.lower():
        config_dash.LOG.critical("Started Basic-DASH Playback")
        start_playback_smart(dp_object, domain, "BASIC", DOWNLOAD, video_segment_duration, RETRANS)
    elif "sara" in PLAYBACK.lower():
        config_dash.LOG.critical("Started SARA-DASH Playback")
        start_playback_smart(dp_object, domain, "SMART", DOWNLOAD, video_segment_duration, RETRANS)
    elif "netflix" in PLAYBACK.lower():
        config_dash.LOG.critical("Started Netflix-DASH Playback")
        start_playback_smart(dp_object, domain, "NETFLIX", DOWNLOAD, video_segment_duration, RETRANS)
    elif "vlc" in PLAYBACK.lower():
        config_dash.LOG.critical("Started Basic2-DASH Playback")
        start_playback_smart(dp_object, domain, "VLC", DOWNLOAD, video_segment_duration, RETRANS)
    elif "empirical" in PLAYBACK.lower():
        config_dash.LOG.critical("Started Hello-DASH Playback")
        start_playback_smart(dp_object, domain, "EMPIRICAL", DOWNLOAD, video_segment_duration, RETRANS)
    elif "bola" in PLAYBACK.lower():
        config_dash.LOG.critical("Started BOLA-DASH Playback")
        start_playback_smart(dp_object, domain, "BOLA", DOWNLOAD, video_segment_duration)
    
    else:
        config_dash.LOG.error("Unknown Playback parameter {}".format(PLAYBACK))
        return None

if __name__ == "__main__":
    sys.exit(main())
