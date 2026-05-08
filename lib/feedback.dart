import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test/main.dart';
import 'package:test/profile.dart';
import 'package:test/userslistpage.dart';
import 'package:test/wishlist.dart';

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

class FeedbackPage extends StatefulWidget {
  final int currentIndex;
  final String userId;
  final String userName;
  final String userEmail;
  // <-- userName parameter add

  const FeedbackPage({
    super.key,
    this.currentIndex = 0,
    required this.userId,
    required this.userName,
    required this.userEmail,
  });

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final TextEditingController feedbackController = TextEditingController();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  List<QueryDocumentSnapshot> _feedbacks = [];
  int _insertedCount = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    feedbackController.dispose();
    super.dispose();
  }

  Future submitFeedback(BuildContext context) async {
    String feedbackText = feedbackController.text.trim();

    if (feedbackText.isEmpty) {
      MySnackBar("Please write something first.", context);
      return;
    }

    await FirebaseFirestore.instance.collection("feedback").add({
      "name": widget.userName,
      "details": feedbackText,
      "time": DateTime.now(),
    });

    feedbackController.clear();
    MySnackBar("Feedback submitted successfully.", context);
  }

  void startAutoInsert() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(milliseconds: 800), (timer) {
      if (_insertedCount >= _feedbacks.length) {
        _timer?.cancel();
        return;
      }
      _listKey.currentState?.insertItem(_insertedCount);
      _insertedCount++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigation(
        currentIndex: 0,
        userId: widget.userId,
        userName: widget.userName,
        userEmail: widget.userEmail,
      ),
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Feedback"),
        elevation: 5,
        shadowColor: const Color.fromARGB(254, 254, 254, 254),
        surfaceTintColor: Colors.transparent,
      ),

      body: Column(
        children: [
          const SizedBox(height: 30),

          // Hello Text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Hello! ${widget.userName}👋", // ব্যাক্তির নাম দেখাবে
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Instruction
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Text(
              "Please write your problem or idea below.",
              style: TextStyle(fontSize: 16),
            ),
          ),

          const SizedBox(height: 10),

          // Text Input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 140,
              color: Colors.white,
              child: TextField(
                controller: feedbackController,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  hintText: "Type here...",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ),

          const SizedBox(height: 25),

          // Submit Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: ElevatedButton(
              onPressed: () async {
                await submitFeedback(context); // Submit করবে
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.deepPurple,
              ),
              child: const Text(
                "Submit",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Recent Feedback List
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("feedback")
                  .orderBy("time", descending: true)
                  .limit(4)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No feedback yet."));
                }

                final feedbacks = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: feedbacks.length,
                  itemBuilder: (context, index) {
                    final data = feedbacks[index].data();
                    return Card(
                      color: const Color.fromRGBO(244, 243, 240, 1),
                      margin: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 5,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['name'] ?? "User",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              data['details'] ?? "",
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Bottom Navigation Bar
class BottomNavigation extends StatelessWidget {
  final int currentIndex;
  final String userId;
  final String userName;
  final String userEmail;

  const BottomNavigation({
    super.key,
    required this.currentIndex,
    required this.userId,
    required this.userName,
    required this.userEmail,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: const Color.fromRGBO(255, 138, 101, 1),
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.black,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.message), label: "Message"),
        BottomNavigationBarItem(icon: Icon(Icons.list), label: "Wishlist"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
      ],
      onTap: (int index) {
        //if (index == currentIndex) return;

        if (index == 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeActivity(
                userId: userId,
                userEmail: userEmail,
                userName: userName,
              ),
            ),
          );
        } else if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UsersListPage(
                currentUserEmail: userEmail,
                currentUserName: userName,
                userId: userId,
                userName: userName,
                userEmail: userEmail,
              ),
            ),
          );
        } else if (index == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WishlistPage(
                currentUserId: userId,
                userId: userId,
                userName: userName,
                userEmail: userEmail,
              ),
            ),
          );
        } else if (index == 3) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfilePage(
                userEmail: userEmail,
                userId: userId,
                userName: userName,
              ),
            ),
          );
        }
      },
    );
  }
}
