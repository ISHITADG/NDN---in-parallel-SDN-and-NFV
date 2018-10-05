""""
* The copyright in this software is being made available under the BSD License,
* included below. This software may be subject to other third party and contributor
* rights, including patent rights, and no such rights are granted under this license.
*
* Copyright (c) 2016, Dash Industry Forum.
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without modification,
* are permitted provided that the following conditions are met:
*  * Redistributions of source code must retain the above copyright notice, this
*  list of conditions and the following disclaimer.
*  * Redistributions in binary form must reproduce the above copyright notice,
*  this list of conditions and the following disclaimer in the documentation and/or
*  other materials provided with the distribution.
*  * Neither the name of Dash Industry Forum nor the names of its
*  contributors may be used to endorse or promote products derived from this software
*  without specific prior written permission.
*
*  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS AS IS AND ANY
*  EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
*  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
*  IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
*  INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
*  NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
*  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
*  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
*  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
*  POSSIBILITY OF SUCH DAMAGE.
"""

# For a description of the BOLA adaptive bitrate (ABR) algorithm, see http://arxiv.org/abs/1601.06748

from __future__ import division

import config_dash
from collections import OrderedDict
import basic_dash
import timeit
import math
import Queue



def setup():
    lastCallTimeDict = {}
    seekMediaTypes = []
    mediaPlayerModel = MediaPlayerModel(context).getInstance()
    playbackController = PlaybackController(context).getInstance()
    adapter = DashAdapter(context).getInstance()
    eventBus.on(Events.PLAYBACK_SEEKING, onPlaybackSeeking, instance)
    eventBus.on(Events.PERIOD_SWITCH_STARTED, onPeriodSwitchStarted, instance)



