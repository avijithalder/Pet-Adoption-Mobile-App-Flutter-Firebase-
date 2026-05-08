import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Custom Snackbar function to show messages
MySnackBar(String message, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.deepPurple,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}

class AccountInfoPage extends StatefulWidget {
  final String userEmail;
  const AccountInfoPage({super.key, required this.userEmail});

  @override
  State<AccountInfoPage> createState() => _AccountInfoPageState();
}

class _AccountInfoPageState extends State<AccountInfoPage> {
  bool _loading = true; // loading state for data fetch
  bool isEditing = false; // toggle edit mode
  bool _obscureOld = true; // hide/show old password
  bool _obscureNew = true; // hide/show new password

  String? docId; // Firestore document ID
  String? profileImageUrl; // user profile image URL

  final _formKey = GlobalKey<FormState>();

  // Controllers for user input fields
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController oldPassController = TextEditingController();
  TextEditingController newPassController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUserData(); // load user data on page start
  }

  /// Fetch user data from Firestore
  Future<void> fetchUserData() async {
    try {
      var query = await FirebaseFirestore.instance
          .collection("users")
          .where("email", isEqualTo: widget.userEmail)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        var data = query.docs.first.data();
        docId = query.docs.first.id;
        // Assign data to controllers
        nameController.text = data['name'] ?? '';
        emailController.text = data['email'] ?? '';
        phoneController.text = data['phone'] ?? '';
        addressController.text = data['address'] ?? '';
        profileImageUrl = data['profileImage'] ?? '';
      }
    } catch (e) {
      print("Error fetching user: $e");
    }

    setState(() {
      _loading = false;
    });
  }

  /// Save updated user data to Firestore
  Future<void> saveUserData() async {
    if (!_formKey.currentState!.validate()) return;
    if (docId == null) return;

    try {
      Map<String, dynamic> updateData = {
        'name': nameController.text,
        'email': emailController.text,
        'phone': phoneController.text,
        'address': addressController.text,
      };

      // Password Change Logic
      if (oldPassController.text.isNotEmpty ||
          newPassController.text.isNotEmpty) {
        if (oldPassController.text.isEmpty || newPassController.text.isEmpty) {
          MySnackBar("Old password and new password both required.", context);
          return;
        }

        var doc = await FirebaseFirestore.instance
            .collection("users")
            .doc(docId)
            .get();

        if (doc.exists && doc['password'] == oldPassController.text) {
          updateData['password'] = newPassController.text;
        } else {
          MySnackBar("Old password is incorrect.", context);
          return;
        }
      }

      await FirebaseFirestore.instance
          .collection("users")
          .doc(docId)
          .update(updateData);

      setState(() {
        isEditing = false;
      });
      // Clear password fields
      oldPassController.clear();
      newPassController.clear();

      MySnackBar("Profile updated successfully!", context);
    } catch (e) {
      print(e);
      MySnackBar("Failed to update profile.", context);
    }
  }

  /// Reusable UI field builder (view + edit mode)
  Widget _buildField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool isPassword = false,
    bool isOldPass = false,
  }) {
    if (isEditing) {
      // Edit mode input field
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: TextFormField(
          controller: controller,
          obscureText: isPassword
              ? (isOldPass ? _obscureOld : _obscureNew)
              : false,
          decoration: InputDecoration(
            labelText: label,
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            prefixIcon: Icon(icon, color: Colors.deepPurple),
            // Show/hide password icon
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      (isOldPass ? _obscureOld : _obscureNew)
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.deepPurple,
                    ),
                    onPressed: () {
                      setState(() {
                        if (isOldPass)
                          _obscureOld = !_obscureOld;
                        else
                          _obscureNew = !_obscureNew;
                      });
                    },
                  )
                : null,
          ),
          validator: (value) =>
              value!.isEmpty ? '$label cannot be empty' : null,
        ),
      );
    }

    // View mode (read-only display)
    if (isPassword) {
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 7,
        child: ListTile(
          leading: Icon(icon, color: Colors.deepPurple),
          title: const Text("********"),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 7,
      child: ListTile(
        leading: Icon(icon, color: Colors.deepPurple),
        title: Text(controller.text),
      ),
    );
  }

  /// Profile header UI section
  Widget profileHeader() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Gradient background header
        Container(
          height: 200,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple.shade400, Colors.deepPurple.shade200],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(50),
              bottomRight: Radius.circular(50),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: const Offset(0, 10),
              ),
            ],
          ),
        ),

        // Profile image + name section
        Positioned(
          bottom: -80,
          left: 0,
          right: 0,
          child: Column(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 80,
                    backgroundColor: Colors.grey[300],
                    backgroundImage:
                        profileImageUrl != null && profileImageUrl!.isNotEmpty
                        ? NetworkImage(profileImageUrl!)
                        : const AssetImage("assets/rescue.png")
                              as ImageProvider,
                  ),

                  // Edit icon (only in edit mode)
                  if (isEditing)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.deepPurple,
                        child: const Icon(Icons.edit, color: Colors.white),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),

              // User name display
              Text(
                nameController.text,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  shadows: [
                    Shadow(
                      blurRadius: 4,
                      color: Colors.black45,
                      offset: Offset(1, 1),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Loading state UI
    if (_loading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(
        elevation: 5,
        title: const Text("Account Information"),
        backgroundColor: Colors.white,
        shadowColor: const Color.fromARGB(254, 254, 254, 254),
        actions: [
          if (!isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  isEditing = true;
                });
              },
            ),
          if (isEditing) ...[
            IconButton(
              icon: const Icon(Icons.save, color: Colors.blue),
              onPressed: saveUserData,
            ),
            IconButton(
              icon: const Icon(Icons.cancel, color: Colors.red),
              onPressed: () {
                setState(() {
                  isEditing = false;
                  oldPassController.clear();
                  newPassController.clear();
                  fetchUserData();
                });
              },
            ),
          ],
        ],
      ),

      // Main content
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          children: [
            profileHeader(),
            const SizedBox(height: 100),

            // Form fields
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildField("Name", nameController, Icons.person),
                  _buildField("Email", emailController, Icons.email),
                  _buildField("Phone", phoneController, Icons.phone),
                  _buildField("Address", addressController, Icons.location_on),

                  // Password fields in edit mode
                  if (isEditing) ...[
                    _buildField(
                      "Old Password",
                      oldPassController,
                      Icons.lock,
                      isPassword: true,
                      isOldPass: true,
                    ),
                    _buildField(
                      "New Password",
                      newPassController,
                      Icons.lock,
                      isPassword: true,
                    ),
                  ] else
                    _buildField(
                      "Password",
                      TextEditingController(),
                      Icons.lock,
                      isPassword: true,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
