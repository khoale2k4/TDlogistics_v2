import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../../core/signaling.dart';
import 'package:tdlogistic_v2/core/constant.dart';

class ChatBox extends StatefulWidget {
  const ChatBox({super.key});

  @override
  _ChatBoxState createState() => _ChatBoxState();
}

class _ChatBoxState extends State<ChatBox> {
  List<String> role = ["Caller", "Receiver"];
  int roleNum = 0;
  bool openAudio = true;
  Signaling signaling = Signaling();
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  String? roomId;
  TextEditingController textEditingController = TextEditingController(text: '');
  TextEditingController messageController = TextEditingController();
  List<Map<String, dynamic>> messages = [];
  bool userJoined = false;
  bool isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _localRenderer.initialize();
    _remoteRenderer.initialize();

    signaling.onAddRemoteStream = ((stream) {
      setState(() {
        _remoteRenderer.srcObject = stream;
      });
    });

    signaling.onMessageReceived = (message) {
      setState(() {
        messages.add(message);
      });
    };

    signaling.onUserJoined = () {
      setState(() {
        userJoined = true;
        print("Someone entered the room");
      });
    };

    signaling.onSpeakingDetected = (isUserSpeaking) {
      setState(() {
        isSpeaking = isUserSpeaking;
      });
    };
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  void startDetectingSpeech() {
    Future.delayed(const Duration(seconds: 1), () {
      signaling.detectSpeaking();
      startDetectingSpeech();
      print("checking");
    });
  }

  void sendMessage() {
    if (roomId != null && messageController.text.isNotEmpty) {
      signaling.sendMessage(roomId!, messageController.text, role[roleNum]);
      messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tin nhắn"),
      ),
      body: Padding(padding: const EdgeInsets.all(20),child:
      Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  roleNum = 0;
                  roomId = await signaling.createRoom(_remoteRenderer);
                  textEditingController.text = roomId!;
                  signaling.listenForMessages(roomId!);
                  setState(() {});
                  startDetectingSpeech();
                },
                child: const Text("Create room"),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  roleNum = 1;
                  if (textEditingController.text.isNotEmpty) {
                    roomId = textEditingController.text.trim();
                    signaling.joinRoom(roomId!, _remoteRenderer);
                    signaling.listenForMessages(roomId!);
                    startDetectingSpeech();
                  }
                },
                child: const Text("Join room"),
              ),
            ],
          ),
          if (userJoined)
            const Text("A user has joined the room",
                style: TextStyle(color: Colors.green)),
          if (isSpeaking)
            const Text("Someone is speaking",
                style: TextStyle(color: mainColor)),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Join the following Room: "),
                Flexible(
                  child: TextFormField(controller: textEditingController),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return Row(
                  mainAxisAlignment: messages[index]["sender"] == role[roleNum]
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: [
                    ChatMessage(msg: messages[index]["message"]),
                  ],
                );
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: messageController,
                  decoration: const InputDecoration(labelText: "Enter message"),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: sendMessage,
              ),
            ],
          ),
        ],
      ),),
    );
  }
}
// userJoined?
//             CircleAvatar(
//               radius: 20,
//               backgroundColor:
//                   isSpeaking ? Colors.green.shade200 : mainColor.shade200,
//               child: Icon(
//                 Icons.mic,
//                 color: isSpeaking ? Colors.green : mainColor,
//               ),
//             )
//           :Container(),

class ChatMessage extends StatelessWidget {
  final String msg;
  const ChatMessage({super.key, required this.msg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(35),
      ),
      child: Text(msg),
    );
  }
}
