import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UploadPetPage extends StatefulWidget {
  final String userId;
  final String userName;

  const UploadPetPage({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<UploadPetPage> createState() => _UploadPetPageState();
}

class _UploadPetPageState extends State<UploadPetPage> {
  final titleController = TextEditingController();
  final descController = TextEditingController();
  final priceController = TextEditingController();

  File? imageFile;
  final picker = ImagePicker();
  bool isLoading = false; // 🔹 Loading state

  Future pickImage() async {
    try {
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked != null) {
        setState(() {
          imageFile = File(picked.path);
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Image selected")));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("No image selected")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error picking image: $e")));
    }
  }

  Future uploadPet() async {
    if (imageFile == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select image")));
      return;
    }

    if (widget.userId.isEmpty || widget.userName.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("User info missing")));
      return;
    }

    setState(() {
      isLoading = true;
    });

    // 🔹 Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    String fileName = DateTime.now().millisecondsSinceEpoch.toString();

    try {
      // Upload to Firebase Storage
      Reference ref = FirebaseStorage.instance.ref().child(
        "pets/$fileName.jpg",
      );
      SettableMetadata metadata = SettableMetadata();
      await ref.putFile(imageFile!, metadata);

      String imageUrl = await ref.getDownloadURL();

      // Save to Firestore
      await FirebaseFirestore.instance.collection("user_pets").add({
        "title": titleController.text,
        "description": descController.text,
        "adoptionPrice": int.tryParse(priceController.text) ?? 0,
        "imgUrl": imageUrl,
        "uploadedAt": FieldValue.serverTimestamp(),
        "userId": widget.userId,
        "userName": widget.userName,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pet Uploaded Successfully")),
      );

      Navigator.pop(context); // Close loading dialog
      Navigator.pop(context); // Go back to previous page
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Upload Failed: $e")));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload for Adopt "),
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
                : const Text("No Image Selected"),
            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: pickImage,
              child: const Text("Pick Image"),
            ),

            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Pet Name"),
            ),

            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: "Description"),
            ),

            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Adoption Price"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(onPressed: uploadPet, child: const Text("Upload")),
          ],
        ),
      ),
    );
  }
}
