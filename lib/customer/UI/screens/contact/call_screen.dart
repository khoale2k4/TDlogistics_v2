// import 'package:flutter/material.dart';
// import 'package:flutter_webrtc/flutter_webrtc.dart';
// import 'package:firebase_database/firebase_database.dart';

// class CallScreen extends StatefulWidget {
//   final String callId; // Unique ID cho cuộc gọi
//   final bool isCaller; // Để phân biệt giữa người gọi và người nhận

//   const CallScreen({
//     Key? key,
//     required this.callId,
//     required this.isCaller,
//   }) : super(key: key);

//   @override
//   State<CallScreen> createState() => _CallScreenState();
// }

// class _CallScreenState extends State<CallScreen> {
//   final DatabaseReference dbRef = FirebaseDatabase.instance.ref();
//   RTCPeerConnection? _peerConnection;
//   RTCVideoRenderer _localRenderer = RTCVideoRenderer();
//   RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
//   MediaStream? _localStream;

//   @override
//   void initState() {
//     super.initState();
//     _initializeRenderers();
//     _initializeCall();
//   }

//   @override
//   void dispose() {
//     _localRenderer.dispose();
//     _remoteRenderer.dispose();
//     _peerConnection?.close();
//     _peerConnection?.dispose();
//     super.dispose();
//   }

//   // Khởi tạo video renderer
//   Future<void> _initializeRenderers() async {
//     await _localRenderer.initialize();
//     await _remoteRenderer.initialize();
//   }

//   // Bắt đầu cuộc gọi
//   Future<void> _initializeCall() async {
//     _peerConnection = await createPeerConnection();

//     // Xử lý stream video
//     _localStream = await _createLocalStream();
//     _localRenderer.srcObject = _localStream;

//     _localStream?.getTracks().forEach((track) {
//       _peerConnection?.addTrack(track, _localStream!);
//     });

//     _peerConnection?.onTrack = (RTCTrackEvent event) {
//       if (event.streams.isNotEmpty) {
//         _remoteRenderer.srcObject = event.streams[0];
//       }
//     };

//     _peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
//       _sendIceCandidate(candidate, widget.isCaller ? "caller" : "receiver");
//     };

//     if (widget.isCaller) {
//       await _startCall();
//     } else {
//       _listenForOffer();
//     }

//     _listenForIceCandidates();
//   }

//   // Tạo PeerConnection
//   Future<RTCPeerConnection> createPeerConnection() async {
//     final configuration = {
//       'iceServers': [
//         {'urls': 'stun:stun.l.google.com:19302'}
//       ]
//     };

//     final constraints = {
//       'mandatory': {
//         'OfferToReceiveAudio': true,
//         'OfferToReceiveVideo': true,
//       },
//       'optional': [],
//     };

//     return await createPeerConnection();
//   }

//   // Tạo MediaStream
//   Future<MediaStream> _createLocalStream() async {
//     final Map<String, dynamic> mediaConstraints = {
//       'audio': true,
//       'video': true,
//     };

//     return await navigator.mediaDevices.getUserMedia(mediaConstraints);
//   }

//   // Bắt đầu cuộc gọi (Caller)
//   Future<void> _startCall() async {
//     final offer = await _peerConnection?.createOffer();
//     await _peerConnection?.setLocalDescription(offer!);

//     await dbRef.child('calls/${widget.callId}/offer').set({
//       'type': offer?.type,
//       'sdp': offer?.sdp,
//     });
//   }

//   // Lắng nghe offer (Receiver)
//   void _listenForOffer() {
//     dbRef.child('calls/${widget.callId}/offer').onValue.listen((event) async {
//       final data = event.snapshot.value as Map?;
//       if (data != null) {
//         final offer = RTCSessionDescription(data['sdp'], data['type']);
//         await _peerConnection?.setRemoteDescription(offer);

//         // Tạo answer
//         final answer = await _peerConnection?.createAnswer();
//         await _peerConnection?.setLocalDescription(answer!);

//         // Lưu answer lên Firebase
//         await dbRef.child('calls/${widget.callId}/answer').set({
//           'type': answer?.type,
//           'sdp': answer?.sdp,
//         });
//       }
//     });
//   }

//   // Lắng nghe answer (Caller)
//   void _listenForAnswer() {
//     dbRef.child('calls/${widget.callId}/answer').onValue.listen((event) async {
//       final data = event.snapshot.value as Map?;
//       if (data != null) {
//         final answer = RTCSessionDescription(data['sdp'], data['type']);
//         await _peerConnection?.setRemoteDescription(answer);
//       }
//     });
//   }

//   // Lắng nghe ICE Candidates
//   void _listenForIceCandidates() {
//     final role = widget.isCaller ? "receiver" : "caller";

//     dbRef.child('calls/${widget.callId}/candidates/$role').onChildAdded.listen((event) {
//       final data = event.snapshot.value as Map?;
//       if (data != null) {
//         final candidate = RTCIceCandidate(
//           data['candidate'],
//           data['sdpMid'],
//           data['sdpMLineIndex'],
//         );
//         _peerConnection?.addCandidate(candidate);
//       }
//     });
//   }

//   // Gửi ICE Candidate
//   void _sendIceCandidate(RTCIceCandidate candidate, String role) {
//     dbRef.child('calls/${widget.callId}/candidates/$role').push().set({
//       'candidate': candidate.candidate,
//       'sdpMLineIndex': candidate.sdpMLineIndex,
//       'sdpMid': candidate.sdpMid,
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         title: const Text("Video Call"),
//         backgroundColor: Colors.black,
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: RTCVideoView(_remoteRenderer),
//           ),
//           Expanded(
//             child: RTCVideoView(_localRenderer, mirror: true),
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               ElevatedButton(
//                 onPressed: () {
//                   _peerConnection?.close();
//                   Navigator.pop(context);
//                 },
//                 style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//                 child: const Text("End Call"),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
