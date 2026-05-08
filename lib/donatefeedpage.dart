import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ================= SNACKBAR =================
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

class DonateFeedPage extends StatelessWidget {
  const DonateFeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Donate Pets Feed"),
        elevation: 5,
        shadowColor: const Color.fromARGB(254, 254, 254, 254),
        surfaceTintColor: Colors.transparent,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("donate_pets")
            .orderBy("created_at", descending: true)
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No donation posts yet"));
          }

          var posts = snapshot.data!.docs;

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              var doc = posts[index].data() as Map<String, dynamic>;

              String problem = doc["problem"] ?? "";
              String location = doc["location"] ?? "Unknown";
              String userName = doc["userName"] ?? "Unknown";
              String neededAmount = doc["needed_amount"]?.toString() ?? "0";
              String imgUrl = doc["imgurl"] ?? "";

              return Card(
                margin: const EdgeInsets.all(10),
                elevation: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ================= USER INFO =================
                    ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(userName),
                    ),

                    // ================= IMAGE =================
                    imgUrl.isNotEmpty
                        ? Image.network(
                            imgUrl,
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                          )
                        : const SizedBox(
                            height: 200,
                            child: Center(child: Text("No Image")),
                          ),

                    // ================= PROBLEM =================
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        problem,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),

                    // ================= LOCATION =================
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 18,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            location,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 5),

                    // ================= AMOUNT =================
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        "Needed Amount: $neededAmount Tk",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                          fontSize: 18,
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
