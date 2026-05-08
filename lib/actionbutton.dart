import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test/main.dart';
import 'package:test/policies.dart';
import 'package:test/profile.dart';
import 'package:test/userslistpage.dart';
import 'package:test/whatsapp.dart';
import 'package:test/wishlist.dart';

/// Custom Snackbar function to show messages
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

class ActionButtonPage extends StatefulWidget {
  final int currentIndex;
  final String userId;
  final String userName;
  final String userEmail;

  const ActionButtonPage({
    super.key,
    this.currentIndex = 0, // default value
    required this.userId,
    required this.userName,
    required this.userEmail,
  });

  //const ActionButtonPage({super.key, required this.userEmail});

  @override
  State<ActionButtonPage> createState() => _ActionButtonPageState();
}

class _ActionButtonPageState extends State<ActionButtonPage> {
  String userName = "";
  bool _loading = true;
  // Controller for problem input field
  TextEditingController problemController = TextEditingController();

  @override
  void initState() {
    super.initState();

    fetchUserName(); // Load user name on page start
  }

  /// Fetch user name from Firestore
  Future<void> fetchUserName() async {
    var query = await FirebaseFirestore.instance
        .collection("users")
        .where("email", isEqualTo: widget.userEmail)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      setState(() {
        userName = query.docs.first["name"];
        _loading = false;
      });
    }
  }

  /// Submit user problem to Firestore
  Future<void> submitProblem() async {
    if (problemController.text.isEmpty) {
      MySnackBar("Please write your problem", context);

      return;
    }

    try {
      await FirebaseFirestore.instance.collection("emergency").add({
        "name": userName,
        "email": widget.userEmail,
        "problem": problemController.text,
        "time": Timestamp.now(),
      });

      problemController.clear();

      MySnackBar("Successfully Submitted", context);
    } catch (e) {
      MySnackBar("Submission Failed", context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while fetching data
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigation(
        currentIndex: 0,
        userId: widget.userId,
        userName: widget.userName,
        userEmail: widget.userEmail,
      ),

      appBar: AppBar(
        title: const Text("Emergency Contact"),
        elevation: 5,
        shadowColor: const Color.fromARGB(254, 254, 254, 254),
        surfaceTintColor: Colors.transparent,
      ),

      backgroundColor: Colors.white,

      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 20),
          children: [
            // Hello Text
            Center(
              child: Text(
                "Hello, $userName 👋",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.blueAccent,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // WhatsApp Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
              child: ElevatedButton.icon(
                onPressed: () {
                  WhatsAppHelper.openWhatsApp(context);
                },
                icon: const Icon(Icons.call, color: Colors.white),
                label: const Text(
                  "WhatsApp",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            // Live Chat Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.message_rounded, color: Colors.white),
                label: const Text(
                  "Live Chat",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 67, 50, 127),
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            // FAQ Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.question_answer, color: Colors.white),
                label: const Text(
                  "FAQs",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 43, 109, 215),
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            // Policies Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PoliciesPage(
                        userId: widget.userId,
                        userName: widget.userName,
                        userEmail: widget.userEmail,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.policy_rounded, color: Colors.white),
                label: const Text(
                  "Guidelines / Policies",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 187, 102, 32),
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Instruction Text In WhatsApp
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 25),
              child: Text(
                "Please describe your problem so we can help you!",
                style: TextStyle(fontSize: 16),
              ),
            ),

            const SizedBox(height: 10),

            // Problem TextField
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: SizedBox(
                height: 140,
                child: TextField(
                  controller: problemController,
                  maxLines: null,
                  expands: true,
                  decoration: InputDecoration(
                    labelText: "Write your problem",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // Submit Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 120),
              child: ElevatedButton.icon(
                onPressed: submitProblem,
                icon: const Icon(Icons.upload, color: Colors.white),
                label: const Text(
                  "Submit",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 92, 86, 209),
                  minimumSize: const Size(150, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
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
                userEmail: userEmail,
                userId: userId,
                userName: userName,
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