def calculateInitialState(segment_download_rate, curr_bitrate, bolaObj):
    
    # TODO: currently based on 12 second buffer target, tweek to utilize a higher buffer target

    #Initialize Bitrate
    #bitrate = mediaInfo.bitrateList.map(b => b.bandwidth)
    #bitrate = basic_dash(segment_number, bitrates,
     #      segment_download_time, curr_bitrate, buffer_size, segment_size)
    bitrateCount = len(bolaObj.bitrates)
    if bitrateCount < 2 or bolaObj.bitrates[0] >= bolaObj.bitrates[1] or bolaObj.bitrates[bitrateCount -  2] >= bolaObj.bitrates[bitrateCount - 1]:
        # if bitrate list irregular, stick to lowest bitrate
        # TODO: should we tolerate repeated bitrates?
        bolaObj.state = config_dash.BOLA_STATE_ONE_BITRATE
        return bolaObj

    # Note: If isDynamic (live streaming) we keep the same target for cases where the user is playing behind live edge, but then make throughput-based decisions when the buffer level is low because of availability.
    bolaObj.bufferTarget = config_dash.DEFAULT_MIN_BUFFER_TIME
    if (bolaObj.vid_length*bolaObj.video_segment_duration) >= config_dash.LONG_FORM_CONTENT_DURATION_THRESHOLD:
        bolaObj.bufferMax = config_dash.BUFFER_TIME_AT_TOP_QUALITY_LONG_FORM
    else:
        bolaObj.bufferMax = config_dash.BUFFER_TIME_AT_TOP_QUALITY


    # During live streaming, there might not be enough fragments available to fill all the way to the buffer target. In such a case, Bola detects the lack of fragment availability and calculate a bitrate depending on what the buffer level would have been had more fragments been available. This is done by keeping an additional virtualBuffer level. Of course, in such a case Bola needs to also keep track of the real buffer to avoid rebuffering.

    # Bola needs some space between buffer levels. If bolaBufferTarget is set to a level higher than the real bufferTarget, the Schedule Controller will still not fill up the buffer up to bolaBufferTarget. However, Bola will detect the effect of the Schedule Controller and calculate a bitrate depending on what the buffer level would have been had the Schedule Controller filled more buffer. This is handled similar to the live streaming scenario using the additional virtualBuffer level.
    bolaObj.bolaBufferTarget = bolaObj.bufferTarget
    if bolaObj.bolaBufferTarget < bolaObj.video_segment_duration + config_dash.MINIMUM_BUFFER_LEVEL_SPACING:

        bolaObj.bolaBufferTarget = bolaObj.video_segment_duration + config_dash.MINIMUM_BUFFER_LEVEL_SPACING


    bolaObj.utility = []
    for i in range(0,bitrateCount):
        bolaObj.utility.append(math.log(bolaObj.bitrates[i] / bolaObj.bitrates[0]))


    # BOLA parameters V and gamma (multiplied by p === video_segment_duration):
    # Choose Vp and gp such that logarithmic utility would always prefer the lowest bitrate when bufferLevel === video_segment_duration and would always prefer the highest bitrate when bufferLevel === bufferTarget.
    # TODO: document the math
    bolaObj.Vp = (bolaObj.bolaBufferTarget - bolaObj.video_segment_duration) / bolaObj.utility[bitrateCount - 1]
    bolaObj.gp = 1.0 + bolaObj.utility[bitrateCount - 1] / (bolaObj.bolaBufferTarget / bolaObj.video_segment_duration - 1.0)

    # If the bufferTarget (the real bufferTarget and not bolaBufferTarget) is large enough, we might guarantee that Bola will never rebuffer unless the network bandwidth drops below the lowest encoded bitrate level. For this to work Bola needs to use the real buffer level without the additional virtualBuffer. Also, for this to work efficiently, we need to make sure that if the buffer level drops to one fragment during a download, the current download does not have more bits remaining than the size of one fragment at the lowest quality.
    maxRtt = 0.2; # TODO: is this reasonable?
    if (bolaObj.bolaBufferTarget == bolaObj.bufferTarget):
        bolaObj.safetyGuarantee = True
    else:
        bolaObj.safetyGuarantee = False
    if (bolaObj.safetyGuarantee):
        # TODO: document the math
        # we might need to adjust Vp and gp
        VpNew = bolaObj.Vp
        gpNew = bolaObj.gp
        for i in range(1,bitrateCount):
            threshold = VpNew * (gpNew - bolaObj.bitrates[0] * bolaObj.utility[i] / (bolaObj.bitrates[i] - bolaObj.bitrates[0]))
            minThreshold = bolaObj.video_segment_duration * (2.0 - bolaObj.bitrates[0] / bolaObj.bitrates[i]) + maxRtt
            if minThreshold >= bolaObj.bufferTarget:
                bolaObj.safetyGuarantee = False
                break

            if threshold < minThreshold:
                VpNew *= (bolaObj.bufferTarget - minThreshold) / (bolaObj.bufferTarget - threshold)
                gpNew = minThreshold / VpNew + bolaObj.utility[i] * bolaObj.bitrates[0] / (bolaObj.bitrates[i] - bolaObj.bitrates[0])


        if (bolaObj.safetyGuarantee) and (bolaObj.bufferTarget - bolaObj.video_segment_duration) * VpNew / bolaObj.Vp < config_dash.MINIMUM_BUFFER_LEVEL_SPACING:
            bolaObj.safetyGuarantee = False

        if bolaObj.safetyGuarantee:
            bolaObj.Vp = VpNew
            bolaObj.gp = gpNew



    # When using the virtualBuffer, it must be capped.
    # TODO: document the math
    bolaObj.bolaBufferMax = bolaObj.Vp * (bolaObj.utility[bitrateCount - 1] + bolaObj.gp)

    # Note: We either use the virtualBuffer or the safetyGuarantee, but not both.

    bolaObj.state                 = config_dash.BOLA_STATE_STARTUP

    bolaObj.bandwidthSafetyFactor = config_dash.BANDWIDTH_SAFETY_FACTOR

    bolaObj.lastQuality           = 0
    bolaObj.virtualBuffer         = 0.0
    bolaObj.throughputCount       = config_dash.AVERAGE_THROUGHPUT_SAMPLE_AMOUNT_VOD

        #if config_dash.BOLA_DEBUG:
    info = ''
    for i in range(0,(len(bolaObj.bitrates)-1)):
        ui  = bolaObj.utility[i]
        ui1 = bolaObj.utility[i + 1]
        ri  = bolaObj.bitrates[i]
        ri1 = bolaObj.bitrates[i + 1]
        th  = bolaObj.Vp * ((ui * ri1 - ui1 * ri) / (ri1 - ri) + bolaObj.gp)
        z = bolaObj.Vp * (ui + bolaObj.gp)
        info += str(i) + ':' + str(bolaObj.bitrates[i] / 1000000) + ' ' + str(th) + '/' + str(z) + ' '
        config_dash.LOG.info('BolaDebug: Utility %d is %f' %(i+1,bolaObj.utility[i]))
    info += ' ' + str(len(bolaObj.bitrates)- 1) + ':' + str(bolaObj.bitrates[len(bolaObj.bitrates)- 1] / 1000000) + ' -/' + str(bolaObj.Vp * (bolaObj.utility[len(bolaObj.bitrates)- 1] + bolaObj.gp))
    #config_dash.LOG.info('BolaDebug: bitrates %s' %info)


    return bolaObj,0.0


