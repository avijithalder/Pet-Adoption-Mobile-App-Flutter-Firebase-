import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test/main.dart';
import 'package:test/profile.dart';
import 'package:test/wishlist.dart';
import 'message.dart';

class UsersListPage extends StatefulWidget {
  final String currentUserEmail;
  final String currentUserName;

  //////
  final String userEmail;
  final String userId;
  final String userName;

  const UsersListPage({
    super.key,
    required this.currentUserEmail,
    required this.currentUserName,

    ////
    required this.userEmail,
    required this.userId,
    required this.userName,
  });

  @override
  State<UsersListPage> createState() => _UsersListPageState();
}

class _UsersListPageState extends State<UsersListPage> {
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigation(
        currentIndex: 1,
        userId: widget.userId,
        userName: widget.userName,
        userEmail: widget.userEmail,
      ),

      appBar: AppBar(
        title: const Text("Find Friends"),
        elevation: 5,
        shadowColor: const Color.fromARGB(254, 254, 254, 254),
        surfaceTintColor: Colors.transparent,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },

        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search users...",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value.toLowerCase();
                  });
                },
              ),
            ),

            // Users List
            Expanded(
              child: UsersListView(
                currentUserEmail: widget.currentUserEmail,
                searchQuery: searchQuery,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UsersListView extends StatelessWidget {
  final String currentUserEmail;
  final String searchQuery;

  const UsersListView({
    super.key,
    required this.currentUserEmail,
    this.searchQuery = "",
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection("users").snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var docs = snapshot.data!.docs;
        var otherUsers = docs.where((doc) {
          var data = doc.data() as Map<String, dynamic>?;
          if (data == null) return false;
          String email = data['email'] ?? "";
          String name = data['name'] ?? "";
          bool notCurrentUser = email != currentUserEmail;
          bool matchesSearch =
              name.toLowerCase().contains(searchQuery) ||
              email.toLowerCase().contains(searchQuery);
          return notCurrentUser && matchesSearch;
        }).toList();

        if (otherUsers.isEmpty) {
          return const Center(child: Text("No users found"));
        }

        return ListView.builder(
          itemCount: otherUsers.length,
          itemBuilder: (context, index) {
            var user = otherUsers[index];
            var data = user.data() as Map<String, dynamic>? ?? {};

            String name = data['name'] ?? "No Name";
            String email = data['email'] ?? "No Email";
            String? profileImage = data['profileImage'];
            String displayInitial = (name.isNotEmpty) ? name[0] : "?";

            return ListTile(
              leading: CircleAvatar(
                radius: 25,
                backgroundImage:
                    (profileImage != null && profileImage.isNotEmpty)
                    ? NetworkImage(profileImage)
                    : null,
                child: (profileImage == null || profileImage.isEmpty)
                    ? Text(displayInitial)
                    : null,
              ),
              title: Text(name),
              subtitle: Text(email),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MessagePage(
                      currentUserEmail: currentUserEmail,
                      receiverEmail: email,
                      receiverName: name,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
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
                userEmail: userEmail,
                userId: userId,
                userName: userName,
              ),
            ),
          );
        } else if (index == 3) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ProfilePage(
                userId: userId,
                userEmail: userEmail,
                userName: userName,
              ),
            ),
          );
        }
      },
    );
  }
}
