import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:test/accountinfo.dart';
import 'package:test/actionbutton.dart';
import 'package:test/adopt.dart';
import 'package:test/feedback.dart';
import 'package:test/intro.dart';
import 'package:test/login.dart';
import 'package:test/policies.dart';
import 'package:test/profile.dart';
import 'package:test/rescue.dart';
import 'package:test/donate.dart';
import 'package:test/userslistpage.dart';
import 'package:test/wishlist.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Initialize Firebase before app starts
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

// Custom SnackBar function (to show messages)
void MySnackBar(message, context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        //  style: TextStyle(fontSize: 16),
        textAlign: TextAlign.center,
      ),
      backgroundColor: Colors.deepPurple,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}

class HomeActivity extends StatefulWidget {
  // User data passed from login
  final String userId;
  final String userName;
  final String userEmail;

  const HomeActivity({
    super.key,
    required this.userId,
    required this.userName,
    required this.userEmail,
  });

  @override
  State<HomeActivity> createState() => _HomeActivityState();
}

class _HomeActivityState extends State<HomeActivity> {
  String? profileImageUrl; // stores profile image URL
  bool _loadingProfile = true; // loading state

  @override
  void initState() {
    super.initState();
    fetchUserProfile(); // fetch profile when screen loads
  }

  // Fetch user profile data from Firestore
  Future<void> fetchUserProfile() async {
    try {
      var query = await FirebaseFirestore.instance
          .collection("users")
          .where("email", isEqualTo: widget.userEmail)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        var data = query.docs.first.data();
        setState(() {
          profileImageUrl = data['profileImage']; // get profile image
          _loadingProfile = false;
        });
      } else {
        setState(() => _loadingProfile = false);
      }
    } catch (e) {
      print("Error fetching profile image: $e");
      setState(() => _loadingProfile = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      //Drawer Part
      drawer: MyDrawer(
        userId: widget.userId,
        userName: widget.userName,
        userEmail: widget.userEmail,
        profileImageUrl: profileImageUrl,
        loadingProfile: _loadingProfile,
      ),

      //Floating Action Button part
      floatingActionButton: MyActionButton(
        userId: widget.userId,
        userName: widget.userName,
        userEmail: widget.userEmail,
      ),

      // Bottom Navigation Bar part
      bottomNavigationBar: BottomNavigation(
        currentIndex: 0,
        userId: widget.userId,
        userName: widget.userName,
        userEmail: widget.userEmail,
      ),

      appBar: AppBar(
        title: const Text("Home"),
        elevation: 5,
        shadowColor: const Color.fromARGB(254, 254, 254, 254),
        surfaceTintColor: Colors.transparent,
      ),

      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 20),

            // Adopt Cards
            Card(
              color: const Color.fromRGBO(198, 175, 161, 1),
              margin: const EdgeInsets.all(12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 7,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset("assets/adopt.png", height: 150),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "This little one is full of love and energy. Adopt now and make a friend for life!",
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AdoptPage(
                                    userId: widget.userId,
                                    userName: widget.userName,
                                  ),
                                ),
                              );
                            },
                            child: const Text("Adopt"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Rescue Card
            Card(
              color: const Color.fromRGBO(199, 64, 68, 1),
              margin: const EdgeInsets.all(12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 7,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset("assets/rescue.png", height: 150),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Be a hero! Rescue a pet in need and give them a second chance at life.",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RescuePage(
                                    userId: widget.userId,
                                    userName: widget.userName,
                                  ),
                                ),
                              );
                            },
                            child: const Text("Rescue"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Donate Card
            Card(
              color: const Color.fromRGBO(25, 196, 216, 1),
              margin: const EdgeInsets.all(12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 7,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset("assets/DD.png", height: 150),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Your kindness can save lives. Donate today and help pets live happy and healthy.",
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DonatePage(
                                    userId: widget.userId,
                                    userName: widget.userName,
                                  ),
                                ),
                              );
                            },
                            child: const Text("Donate"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//Drawer Code

class MyDrawer extends StatelessWidget {
  final String userId;
  final String userName;
  final String userEmail;
  final String? profileImageUrl;
  final bool loadingProfile;

  const MyDrawer({
    super.key,

    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.profileImageUrl,
    required this.loadingProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        children: [
          // User info header
          DrawerHeader(
            padding: EdgeInsets.zero,
            child: UserAccountsDrawerHeader(
              margin: EdgeInsets.zero,
              accountName: Text(
                userName,
                style: const TextStyle(color: Colors.black, fontSize: 16),
              ),
              accountEmail: Text(
                userEmail,
                style: const TextStyle(color: Colors.black, fontSize: 16),
              ),

              // Profile image from Firestore
              currentAccountPicture: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("users")
                    .where("email", isEqualTo: userEmail)
                    .limit(1)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return CircleAvatar(
                      backgroundImage: AssetImage("assets/rescue.png"),
                    );
                  }

                  var data = snapshot.data!.docs.first.data();
                  String? imageUrl = data['profileImage'];

                  return CircleAvatar(
                    backgroundImage: (imageUrl != null && imageUrl.isNotEmpty)
                        ? NetworkImage(imageUrl)
                        : AssetImage("assets/rescue.png") as ImageProvider,
                  );
                },
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),

          // Account page
          ListTile(
            title: const Text("Account Update"),
            leading: const Icon(Icons.account_box, color: Colors.blue),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AccountInfoPage(userEmail: userEmail),
                ),
              );
            },
          ),

          // Terms and conditionn page
          ListTile(
            title: const Text("Terms & condition"),
            leading: const Icon(Icons.description, color: Colors.purple),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PoliciesPage(
                    userId: userId,
                    userName: userName,
                    userEmail: userEmail,
                  ),
                ),
              );
            },
          ),

          // feedback page
          ListTile(
            title: const Text("Feedback"),
            leading: const Icon(Icons.feedback, color: Colors.blue),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FeedbackPage(
                    userId: userId,
                    userName: userName,
                    userEmail: userEmail,
                  ),
                ),
              );
            },
          ),

          // logout
          ListTile(
            title: const Text("Logout"),
            leading: const Icon(Icons.logout, color: Colors.red),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text("Alert"),
                    content: const Text("Do you want to Logout?"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          emailController.clear();
                          passwordController.clear();
                          MySnackBar("Logout successful", context);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginPage(),
                            ),
                          );
                        },
                        child: const Text("Yes"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("No"),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

//Floacting Action Button Code
class MyActionButton extends StatelessWidget {
  final int currentIndex;
  final String userId;
  final String userName;
  final String userEmail;

  const MyActionButton({
    super.key,
    this.currentIndex = 0, // default value
    required this.userId,
    required this.userName,
    required this.userEmail,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      elevation: 10,
      backgroundColor: Colors.blue,
      child: const Icon(Icons.phone),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ActionButtonPage(
              userId: userId,
              userName: userName,
              userEmail: userEmail,
            ),
          ),
        );
      },
    );
  }
}

//Bottom Navigation Bar Code
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
        if (index == currentIndex) return;

        if (index == 0) {
          Navigator.popUntil(context, (route) => route.isFirst);
        }

        if (index == 1) {
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
        }

        if (index == 2) {
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
        }

        if (index == 3) {
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
