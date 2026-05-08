import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test/main.dart';
import 'package:test/profile.dart';
import 'package:test/userslistpage.dart';

class WishlistPage extends StatelessWidget {
  final String currentUserId;
  final String userEmail;
  final String userId;
  final String userName;

  const WishlistPage({
    super.key,
    required this.currentUserId,
    required this.userEmail,
    required this.userId,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigation(
        currentIndex: 2,
        userId: userId,
        userName: userName,
        userEmail: userEmail,
      ),
      appBar: AppBar(
        title: const Text("Wishlist"),
        elevation: 5,
        shadowColor: const Color.fromARGB(254, 254, 254, 254),
        surfaceTintColor: Colors.transparent,
      ),

      // StreamBuilder listens to real-time Firestore updates
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("wishlist")
            .where(
              "userId",
              isEqualTo: currentUserId,
            ) // filter current user data
            //.orderBy("addedAt", descending: true) // optional sorting
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Something went wrong"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          var items = snapshot.data!.docs;
          // Empty wishlist state
          if (items.isEmpty) {
            return const Center(child: Text("No items in Wishlist"));
          }
          // Display wishlist items
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              var item = items[index].data() as Map<String, dynamic>;

              return Card(
                elevation: 7,
                margin: const EdgeInsets.all(13),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Display item image
                    item['imgUrl'] != null && item['imgUrl'] != ""
                        ? Image.network(
                            item['imgUrl'],
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : const Placeholder(fallbackHeight: 200),

                    // TITLE
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        item['title'] ?? "",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // DESCRIPTION
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        item['description'] ?? "",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),

                    // ADOPTION PRICE
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        "Price: ${item['adoptionPrice'] ?? 0} Tk",
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),

                    // Remove item from wishlist button
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          try {
                            await FirebaseFirestore.instance
                                .collection("wishlist")
                                .doc(items[index].id)
                                .delete();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Removed from Wishlist"),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Failed to remove item"),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.delete, color: Colors.white),
                        label: const Text(
                          "Remove",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
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
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => WishlistPage(
                currentUserId: userId,
                userId: userId,
                userEmail: userEmail,
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
