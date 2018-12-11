// Version 0.0 : dns and multisteps, lw and hw are all in the same instance
// For userlevel experiments

define($DNS_MAX_LEN 10)
define($DNS_EXPIRE  10)
define($DNS_THRSHLD 50)
define($PERFLOW_EXPIRE 300)
define($FROM_DEV clan1)

tcp_or_udp :: IPClassifier (
    tcp,
    udp,
    -)

tcp_classifier :: TCPClassifier()
udp_classifier :: UDPClassifier()

// Notice, I set the OUTBOUND to 1 to enable the pcap to capture the both in and out pacet. See elements/userlevel/fromdevice.cc in details.
FromDevice(click_v_1, OUTBOUND 1) -> SetTimestamp -> CheckIPHeader(14) -> PerFlowAnalysis(expire $PERFLOW_EXPIRE) -> IPReassembler() -> GeneveEncap(opt_len 4) -> tcp_or_udp

tcp_or_udp[0] -> CheckTCPHeader() -> tcp_classifier
tcp_or_udp[1] -> CheckUDPHeader() -> udp_classifier -> Discard
tcp_or_udp[2] -> Discard

mltstp_lw_detector :: MLTSTP_LW_DETECTOR(expire 100)

tcp_classifier[0] -> [0] mltstp_lw_detector [0] -> HTTPAnalyzer() -> Discard
tcp_classifier[1] -> [1] mltstp_lw_detector [1] -> FTPAnalyzer() -> Discard
tcp_classifier[2] -> [2] mltstp_lw_detector [2] -> SSHAnalyzer() -> Discard

