import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test/accountinfo.dart';

class UploadDonatePage extends StatefulWidget {
  final String userId;
  final String userName;

  const UploadDonatePage({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<UploadDonatePage> createState() => _UploadDonatePageState();
}

class _UploadDonatePageState extends State<UploadDonatePage> {
  final problemController = TextEditingController();
  final locationController = TextEditingController();
  final amountController = TextEditingController();

  File? imageFile;
  final picker = ImagePicker();
  bool isLoading = false;

  // ================= PICK IMAGE =================
  Future pickImage() async {
    try {
      final picked = await picker.pickImage(source: ImageSource.gallery);

      if (picked != null) {
        setState(() => imageFile = File(picked.path));

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

  // ================= UPLOAD DONATION =================
  Future uploadDonate() async {
    if (imageFile == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select an image")));
      return;
    }

    if (widget.userId.isEmpty || widget.userName.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("User info missing")));
      return;
    }

    setState(() => isLoading = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();

      Reference ref = FirebaseStorage.instance.ref().child(
        "donate_pets/$fileName.jpg",
      );

      SettableMetadata metadata = SettableMetadata(contentType: 'image/jpeg');

      // Upload image
      await ref.putFile(imageFile!, metadata);
      String imageUrl = await ref.getDownloadURL();

      // Save Firestore
      await FirebaseFirestore.instance.collection("donate_pets").add({
        "imgurl": imageUrl,
        "problem": problemController.text.trim(),
        "location": locationController.text.trim(),
        "needed_amount": amountController.text.trim(),
        "uploadedAt": FieldValue.serverTimestamp(),
        "userId": widget.userId,
        "userName": widget.userName,
      });

      Navigator.pop(context); // close loading

      MySnackBar("Donation post uploaded!", context);

      Navigator.pop(context); // go back
    } catch (e) {
      Navigator.pop(context);

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
        title: const Text("Upload for Donation"),
        elevation: 5,
        shadowColor: const Color.fromARGB(254, 254, 254, 254),
        surfaceTintColor: Colors.transparent,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            // ================= IMAGE PREVIEW =================
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

            const SizedBox(height: 20),

            // ================= PROBLEM =================
            TextField(
              controller: problemController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Problem Description",
                //  border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            // ================= LOCATION =================
            TextField(
              controller: locationController,
              decoration: const InputDecoration(
                labelText: "Location",
                // border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            // ================= AMOUNT =================
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Needed Amount (Tk)",
                // border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: uploadDonate,
              child: const Text("Upload"),
            ),
          ],
        ),
      ),
    );
  }
}
