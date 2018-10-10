#The following is a sample Controller code which uses th switch_ready API that RYU provides to statically install rules when the controller is started

from ryu.base import app_manager
from ryu.controller import ofp_event
from ryu.controller.handler import MAIN_DISPATCHER, CONFIG_DISPATCHER
from ryu.controller.handler import set_ev_cls
from ryu.ofproto import ofproto_v1_0
from ryu.ofproto import ofproto_v1_2
from ryu.ofproto import ofproto_v1_3
from ryu.lib.mac import haddr_to_bin
from ryu.lib.packet import packet
from ryu.lib.packet import ethernet
from ryu.lib.packet import ether_types
from ryu.lib.packet import ethernet
from ryu.lib.packet import ipv4
from ryu.lib.packet import icmp

class NDNRouter(app_manager.RyuApp):
    OFP_VERSIONS = [ofproto_v1_0.OFP_VERSION]

    def __init__(self, *args, **kwargs):
        super(NDNRouter, self).__init__(*args, **kwargs)
        self.mac_to_port = {}
        self.NDN_to_port = {}

    def add_flow(self, datapath, in_port, dst, actions):
        ofproto = datapath.ofproto

        match = datapath.ofproto_parser.OFPMatch(
            in_port=in_port, dl_dst=haddr_to_bin(dst))

        mod = datapath.ofproto_parser.OFPFlowMod(
            datapath=datapath, match=match, cookie=0,
            command=ofproto.OFPFC_ADD, idle_timeout=0, hard_timeout=0,
            priority=ofproto.OFP_DEFAULT_PRIORITY,
            flags=ofproto.OFPFF_SEND_FLOW_REM, actions=actions)
        datapath.send_msg(mod)

    def add_ipflow(self, datapath, in_port, dst, actions):
        ofproto = datapath.ofproto

        match = datapath.ofproto_parser.OFPMatch(
            in_port=in_port)
        mod = datapath.ofproto_parser.OFPFlowMod(
            datapath=datapath, match=match, cookie=0,
            command=ofproto.OFPFC_ADD, idle_timeout=0, hard_timeout=0,
            priority=ofproto.OFP_DEFAULT_PRIORITY,
            flags=ofproto.OFPFF_SEND_FLOW_REM, actions=actions)
        datapath.send_msg(mod)

    @set_ev_cls(ofp_event.EventOFPSwitchFeatures, CONFIG_DISPATCHER)
    def switch_features_handler(self, ev):
        datapath = ev.msg.datapath
        ofproto = datapath.ofproto
        parser = datapath.ofproto_parser

        # install table-miss flow entry
        #
        # We specify NO BUFFER to max_len of the output action due to
        # OVS bug. At this moment, if we specify a lesser number, e.g.,
        # 128, OVS will send Packet-In with invalid buffer_id and
        # truncated packet data. In that case, we cannot output packets
        # correctly.  The bug has been fixed in OVS v2.1.0.
        # Router1
        print datapath.id
        if datapath.id == 77781502685763:
            #Following are for NDN Packets
            match = parser.OFPMatch(in_port=8, dl_type=0x8624)
            out_port = 7
            actions = [datapath.ofproto_parser.OFPActionOutput(out_port)]
            self.add_ipflow(datapath, 8, match, actions)
            match = parser.OFPMatch(in_port=7, dl_type=0x8624)
            out_port = 8
            actions = [datapath.ofproto_parser.OFPActionOutput(out_port)]
            self.add_ipflow(datapath, 7, match, actions)

            match = parser.OFPMatch(in_port=9, dl_type=0x8624)
            out_port = 6
            actions = [datapath.ofproto_parser.OFPActionOutput(out_port)]
            self.add_ipflow(datapath, 9, match, actions)
            match = parser.OFPMatch(in_port=6, dl_type=0x8624)
            out_port = 9
            actions = [datapath.ofproto_parser.OFPActionOutput(out_port)]
            self.add_ipflow(datapath, 6, match, actions)

            match = parser.OFPMatch(in_port=14, dl_type=0x8624)
            out_port = 13
            actions = [datapath.ofproto_parser.OFPActionOutput(out_port)]
            self.add_ipflow(datapath, 14, match, actions)
            match = parser.OFPMatch(in_port=13, dl_type=0x8624)
            out_port = 14
            actions = [datapath.ofproto_parser.OFPActionOutput(out_port)]
            self.add_ipflow(datapath, 13, match, actions)

            #Following are for IPv4 Packets
            match = parser.OFPMatch(in_port=8, dl_type=0x0800)
            out_port = 7
            actions = [datapath.ofproto_parser.OFPActionOutput(out_port)]
            self.add_ipflow(datapath, 8, match, actions)
            match = parser.OFPMatch(in_port=7, dl_type=0x0800)
            out_port = 8
            actions = [datapath.ofproto_parser.OFPActionOutput(out_port)]
            self.add_ipflow(datapath, 7, match, actions)
        print datapath.id
        # Router2
        if datapath.id == 77781502685763:
            #Following are for NDN Packets
            match = parser.OFPMatch(in_port=8, dl_type=0x8624)
            out_port = 7
            actions = [datapath.ofproto_parser.OFPActionOutput(out_port)]
            self.add_ipflow(datapath, 8, match, actions)
            match = parser.OFPMatch(in_port=7, dl_type=0x8624)
            out_port = 8
            actions = [datapath.ofproto_parser.OFPActionOutput(out_port)]
            self.add_ipflow(datapath, 7, match, actions)

            match = parser.OFPMatch(in_port=9, dl_type=0x8624)
            out_port = 6
            actions = [datapath.ofproto_parser.OFPActionOutput(out_port)]
            self.add_ipflow(datapath, 9, match, actions)
            match = parser.OFPMatch(in_port=6, dl_type=0x8624)
            out_port = 9
            actions = [datapath.ofproto_parser.OFPActionOutput(out_port)]
            self.add_ipflow(datapath, 6, match, actions)

            match = parser.OFPMatch(in_port=14, dl_type=0x8624)
            out_port = 13
            actions = [datapath.ofproto_parser.OFPActionOutput(out_port)]
            self.add_ipflow(datapath, 14, match, actions)
            match = parser.OFPMatch(in_port=13, dl_type=0x8624)
            out_port = 14
            actions = [datapath.ofproto_parser.OFPActionOutput(out_port)]
            self.add_ipflow(datapath, 13, match, actions)

            #Following are for IPv4 Packets
            match = parser.OFPMatch(in_port=8, dl_type=0x0800)
            out_port = 7
            actions = [datapath.ofproto_parser.OFPActionOutput(out_port)]
            self.add_ipflow(datapath, 8, match, actions)
            match = parser.OFPMatch(in_port=7, dl_type=0x0800)
            out_port = 8
            actions = [datapath.ofproto_parser.OFPActionOutput(out_port)]
            self.add_ipflow(datapath, 7, match, actions)


                                                                                                                              
                                                                               
