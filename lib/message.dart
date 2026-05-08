import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class MessagePage extends StatefulWidget {
  final String currentUserEmail;
  final String receiverEmail;
  final String receiverName;

  const MessagePage({
    super.key,
    required this.currentUserEmail,
    required this.receiverEmail,
    required this.receiverName,
  });

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  // Controller for message input field
  final TextEditingController messageController = TextEditingController();

  /// Send message to Firestore
  Future<void> sendMessage() async {
    if (messageController.text.trim().isEmpty) return;

    await FirebaseFirestore.instance.collection("messages").add({
      "senderEmail": widget.currentUserEmail,
      "receiverEmail": widget.receiverEmail,
      "message": messageController.text.trim(),
      "time": FieldValue.serverTimestamp(),
    });
    // Clear input after sending
    messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:
          true, // mobile er keyboard er jonno Adjust UI when keyboard appears
      appBar: AppBar(
        title: Text(widget.receiverName),
        elevation: 5,
        shadowColor: const Color.fromARGB(254, 254, 254, 254),
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),

            /// Message list section
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("messages")
                    .orderBy("time")
                    .snapshots(),
                builder: (context, snapshot) {
                  // Loading state
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Filter messages between the two users
                  var messages = snapshot.data!.docs.where((doc) {
                    return (doc["senderEmail"] == widget.currentUserEmail &&
                            doc["receiverEmail"] == widget.receiverEmail) ||
                        (doc["senderEmail"] == widget.receiverEmail &&
                            doc["receiverEmail"] == widget.currentUserEmail);
                  }).toList();
                  // Display messages
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: messages.map((msg) {
                        bool isMe =
                            msg["senderEmail"] == widget.currentUserEmail;

                        return MessageBubble(
                          message: msg["message"],
                          isMe: isMe,
                          senderEmail: msg["senderEmail"],
                          time: msg["time"],
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ),

            /// Message input field
            MessageInput(controller: messageController, onSend: sendMessage),
          ],
        ),
      ),
    );
  }
}

/// Message Bubble Widget
/// Displays individual chat messages
class MessageBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final String senderEmail;
  final Timestamp? time;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.senderEmail,
    this.time,
  });

  /// Format timestamp to readable time
  String formatTime(Timestamp? timestamp) {
    if (timestamp == null) return "";
    return DateFormat('hh:mm a').format(timestamp.toDate());
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: TextStyle(color: isMe ? Colors.white : Colors.black),
            ),
            const SizedBox(height: 4),
            // Sender + time info
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isMe)
                  Text(
                    senderEmail,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                if (!isMe) const SizedBox(width: 5),
                Text(
                  formatTime(time),
                  style: const TextStyle(fontSize: 12, color: Colors.black45),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Message Input Widget
/// Handles user text input and send button
class MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const MessageInput({
    super.key,
    required this.controller,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 0, 5, 20),
      child: Row(
        children: [
          // Text input field
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: "Type a message...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0),
                    bottomRight: Radius.circular(20.0),
                    bottomLeft: Radius.circular(20.0),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 5),
          // Send button
          IconButton(
            icon: const Icon(Icons.send, color: Colors.deepPurple),
            onPressed: onSend,
          ),
        ],
      ),
    );
  }
}
