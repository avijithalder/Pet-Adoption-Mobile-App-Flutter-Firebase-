import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'uploadpetpage.dart';
import 'chatpage.dart';

// ================= MySnackBar =================
void MySnackBar(String message, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.deepPurple,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}

// ================= CommentWidget =================
class CommentWidget extends StatefulWidget {
  final String petId;
  final String currentUserId;
  final String currentUserName;

  const CommentWidget({
    super.key,
    required this.petId,
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
        .collection("user_pets")
        .doc(widget.petId)
        .collection("comments")
        .add({
          "userId": widget.currentUserId,
          "userName": widget.currentUserName,
          "text": text,
          "timestamp": FieldValue.serverTimestamp(),
        });

    _commentController.clear();
  }
  // ================= Comment Delete Dialog =================

  void deleteComment(String commentId) async {
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

    if (confirm) {
      await _firestore
          .collection("user_pets")
          .doc(widget.petId)
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
        // ================= COMMENTS LIST (adopt STYLE) =================
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 80),
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection("user_pets")
                .doc(widget.petId)
                .collection("comments")
                .orderBy("timestamp", descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox();

              var comments = snapshot.data!.docs;

              if (comments.isEmpty) {
                return const Center(
                  child: Text(
                    "No comments yet",
                    style: TextStyle(color: Colors.black),
                  ),
                );
              }

              return ListView.builder(
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  var comment = comments[index];
                  bool isMe = comment["userId"] == widget.currentUserId;

                  return Container(
                    alignment: isMe
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(
                      vertical: 2,
                      horizontal: 8,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Container(
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
                        ),
                        if (isMe)
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              size: 18,
                              color: Colors.red,
                            ),
                            onPressed: () => deleteComment(comment.id),
                          ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
        // ================= INPUT =================
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _commentController,
                decoration: const InputDecoration(
                  hintText: "Write a comment...",
                  hintStyle: const TextStyle(color: Colors.black),
                  border: InputBorder.none,
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

// ================= AdoptPage =================
class AdoptPage extends StatelessWidget {
  final String userId;
  final String userName;

  const AdoptPage({super.key, required this.userId, required this.userName});

  Future<void> deletePet(
    String docId,
    String? imageUrl,
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
          .collection("user_pets")
          .doc(docId)
          .delete();

      MySnackBar("Pet deleted", context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Adopt Pets"),
        elevation: 5,
        shadowColor: const Color.fromARGB(254, 254, 254, 254),
        surfaceTintColor: Colors.transparent,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("user_pets")
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
              var data = posts[index];
              var docId = data.id;

              return Card(
                color: const Color.fromARGB(164, 214, 214, 214),
                elevation: 7,
                margin: const EdgeInsets.all(13),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //  USER INFO WITH PROFILE IMAGE
                    ListTile(
                      leading: FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection("users")
                            .doc(data["userId"])
                            .get(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircleAvatar(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (!snapshot.hasData || !snapshot.data!.exists) {
                            return const CircleAvatar(
                              child: Icon(Icons.person),
                            );
                          }

                          var userData =
                              snapshot.data!.data() as Map<String, dynamic>;

                          String imageUrl = userData["profileImage"] ?? "";

                          return CircleAvatar(
                            backgroundImage: imageUrl.isNotEmpty
                                ? NetworkImage(imageUrl)
                                : null,
                            child: imageUrl.isEmpty
                                ? const Icon(Icons.person)
                                : null,
                          );
                        },
                      ),
                      title: Text(data["userName"] ?? "Unknown User"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (data["userId"] == userId)
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () =>
                                  deletePet(docId, data["imgUrl"], context),
                            ),
                          IconButton(
                            icon: const Icon(Icons.chat, color: Colors.blue),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatPage(
                                    currentUserId: userId,
                                    otherUserId: data["userId"],
                                    otherUserName: data["userName"],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    // PET IMAGE
                    data["imgUrl"] != null && data["imgUrl"] != ""
                        ? Image.network(
                            data["imgUrl"],
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : const Placeholder(fallbackHeight: 200),

                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        data["title"] ?? "",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),

                      child: Text(
                        data["description"] ?? "",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        "Price: ${data["adoptionPrice"] ?? 0} Tk",
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,

                          fontSize: 16,
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CommentWidget(
                        petId: docId,
                        currentUserId: userId,
                        currentUserName: userName,
                      ),
                    ),

                    // ================= Inside AdoptPage ListView.builder =================
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              MySnackBar("Adoption Request Sent", context);
                            },
                            child: const Text("Adopt Pet"),
                          ),
                          ElevatedButton.icon(
                            onPressed: () async {
                              try {
                                await FirebaseFirestore.instance
                                    .collection("wishlist")
                                    .add({
                                      "title": data["title"] ?? "",
                                      "description": data["description"] ?? "",
                                      "imgUrl": data["imgUrl"] ?? "",
                                      "adoptionPrice":
                                          data["adoptionPrice"] ?? "",
                                      "userId": userId, // Current user id
                                      "addedAt": FieldValue.serverTimestamp(),
                                    });
                                MySnackBar("Added to Wishlist", context);
                              } catch (e) {
                                MySnackBar("Failed to add wishlist", context);
                              }
                            },
                            icon: const Icon(
                              Icons.favorite,
                              color: Colors.white,
                            ),
                            label: const Text(
                              "Wishlist",
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pinkAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.upload),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  UploadPetPage(userId: userId, userName: userName),
            ),
          );
        },
      ),
    );
  }
}