def getQualityFromBufferLevel(bolaObj, bufferLevel):
    bitrateCount = len(bolaObj.bitrates)
    #config_dash.LOG.info("BOLA: GetQualFromBuffer bitrate length=%d"%bitrateCount)
    quality = bitrateCount - 1
    score = 0.0
    for i in range(0,bitrateCount):
        s = (bolaObj.utility[i] + bolaObj.gp - bufferLevel / bolaObj.Vp) / bolaObj.bitrates[i]
        if s > score:
            score = s
            quality = i
        config_dash.LOG.info("BOLA:GetQualFromBuffer with %f Utility %f "%(bolaObj.utility[i],score))
    return quality

#Write function to get throughput (download rate) of most recent HTTP request
def getLastHttpRequests(metrics, count):
    allHttpRequests = dashMetrics.getHttpRequests(metrics)
    httpRequests = []
    for i in range(len(allHttpRequests)- 1,-1,--i): 
        request = allHttpRequests[i]
        if request.type is HTTPRequest.MEDIA_SEGMENT_TYPE and request._tfinish and request.tresponse and request.trace:
            httpRequests.append(request)
            if len(httpRequests)is count:
                break



    return httpRequests
def reduce_acc(a,b):
    return a+b.b[0]

def getLastThroughput(count, last_requests_start, last_requests_finish,last_requests_tput): # TODO: mediaType only used for debugging, remove it
    # TODO: Should we replace this with an average of the last few throughputs?
    lastRequests = last_requests_start
    if len(lastRequests) is 0:
        return 0.0


    totalInverse = 0.0
    downloadBits=0.0
    msg = ''
    for i in range(len(lastRequests)-1,len(lastRequests)):
        # The RTT delay results in a lower throughput. We can avoid this delay in the calculation, but we do not want to.
        downloadSeconds = (last_requests_finish[i] - lastRequests[i])
            
        for j in range (len(last_requests_tput)-1,len(last_requests_tput)):
            downloadBits+=last_requests_tput[j]
        #downloadBits = reduce((lambda x, y: x+y), last_requests_tput)
        downloadBits/=len(last_requests_tput)
        
        config_dash.LOG.info("%d Last Throughput %f"%((i),downloadBits))
        config_dash.LOG.info("%d Last Download Time %f"%((i),downloadSeconds))
        totalInverse += downloadSeconds / downloadBits

    #config_dash.LOG.info( 'BolaRule last throughput = %f' %(len(lastRequests)/ totalInverse / 1000000))

    return len(lastRequests)/ totalInverse


def getQualityFromThroughput(bolaObj, throughput):
    # do not factor in bandwidthSafetyFactor here - it is factored at point of call
    
    q = 0
    for i in range(1,len(bolaObj.bitrates)):
        if bolaObj.bitrates[i] > throughput:
            break

        q = i
    #config_dash.LOG.info("BOLA: Throughput  %f for Quality%d"%(throughput,q))
    return bolaObj.bitrates[q]


def getDelayFromLastFragmentInSeconds(last_requests_finish):
    lastRequests = last_requests_finish
    if len(lastRequests)is 0:
        return 0.0

    lastRequest = lastRequests[0]
    nowMilliSeconds = timeit.default_timer()
    lastRequestFinishMilliSeconds = lastRequest

    if lastRequestFinishMilliSeconds > nowMilliSeconds:
        # this shouldn't happen, try to handle gracefully
        lastRequestFinishMilliSeconds = nowMilliSeconds


    lct = lastRequests[len(lastRequests)-1]
    lastRequests[len(lastRequests)-1] = nowMilliSeconds
    delayMilliSeconds = 0.0
    if lct and lct > lastRequestFinishMilliSeconds:
        delayMilliSeconds = nowMilliSeconds - lct
    else:
        delayMilliSeconds = nowMilliSeconds - lastRequestFinishMilliSeconds


    if delayMilliSeconds < 0.0:
        return 0.0
    return 0.001 * delayMilliSeconds

