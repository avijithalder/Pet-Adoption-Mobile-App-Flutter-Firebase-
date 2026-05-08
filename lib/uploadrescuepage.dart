import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

class UploadRescuePage extends StatefulWidget {
  final String userId;
  final String userName;

  const UploadRescuePage({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<UploadRescuePage> createState() => _UploadRescuePageState();
}

class _UploadRescuePageState extends State<UploadRescuePage> {
  final descController = TextEditingController();
  final locationController = TextEditingController();

  File? imageFile;
  final picker = ImagePicker();
  bool isLoading = false;

  // ================= Pick Image =================
  Future pickImage() async {
    try {
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked != null) {
        setState(() => imageFile = File(picked.path));
        print("Selected image path: ${picked.path}");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Image selected")));
      } else {
        print("No image selected");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("No image selected")));
      }
    } catch (e) {
      print("Pick image error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error picking image: $e")));
    }
  }

  // ================= Upload Rescue Pet =================
  Future uploadRescuePet() async {
    if (imageFile == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select an image")));
      print("Upload aborted: No image selected");
      return;
    }

    if (widget.userId.isEmpty || widget.userName.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("User info missing")));
      print("Upload aborted: User info missing");
      return;
    }

    setState(() => isLoading = true);

    // Show loading spinner
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = FirebaseStorage.instance.ref().child(
        "rescue_pets/$fileName.jpg",
      );

      // Optional metadata for content type
      SettableMetadata metadata = SettableMetadata(contentType: 'image/jpeg');

      print("Uploading to Storage: rescue_pets/$fileName.jpg");

      // Upload file
      TaskSnapshot snap = await ref.putFile(imageFile!, metadata);
      print("Upload finished!");

      String imageUrl = await ref.getDownloadURL();
      print("Download URL: $imageUrl");

      // Save Firestore document
      await FirebaseFirestore.instance.collection("rescue_pets").add({
        "description": descController.text.trim(),
        "location": locationController.text.trim(),
        "imgurl": imageUrl,
        "uploadedAt": FieldValue.serverTimestamp(),
        "userId": widget.userId,
        "userName": widget.userName,
      });

      print("Firestore document added successfully!");

      Navigator.pop(context); // Close spinner
      MySnackBar("Rescue post uploaded!", context);
      //  ScaffoldMessenger.of(
      //   context,
      //  ).showSnackBar(const SnackBar(content: Text("Rescue post uploaded!")));
      Navigator.pop(context); // Go back
    } catch (e) {
      Navigator.pop(context); // Close spinner
      print("Upload error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Upload failed: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload for Rescue"),
        elevation: 5,
        shadowColor: const Color.fromARGB(254, 254, 254, 254),
        surfaceTintColor: Colors.transparent,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            imageFile != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(imageFile!, height: 150),
                  )
                : const Text("No image selected"),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: pickImage,
              child: const Text("Pick Image"),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: "Pet Description"),
            ),
            TextField(
              controller: locationController,
              decoration: const InputDecoration(labelText: "Found Location"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: uploadRescuePet,
              child: const Text("Upload"),
            ),
          ],
        ),
      ),
    );
  }
}
