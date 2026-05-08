import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'uploaddonatepage.dart';
import 'chatpage.dart';

// ================= SNACKBAR =================
void MySnackBar(message, context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message, textAlign: TextAlign.center),

      backgroundColor: Colors.deepPurple,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}

// ================= COMMENT WIDGET (RESCUE STYLE) =================
class CommentWidget extends StatefulWidget {
  final String postId;
  final String currentUserId;
  final String currentUserName;

  const CommentWidget({
    super.key,
    required this.postId,
    required this.currentUserId,
    required this.currentUserName,
  });

  @override
  State<CommentWidget> createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  final TextEditingController _commentController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void sendComment() async {
    String text = _commentController.text.trim();
    if (text.isEmpty) return;

    await _firestore
        .collection("donate_pets")
        .doc(widget.postId)
        .collection("comments")
        .add({
          "userId": widget.currentUserId,
          "userName": widget.currentUserName,
          "text": text,
          "timestamp": FieldValue.serverTimestamp(),
        });

    _commentController.clear();
  }

  // ================= Delete Comment =================
  Future<void> deleteComment(String commentId) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Comment?"),
        content: const Text("Are you sure you want to delete this comment?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Yes"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _firestore
          .collection("donate_pets")
          .doc(widget.postId)
          .collection("comments")
          .doc(commentId)
          .delete();

      MySnackBar("Comment deleted", context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 150),
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection("donate_pets")
                .doc(widget.postId)
                .collection("comments")
                .orderBy("timestamp", descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox();

              var comments = snapshot.data!.docs;

              if (comments.isEmpty) {
                return const Center(child: Text("No comments yet"));
              }

              return ListView.builder(
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  var comment = comments[index];
                  bool isMe = comment["userId"] == widget.currentUserId;

                  return Row(
                    mainAxisAlignment: isMe
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.all(4),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isMe
                              ? Colors.blue[200]
                              : const Color.fromARGB(255, 243, 243, 243),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "${comment["userName"]}: ${comment["text"]}",
                        ),
                      ),

                      if (isMe)
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                            size: 18,
                          ),
                          onPressed: () => deleteComment(comment.id),
                        ),
                    ],
                  );
                },
              );
            },
          ),
        ),

        const SizedBox(height: 5),

        // ================= INPUT =================
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _commentController,
                decoration: const InputDecoration(
                  hintText: "Write comment...",
                  hintStyle: TextStyle(color: Colors.black),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send, color: Colors.blue),
              onPressed: sendComment,
            ),
          ],
        ),
      ],
    );
  }
}

// ================= DONATE PAGE =================
class DonatePage extends StatelessWidget {
  final String userId;
  final String userName;

  const DonatePage({super.key, required this.userId, required this.userName});

  Future<void> deletePost(
    String docId,
    String imageUrl,
    BuildContext context,
  ) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete This Post?"),
        content: const Text("Are you sure?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Yes"),
          ),
        ],
      ),
    );
    if (confirm) {
      if (imageUrl != null && imageUrl.isNotEmpty) {
        final ref = FirebaseStorage.instance.refFromURL(imageUrl);
        await ref.delete();
      }

      await FirebaseFirestore.instance
          .collection("donate_pets")
          .doc(docId)
          .delete();

      MySnackBar("Deleted successfully", context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Donate Pets"),
        elevation: 5,
        shadowColor: const Color.fromARGB(254, 254, 254, 254),
        surfaceTintColor: Colors.transparent,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("donate_pets")
            .orderBy("uploadedAt", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var posts = snapshot.data!.docs;

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              var doc = posts[index];
              String docId = doc.id;

              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

              String imgUrl = data["imgurl"] ?? "";
              String user = data["userName"] ?? "Unknown";
              String location = data["location"] ?? "Unknown location";
              String problem = data["problem"] ?? "";
              String amount = data["needed_amount"]?.toString() ?? "0";
              String ownerId = data["userId"] ?? "";

              return Card(
                color: const Color.fromARGB(164, 214, 214, 214),
                elevation: 7,
                margin: const EdgeInsets.all(13),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ================= USER INFO =================
                    ListTile(
                      leading: FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection("users")
                            .doc(ownerId)
                            .get(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData || !snapshot.data!.exists) {
                            return const CircleAvatar(
                              child: Icon(Icons.person),
                            );
                          }

                          var userData =
                              snapshot.data!.data() as Map<String, dynamic>;

                          String profileImage = userData["profileImage"] ?? "";

                          return CircleAvatar(
                            backgroundImage: profileImage.isNotEmpty
                                ? NetworkImage(profileImage)
                                : null,
                            child: profileImage.isEmpty
                                ? const Icon(Icons.person)
                                : null,
                          );
                        },
                      ),

                      title: Text(user),

                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (ownerId == userId)
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () =>
                                  deletePost(docId, imgUrl, context),
                            ),

                          IconButton(
                            icon: const Icon(Icons.chat, color: Colors.blue),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatPage(
                                    currentUserId: userId,
                                    otherUserId: ownerId,
                                    otherUserName: user,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    // ================= IMAGE =================
                    imgUrl.isNotEmpty
                        ? Image.network(
                            imgUrl,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : const SizedBox(),

                    // ================= PROBLEM =================
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        problem,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),

                    // ================= LOCATION =================
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          Text(
                            "Location: ",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Icon(
                            Icons.location_on,
                            size: 16,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 5),
                          Text(location, style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 5),

                    // ================= AMOUNT =================
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        "Need: $amount Tk",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // ================= COMMENTS =================
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: CommentWidget(
                        postId: docId,
                        currentUserId: userId,
                        currentUserName: userName,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),

      // ================= FLOATING BUTTON =================
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.upload),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  UploadDonatePage(userId: userId, userName: userName),
            ),
          );
        },
      ),
    );
  }
}
