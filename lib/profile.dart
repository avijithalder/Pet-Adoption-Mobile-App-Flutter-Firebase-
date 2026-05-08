import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:test/main.dart';
import 'package:test/userslistpage.dart';
import 'package:test/wishlist.dart';

// Custom SnackBar function (show messages)
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

class ProfilePage extends StatefulWidget {
  // User data passed from previous page
  final String userEmail;
  final String userId;
  final String userName;

  const ProfilePage({
    super.key,
    required this.userEmail,
    required this.userId,
    required this.userName,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  //Image save loading
  bool _uploading = false;
  // Loading state
  bool _loading = true;
  // Edit mode toggle
  bool isEditing = false;
  // Profile image file and URL
  File? profileImageFile;
  String profileImageUrl = '';
  // Image picker instance
  final picker = ImagePicker();
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Controllers for user input fields
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUserData(); // Load user data when screen opens
  }

  // FETCH USER DATA
  Future<void> fetchUserData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.userId)
          .get();

      if (!doc.exists) {
        MySnackBar("User not found", context);
        setState(() => _loading = false);
        return;
      }

      final data = doc.data()!;

      // Set data into controllers
      nameController.text = data['name'] ?? '';
      emailController.text = data['email'] ?? '';
      phoneController.text = data['phone'] ?? '';
      addressController.text = data['address'] ?? '';
      profileImageUrl = data['profileImage'] ?? '';
    } catch (e) {
      print("FETCH ERROR: $e");
      MySnackBar("Fetch error", context);
    }

    setState(() => _loading = false);
  }

  //PICK IMAGE FROM DEVICE
  Future<void> pickImage() async {
    try {
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (picked == null) return;

      setState(() => profileImageFile = File(picked.path));

      await uploadImage(); // Upload after selecting
    } catch (e) {
      print("PICK ERROR: $e");
      MySnackBar("Image pick failed", context);
    }
  }

  // UPLOAD IMAGE
  Future<void> uploadImage() async {
    if (profileImageFile == null) {
      MySnackBar("Select image first", context);
      return;
    }
    setState(() {
      _uploading = true; //Start loading
    });

    try {
      // Create unique file name
      final fileName =
          "profile_${widget.userId}_${DateTime.now().millisecondsSinceEpoch}.jpg";

      final ref = FirebaseStorage.instance.ref().child(
        "profile_pics/$fileName",
      );
      // Upload file to Firebase Storage
      UploadTask uploadTask = ref.putFile(
        profileImageFile!,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      TaskSnapshot snapshot = await uploadTask;

      if (snapshot.state == TaskState.success) {
        // Get download URL
        final url = await snapshot.ref.getDownloadURL();

        // Update Firestore with image URL
        await FirebaseFirestore.instance
            .collection("users")
            .doc(widget.userId)
            .update({"profileImage": url});

        setState(() {
          profileImageUrl = url;
          profileImageFile = null;
        });

        MySnackBar("Image uploaded successfully", context);
      } else {
        MySnackBar("Upload failed", context);
      }
    } catch (e) {
      print("UPLOAD ERROR: $e");
      MySnackBar("Upload error", context);
    }
    setState(() {
      _uploading = false; //stop loading only after Firestore save done
    });
  }

  // SAVE PROFILE DATA
  Future<void> saveUser() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.userId)
          .update({
            "name": nameController.text,
            "phone": phoneController.text,
            "address": addressController.text,
          });

      setState(() => isEditing = false);

      MySnackBar("Profile updated", context);
    } catch (e) {
      print(e);
      MySnackBar("Update failed", context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigation(
        currentIndex: 3,
        userId: widget.userId,
        userName: widget.userName,
        userEmail: widget.userEmail,
      ),

      appBar: AppBar(
        title: const Text("Profile"),
        elevation: 5,
        shadowColor: const Color.fromARGB(254, 254, 254, 254),
        surfaceTintColor: Colors.transparent,
        actions: [
          if (!isEditing)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => setState(() => isEditing = true),
            ),
          if (isEditing) ...[
            IconButton(
              icon: const Icon(Icons.save, color: Colors.blue),
              onPressed: saveUser,
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () {
                setState(() {
                  isEditing = false;
                  fetchUserData();
                });
              },
            ),
          ],
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),

        children: [
          //  PROFILE IMAGE
          Center(
            child: Container(
              padding: const EdgeInsets.fromLTRB(100, 30, 100, 30),
              decoration: BoxDecoration(
                // color: const Color.fromARGB(164, 214, 214, 214),
                color: const Color.fromARGB(160, 116, 233, 83),

                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 80,
                    backgroundImage: profileImageFile != null
                        ? FileImage(profileImageFile!)
                        : (profileImageUrl.isNotEmpty
                                  ? NetworkImage(profileImageUrl)
                                  : const AssetImage("assets/rescue.png"))
                              as ImageProvider,
                  ),

                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: pickImage,
                      child: const CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(Icons.camera_alt),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),
          // Profile picture uploading loding animation
          if (_uploading)
            Container(
              //color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.blue),
                    SizedBox(height: 10),
                    Text(
                      "Uploading Profile...",
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),

          // FORM
          isEditing
              ? Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: "Name"),
                        validator: (v) => v!.isEmpty ? "Required" : null,
                      ),
                      TextFormField(
                        controller: emailController,
                        readOnly: true,
                        decoration: const InputDecoration(labelText: "Email"),
                      ),
                      TextFormField(
                        controller: phoneController,
                        decoration: const InputDecoration(labelText: "Phone"),
                      ),
                      TextFormField(
                        controller: addressController,
                        decoration: const InputDecoration(labelText: "Address"),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person, color: Colors.blue),
                      title: const Text("Name"),
                      subtitle: Text(nameController.text),
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.email,
                        color: Colors.deepOrangeAccent,
                      ),
                      title: const Text("Email"),
                      subtitle: Text(emailController.text),
                    ),
                    ListTile(
                      leading: const Icon(Icons.phone, color: Colors.green),
                      title: const Text("Phone"),
                      subtitle: Text(phoneController.text),
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.location_on,
                        color: Colors.blue,
                      ),
                      title: const Text("Address"),
                      subtitle: Text(addressController.text),
                    ),
                  ],
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
