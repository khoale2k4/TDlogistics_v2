import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';

class P2PVoiceChat extends StatefulWidget {
  final WebSocketChannel signalingChannel;

  const P2PVoiceChat({super.key, required this.signalingChannel});

  @override
  _P2PVoiceChatState createState() => _P2PVoiceChatState();
}

class _P2PVoiceChatState extends State<P2PVoiceChat> {
  RTCPeerConnection? _peerConnection;
  RTCDataChannel? _dataChannel;
  MediaStream? _localStream;
  final _remoteRenderer = RTCVideoRenderer();

  @override
  void initState() {
    super.initState();
    _initRenderer();
    _createPeerConnection();
  }

  Future<void> _initRenderer() async {
    await _remoteRenderer.initialize();
  }

  Future<void> _createPeerConnection() async {
    // Tạo PeerConnection
    _peerConnection = await createPeerConnection(_iceServers);

    // Lắng nghe ICE candidate
    _peerConnection!.onIceCandidate = (candidate) {
      widget.signalingChannel.sink.add(jsonEncode({
        'type': 'candidate',
        'candidate': candidate.toMap(),
      }));
    };

    // Lắng nghe kết nối stream từ peer
    _peerConnection!.onAddStream = (stream) {
      setState(() {
        _remoteRenderer.srcObject = stream;
      });
    };

    // Lấy stream audio từ microphone
    _localStream = await _getUserMedia();
    _peerConnection!.addStream(_localStream!);

    // Thiết lập data channel (nếu muốn)
    _dataChannel = await _peerConnection!.createDataChannel('data', RTCDataChannelInit());

    // Xử lý sự kiện nhận được tin nhắn từ data channel
    _dataChannel!.onMessage = (RTCDataChannelMessage message) {
      print('Received: ${message.text}');
    };

    // Trao đổi SDP (Session Description)
    var offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);

    widget.signalingChannel.sink.add(jsonEncode({
      'type': 'offer',
      'sdp': offer.sdp,
    }));
  }

  // Nhận media stream từ microphone
  Future<MediaStream> _getUserMedia() async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': false,
    };
    return await navigator.mediaDevices.getUserMedia(mediaConstraints);
  }

  // Xử lý khi nhận được SDP offer từ peer khác
  void _onOfferReceived(String sdp) async {
    var description = RTCSessionDescription(sdp, 'offer');
    await _peerConnection!.setRemoteDescription(description);
    var answer = await _peerConnection!.createAnswer();
    await _peerConnection!.setLocalDescription(answer);

    widget.signalingChannel.sink.add(jsonEncode({
      'type': 'answer',
      'sdp': answer.sdp,
    }));
  }

  // Xử lý khi nhận được SDP answer từ peer khác
  void _onAnswerReceived(String sdp) async {
    var description = RTCSessionDescription(sdp, 'answer');
    await _peerConnection!.setRemoteDescription(description);
  }

  // Xử lý khi nhận được ICE candidate
  void _onCandidateReceived(Map<String, dynamic> candidateMap) async {
    var candidate = RTCIceCandidate(
      candidateMap['candidate'],
      candidateMap['sdpMid'],
      candidateMap['sdpMLineIndex'],
    );
    await _peerConnection!.addCandidate(candidate);
  }

  @override
  void dispose() {
    _localStream?.dispose();
    _remoteRenderer.dispose();
    _peerConnection?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("P2P Voice Chat")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.call),
              onPressed: () {
                // Gọi chức năng kết nối
                _createPeerConnection();
              },
            ),
            Expanded(
              child: RTCVideoView(_remoteRenderer),
            ),
          ],
        ),
      ),
    );
  }

  // Các ICE servers cần thiết để hỗ trợ kết nối P2P
  final Map<String, dynamic> _iceServers = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'}, // Sử dụng STUN server của Google
    ]
  };
}
