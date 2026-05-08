import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PetFeedPage extends StatelessWidget {
  const PetFeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pet Adoption Feed")),

      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("user_pets")
            .orderBy("uploadedAt", descending: true)
            .snapshots(),

        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var posts = snapshot.data!.docs;

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              var data = posts[index];

              return Card(
                margin: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Text(data["title"]),
                      subtitle: Text("by ${data["userName"]}"),
                    ),

                    Image.network(data["imgUrl"]),

                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(data["description"]),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        "Adoption Price: ${data["adoptionPrice"]} Tk",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.pushNamed(context, "/uploadPet");
        },
      ),
    );
  }
}

//Avijit