'''
def onPlaybackSeeking():
    # TODO: Verify what happens if we seek mid-fragment.
    # TODO: If we have 10s fragments and seek, we would like to download the first fragment at a lower quality to restart playback quickly.
    for i = 0; i < seekMediaTypes.length; ++i:
        mediaType = seekMediaTypes[i]
        metrics = metricsModel.getReadOnlyMetricsFor(mediaType)
        if metrics.BolaState.length()is not 0:
            bolaState = metrics.BolaState[0]._s
            if bolaState.state is not BOLA_STATE_ONE_BITRATE:
                bolaState.state = BOLA_STATE_STARTUP

            metricsModel.updateBolaState(mediaType, bolaState)




def onPeriodSwitchStarted():
    # TODO

'''
def bola_dash(dash_player_buffer, segment_download_rate, curr_bitrate, last_requests_start, last_requests_finish, last_requests_tput, bolaObj):
    '''
    streamProcessor = rulesContext.getStreamProcessor()
    streamProcessor.getScheduleController().setTimeToLoadDelay(0.0)

    switchRequest = SwitchRequest(context).create(SwitchRequest.NO_CHANGE, SwitchRequest.WEAK)

    mediaInfo = rulesContext.getMediaInfo()
    mediaType = mediaInfo.type
    metrics = metricsModel.getReadOnlyMetricsFor(mediaType)
    '''
    dash_player_buffer+=bolaObj.bufferlen
    if len(last_requests_start) <= 2:
        # initialization

      
        config_dash.LOG.info("BOLA: buffer empty\n")
            #config_dash.LOG.info('BOLA: BolaRule for state=- fragmentStart=' + adapter.getIndexHandlerTime(rulesContext.getStreamProcessor()).toFixed(3))

        #state,bitrate,utility,Vp,gp,video_segment_duration,bandwidthSafetyFactor,bufferTarget,bufferMax,bolaBufferTarget, bolaBufferMax, safetyGuarantee,lastQuality, virtualBuffer,throughputCount = calculateInitialState(bitrates, segment_download_rate, curr_bitrate, state, video_segment_duration, vid_length)
    
        q = 0
        if bolaObj.state is not config_dash.BOLA_STATE_ONE_BITRATE:

           # seekMediaTypes.append(mediaType)

            # Bola is not invoked by dash.js to determine the bitrate quality for the first fragment. We might estimate the throughput level here, but the metric related to the HTTP request for the first fragment is usually not available.
            # TODO: at some point, we may want to consider a tweak that redownloads the first fragment at a higher quality

            initThroughput = segment_download_rate
            if initThroughput is 0.0:
                # We don't have information about any download yet - someone else decide quality.
                
                config_dash.LOG.info(' BolaRule quality unchanged for INITIALIZE')
                return
            
            q = getQualityFromThroughput(bolaObj, initThroughput * bolaObj.bandwidthSafetyFactor)
            
            bolaObj.lastQuality = q
            config_dash.LOG.info("BOLA:  Initial quality %d"%(bolaObj.lastQuality))
            #switchRequest = SwitchRequest(context).create(q, SwitchRequest.DEFAULT)
        

        #config_dash.LOG.debug(' BolaRule quality ' + q + ' for INITIALIZE')
        #callback(switchRequest)
        return bolaObj,0.0
    

    # metrics.BolaState.length()> 0
    #bolaState = metrics.BolaState[0]._s
    # TODO: does changing bolaState conform to coding style, or should we clone?
    config_dash.LOG.info("BOLA: InitState %d"%bolaObj.state)
    if bolaObj.state is config_dash.BOLA_STATE_ONE_BITRATE:
        config_dash.LOG.info('BolaRule quality 0 for ONE_BITRATE')
        #callback(switchRequest)
        return
    

    #config_dash.LOG.debug(' EXECUTE BolaRule for state=' + state + ' fragmentStart=' + adapter.getIndexHandlerTime(rulesContext.getStreamProcessor()).toFixed(3))

    bufferLevel = (dash_player_buffer+bolaObj.bufferlen)*bolaObj.video_segment_duration
    bolaQuality = bolaObj.bitrates[getQualityFromBufferLevel(bolaObj, bufferLevel)]
    lastThroughput = getLastThroughput(bolaObj.throughputCount, last_requests_start, last_requests_finish, last_requests_tput)

    config_dash.LOG.info(' BolaRule bufferLevel=%s \t lastThroughput=%f \t tentativequality %f'%(bufferLevel, (lastThroughput / 1000000.0), bolaQuality))
    if bufferLevel <= (0.1*config_dash.BOLA_BUFFER_SIZE*bolaObj.video_segment_duration):
        # rebuffering occurred, reset virtual buffer
        bolaObj.virtualBuffer = 0.0
    

    if not (bolaObj.safetyGuarantee): # we can use virtualBuffer
    # find out if there was delay because of lack of availability or because bolaBufferTarget > bufferTarget
     timeSinceLastDownload = getDelayFromLastFragmentInSeconds(last_requests_finish)
     if timeSinceLastDownload > 0.0: # TODO: maybe we should set some positive threshold here
        bolaObj.virtualBuffer += timeSinceLastDownload
    
     if bufferLevel + bolaObj.virtualBuffer > bolaObj.bolaBufferMax:
        bolaObj.virtualBuffer = bolaObj.bolaBufferMax - bufferLevel

     if bolaObj.virtualBuffer < 0.0:
        bolaObj.virtualBuffer = 0.0


    # update bolaQuality using virtualBuffer: bufferLevel might be artificially low because of lack of availability

     bolaQualityVirtual = getQualityFromBufferLevel(bolaObj,bufferLevel + bolaObj.virtualBuffer)
     if bolaQualityVirtual > bolaQuality:
        # May use quality higher than that indicated by real buffer level.

        # In this case, make sure there is enough throughput to download a fragment before real buffer runs out.

        maxQuality = bolaQuality
        while (maxQuality < bolaQualityVirtual and (bolaObj.bitrates[maxQuality + 1] * bolaObj.video_segment_duration) / (lastThroughput * bolaObj.bandwidthSafetyFactor) < bufferLevel):
            maxQuality+=1

        config_dash.LOG.info(' BolaRule bolaQualVirtual=%s \n'%bolaQualityVirtual)
        # TODO: maybe we can use a more conservative level here, but this should be OK

        if maxQuality > bolaQuality:
            # We can (and will) download at a quality higher than that indicated by real buffer level.
            if bolaQualityVirtual <= maxQuality:
                # we can download fragment indicated by real+virtual buffer without rebuffering
                bolaQuality = bolaObj.bitrates[bolaQualityVirtual]
            else:
                # downloading fragment indicated by real+virtual rebuffers, use lower quality
                bolaQuality = bolaObj.bitrates[maxQuality]
                # deflate virtual buffer to match quality
                # TODO: document the math
                targetBufferLevel = bolaObj.Vp * (bolaObj.gp + bolaObj.utility[maxQuality])
                if bufferLevel + bolaObj.virtualBuffer > targetBufferLevel:
                    bolaObj.virtualBuffer = targetBufferLevel - bufferLevel
                    if bolaObj.virtualBuffer < 0.0: # should be false
                        bolaObj.virtualBuffer = 0.0
                        
                    
                

    if bolaObj.state is config_dash.BOLA_STATE_STARTUP or bolaObj.state is config_dash.BOLA_STATE_STARTUP_NO_INC:
        # in startup phase, use some throughput estimation

        q = getQualityFromThroughput(bolaObj, lastThroughput * bolaObj.bandwidthSafetyFactor)

        if lastThroughput <= 0.0:
            # something went wrong - go to steady state
            bolaObj.state = config_dash.BOLA_STATE_STEADY
            config_dash.LOG.info('BOLA: BolaRule STATE READY')

        if bolaObj.state is config_dash.BOLA_STATE_STARTUP and q < bolaObj.lastQuality:
            # Since the quality is decreasing during startup, it will not be allowed to increase again.
            bolaObj.state = config_dash.BOLA_STATE_STARTUP_NO_INC
            config_dash.LOG.info('BOLA: BolaRule STATE STARTUP_NO_INC')

        if bolaObj.state is config_dash.BOLA_STATE_STARTUP_NO_INC and q > bolaObj.lastQuality:
            # In this state the quality is not allowed to increase until steady state.
            q = bolaObj.lastQuality
            config_dash.LOG.info('BOLA: BolaRule STATE STARTUP_NO_INC and qual increase')

        if q <= bolaQuality:
            # Since the buffer is full enough for steady state operation to match startup operation, switch over to steady state.
            bolaObj.state = config_dash.BOLA_STATE_STEADY
            config_dash.LOG.info('BOLA: BolaRule STATE READY and q non increasing')

        if bolaObj.state is not config_dash.BOLA_STATE_STEADY:
            # still in startup mode
            
            bolaObj.lastQuality = q
            config_dash.LOG.info('BOLA: BolaRule quality %d > for STARTUP' %bolaObj.lastQuality)
            
            #metricsModel.updateBolaState(mediaType, bolaState)
            #switchRequest = SwitchRequest(context).create(q, SwitchRequest.DEFAULT)
            #callback(switchRequest)
            return bolaObj, 0.0
        
    

    # steady state

    # we want to avoid oscillations
    # We implement the "BOLA-O" variant: when network bandwidth lies between two encoded bitrate levels, stick to the lowest level.
    
    delaySeconds = 0.0
    
    if config_dash.BOLAU == False:
    
     if bolaQuality > bolaObj.lastQuality:
        # do not multiply throughput by bandwidthSafetyFactor here: we are not using throughput estimation but capping bitrate to avoid oscillations
        q = getQualityFromThroughput(bolaObj, lastThroughput)
        if bolaQuality > q:
            # only intervene if we are trying to *increase* quality to an *unsustainable* level

            if q < bolaObj.lastQuality:
                # we are only avoid oscillations - do not drop below last quality
                q = bolaObj.lastQuality
            else:
                # We are dropping to an encoded bitrate which is a little less than the network bandwidth because bitrate levels are discrete. Quality q might lead to buffer inflation, so we deflate buffer to the level that q gives postive utility.
                wantBufferLevel = bolaObj.Vp * (bolaObj.utility[bolaObj.bitrates.index(q)] + bolaObj.gp)
                delaySeconds = bufferLevel - wantBufferLevel
            config_dash.LOG.info("BOLA: BufferLevel %f\t wantBufferLevel %f"%(bufferLevel,wantBufferLevel))
            bolaQuality = q
        config_dash.LOG.info("BOLA: qual_compare tput %f\t quality %d"%(lastThroughput,q))

    

     if delaySeconds > 0.0:
        # first reduce virtual buffer
        if delaySeconds > bolaObj.virtualBuffer:
            delaySeconds -= bolaObj.virtualBuffer
            bolaObj.virtualBuffer = 0.0
        else:
            bolaObj.virtualBuffer -= delaySeconds
            delaySeconds = 0.0
    
    
    '''
    if delaySeconds > 0.0:
        streamProcessor.getScheduleController().setTimeToLoadDelay(1000.0 * delaySeconds)
    '''

    bolaObj.lastQuality = bolaQuality
    #metricsModel.updateBolaState(mediaType, bolaState)
    #switchRequest = SwitchRequest(context).create(bolaQuality, SwitchRequest.DEFAULT)
    config_dash.LOG.info("BOLA: Final Delay %f and quality %d"%(delaySeconds,bolaObj.lastQuality))
    #callback(switchRequest)
    return bolaObj, delaySeconds

