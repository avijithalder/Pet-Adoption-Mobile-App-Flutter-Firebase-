import 'package:flutter/material.dart';
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

class RescueFeedPage extends StatelessWidget {
  const RescueFeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Rescue Pets Feed")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("rescue_pets")
            .orderBy("uploadedAt", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          var posts = snapshot.data!.docs;
          if (posts.isEmpty)
            return const Center(child: Text("No rescue posts yet"));

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              var data = posts[index];

              // Null-safe extraction
              String description = data.get("description") ?? "";
              String location = data.get("location") ?? "Unknown";
              String userName = data.get("userName") ?? "Unknown";
              String? imgUrl = data.get("imgurl");

              return Card(
                margin: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(userName),
                    ),
                    imgUrl != null && imgUrl.isNotEmpty
                        ? Image.network(
                            imgUrl,
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                          )
                        : const Placeholder(fallbackHeight: 200),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        description,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        "Location: $location",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
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
