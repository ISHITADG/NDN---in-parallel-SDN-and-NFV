#!/usr/bin/env python
#
#    AStream: Python based DASH player emulator to evaluate the rate adaptation algorithms
#             for DASH.
#    Copyright (C) 2015, Parikshit Juluri
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License along
#    with this program; if not, write to the Free Software Foundation, Inc.,
#    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#

from time import strftime
import os
import random
from string import ascii_letters, digits
# The configuration file for the AStream module
# create logger
LOG_NAME = 'AStream_log'
LOG_LEVEL = None
idr = os.environ["id"]
# Set '-' to print to screen
LOG_FOLDER = "/mnt/QUIClientServer0/ASTREAM_LOGS/"
if not os.path.exists(LOG_FOLDER):
    os.makedirs(LOG_FOLDER)

LOG_FILENAME = os.path.join(LOG_FOLDER, 'DASH_RUNTIME_LOG')
# Logs related to the statistics for the video
# PLAYBACK_LOG_FILENAME = os.path.join(LOG_FOLDER, strftime('DASH_PLAYBACK_LOG_%Y-%m-%d.%H_%M_%S.csv'))
# Buffer logs created by dash_buffer.py
BUFFER_LOG_FILENAME = os.path.join(LOG_FOLDER, strftime('DASH_BUFFER_LOG_%Y-%m-%d.%H_%M_%S_'+idr+'.csv'))
SERVER_LOG_FILENAME = os.path.join(LOG_FOLDER, strftime('SERVER_LOG_%Y-%m-%d.%H_%M_%S_'+idr+'.csv'))
BOLA_BUFFER_LOG_FILENAME = os.path.join(LOG_FOLDER, strftime('BOLA_LOG_%Y-%m-%d.%H_%M_%S_'+idr+'.csv'))
LOG_FILE_HANDLE = None
# To be set by configure_log_file.py
LOG = None
# JSON Filename
JSON_LOG = os.path.join(LOG_FOLDER, strftime('ASTREAM_%Y-%m-%d.%H_%M_%S_'+idr+'.json'))
JSON_HANDLE = dict()
JSON_HANDLE['playback_info'] = {'start_time': None,
                                'end_time': None,
                                'initial_buffering_duration': None,
                                'interruptions': {'count': 0, 'events': list(), 'total_duration': 0},
                                'up_shifts': 0,
                                'down_shifts': 0
                                }
# Constants for the BASIC-2 adaptation scheme
BASIC_THRESHOLD = 10
BASIC_UPPER_THRESHOLD = 1.2
# Number of segments for moving average
BASIC_DELTA_COUNT = 5

# ---------------------------------------------------
# SARA (Segment Aware Rate Adaptation)
# ---------------------------------------------------
# Number of segments for moving weighted average
SARA_SAMPLE_COUNT = 5
# Constants for the Buffer in the Weighted adaptation scheme (in segments)
INITIAL_BUFFERING_COUNT = 1
RE_BUFFERING_COUNT = 1
ALPHA_BUFFER_COUNT = 5
BETA_BUFFER_COUNT = 10
# Set the size of the buffer in terms of segments. Set to unlimited if 0 or None
MAX_BUFFER_SIZE = 15

# ---------------------------------------------------
# Netflix (Buffer-based) ADAPTATION
# ---------------------------------------------------
# Constants for the Netflix Buffering scheme adaptation/netflix_buffer.py
# Constants is terms of buffer occupancy PERCENTAGE(%)
NETFLIX_RESERVOIR = 0.1
NETFLIX_CUSHION = 0.9
# Buffer Size in Number of segments 240/4
NETFLIX_BUFFER_SIZE = 15
NETFLIX_INITIAL_BUFFER = 2
NETFLIX_INITIAL_FACTOR = 0.875

#------------------------------------------------
#BOLA ADAPTATION
#------------------------------------------------
MINIMUM_BUFFER_LEVEL_SPACING = 5.0
AVERAGE_THROUGHPUT_SAMPLE_AMOUNT_LIVE = 2
AVERAGE_THROUGHPUT_SAMPLE_AMOUNT_VOD = 3
DEFAULT_MIN_BUFFER_TIME = 12
LONG_FORM_CONTENT_DURATION_THRESHOLD = 600
BUFFER_TIME_AT_TOP_QUALITY_LONG_FORM = 60
BUFFER_TIME_AT_TOP_QUALITY = 30
BANDWIDTH_SAFETY_FACTOR = 0.9
BOLA_BUFFER_SIZE=15
#BOLA_STATE_ONE_BITRATE   : If there is only one bitrate (or initialization failed), always return NO_CHANGE.
BOLA_STATE_ONE_BITRATE = 0
#BOLA_STATE_STARTUP       : Download fragments at most recently measured throughput.
BOLA_STATE_STARTUP = 1
#BOLA_STATE_STARTUP_NO_INC: If quality increased then decreased during startup, then quality cannot be increased.
BOLA_STATE_STARTUP_NO_INC = 2
#BOLA_STATE_STEADY        : Buffer primed, we switch to steady operation.
BOLA_STATE_STEADY = 3
BOLA_DEBUG =0
BOLAU = False

GRACE_PERIOD_MS = 0.5
POOR_LATENCY_MS = 0.2
# For ping.py
PING_PACKETS = 10
ping_option_nb_pkts = PING_PACKETS
rtt_match = None
rtt_pattern = None
index_rtt_min = None
index_rtt_avg = None
index_rtt_max = None
RTT = False