def bola_abandon(dash_player_buffer, current_chunk_dl_rate, last_requests_tput, bolaObj, start_time, current_time, segment_size, seg_sizes, chunk_dl_time):
    abandonReq = False
    
    quality = bolaObj.bitrates.index(bolaObj.lastQuality)
    estTputBSF = bolaObj.bandwidthSafetyFactor * current_chunk_dl_rate
    latencyS = (current_time-start_time)
    bytesTotal = seg_sizes[bolaObj.lastQuality]/8
    bytesRemaining = seg_sizes[bolaObj.lastQuality]/8 - segment_size 
    effectiveBufferLevel = (dash_player_buffer + bolaObj.bufferlen + bolaObj.virtualBuffer)*bolaObj.video_segment_duration
    
    if latencyS < config_dash.POOR_LATENCY_MS:
        latencyS = config_dash.POOR_LATENCY_MS
    estimatedTime = latencyS + 8*segment_size / estTputBSF
    estBytesTot =  bytesTotal * (bolaObj.bitrates[0]/bolaObj.bitrates[quality])/8
    estimateBytesRemainingAfterLatency = bytesRemaining - latencyS * estTputBSF/8
    if (estimateBytesRemainingAfterLatency < 15000):
            estimateBytesRemainingAfterLatency = 15000
    
    if (chunk_dl_time < config_dash.GRACE_PERIOD_MS or bytesRemaining <= estBytesTot or dash_player_buffer > bolaObj.bufferTarget or estimateBytesRemainingAfterLatency <= estBytesTot or estimatedTime <= bolaObj.video_segment_duration):
        config_dash.LOG.info("BOLA: Stay at current quality")
        return abandonReq, bolaObj
    else:
        config_dash.LOG.info("BOLA: Switch quality")
        effectiveBufferAfterLatency = effectiveBufferLevel - latencyS
        
        maxQualityAllowed = quality
        estimateTimeRemainSeconds = 8*bytesRemaining / estTputBSF
        if estimateTimeRemainSeconds > (dash_player_buffer + bolaObj.bufferlen)*bolaObj.video_segment_duration:
            maxQualityAllowed-=1
            while (maxQualityAllowed > 0):
                estBytesTot = bytesTotal * bolaObj.bitrates[maxQualityAllowed] / bolaObj.bitrates[quality]/8;
                estimateTimeRemainSeconds = latencyS + 8*estBytesTot / estTputBSF;
                if estimateTimeRemainSeconds <= dash_player_buffer:
                    break
            
                maxQualityAllowed-=1;
    
        bufferAfterRtt = (dash_player_buffer + bolaObj.bufferlen + bolaObj.virtualBuffer)*bolaObj.video_segment_duration - latencyS
        
        newQuality = quality
        score = (bolaObj.Vp * (bolaObj.utility[quality] + bolaObj.gp) - effectiveBufferAfterLatency) / estimateBytesRemainingAfterLatency 
        for i in range (0, quality):
            estBytesTot = bytesTotal * bolaObj.bitrates[i] / bolaObj.bitrates[quality];
            if (estBytesTot > estimateBytesRemainingAfterLatency):
                break
            s = (bolaObj.utility[i] + bolaObj.gp - bufferAfterRtt / bolaObj.Vp) / estBytesTot;
            if (s > score):
                newQuality = i;
                score = s;
         
        #compare with maximum allowed quality that shouldn't lead to rebuffering
        if (newQuality > maxQualityAllowed):
            newQuality = maxQualityAllowed
        

        if (newQuality == quality):
            abandonReq = False
            return abandonReq, bolaObj
        

        #Abandon, but to which quality? Abandoning should not happen often, and it's OK to be more conservative when it does.
        

        
        while (newQuality > 0 and bolaObj.bitrates[newQuality] > estTputBSF):
            newQuality-=1 
        bolaObj.lastQuality = bolaObj.bitrates[newQuality]
        abandonReq = True
    return abandonReq, bolaObj
'''
def reset(:
    eventBus.off(Events.PLAYBACK_SEEKING, onPlaybackSeeking, instance)
    eventBus.off(Events.PERIOD_SWITCH_STARTED, onPeriodSwitchStarted, instance)
    setup()


instance = {
    execute: execute,
    reset: reset
}

setup()
return instance


BolaRule.__dashjs_factory_name = 'BolaRule'
factory = FactoryMaker.getClassFactory(BolaRule)
factory.BOLA_STATE_ONE_BITRATE    = BOLA_STATE_ONE_BITRATE
factory.BOLA_STATE_STARTUP        = BOLA_STATE_STARTUP
factory.BOLA_STATE_STARTUP_NO_INC = BOLA_STATE_STARTUP_NO_INC
factory.BOLA_STATE_STEADY         = BOLA_STATE_STEADY
factory.BOLA_DEBUG = BOLA_DEBUG; # TODO: remove
export default factory
'''

