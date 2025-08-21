import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test2/components/my_drawer.dart';
import 'package:flutter_test2/components/user_tile.dart';
import 'package:flutter_test2/pages/chat_page.dart';
import 'package:flutter_test2/services/auth/auth_service.dart';
import 'package:flutter_test2/services/chat/chat_service.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.person_add),
            onPressed: () {
              _showAddContactDialog(context);
            },
          )
        ],
      ),
      drawer: MyDrawer(),
      body: _buildUserList(),
    );
  }

  Widget _buildUserList() {
  return StreamBuilder(
    stream: _chatService.getContactsStream(),
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return const Text("error");
      }
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Text("Loading...");
      }
      final contacts = snapshot.data!;
      if (contacts.isEmpty) {
        return const Center(child: Text("Belum ada kontak"));
      }
      return ListView(
        children: contacts
            .map<Widget>((userData) =>
                _buildUserListItem(userData, context))
            .toList(),
      );
    },
  );
  }


  Widget _buildUserListItem(Map<String, dynamic> userData, BuildContext context) {
    if (userData["email"] != _authService.getCurrentUser()!.email ) {
      return UserTile(
      text: userData["email"],
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
              receiverEmail: userData["email"],
              receiverID: userData["uid"],
            ),
          )
        );
      },
    );
    } else {
      return Container();
    }
  }

  void _showAddContactDialog(BuildContext context) {
  final TextEditingController emailController = TextEditingController();
  Map<String, dynamic>? searchedUser;
  bool isLoading = false;
  String statusMessage = "";

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          Future<void> searchUser() async {
            setState(() {
              isLoading = true;
              searchedUser = null;
              statusMessage = "";
            });
            try {
              final userQuery = await FirebaseFirestore.instance
                  .collection("Users")
                  .where("email", isEqualTo: emailController.text.trim())
                  .get();

              if (userQuery.docs.isEmpty) {
                setState(() {
                  statusMessage = "User not found";
                  isLoading = false;
                });
                return;
              }

              setState(() {
                searchedUser = {
                  "uid": userQuery.docs.first.id,
                  "email": userQuery.docs.first["email"],
                };
                isLoading = false;
              });
            } catch (e) {
              setState(() {
                statusMessage = "Error: ${e.toString()}";
                isLoading = false;
              });
            }
          }

          Future<void> addContact(Map<String, dynamic> user) async {
            try {
              final currentUserID =
                  FirebaseAuth.instance.currentUser!.uid;

              await FirebaseFirestore.instance
                  .collection("Users")
                  .doc(currentUserID)
                  .collection("contacts")
                  .doc(user["uid"])
                  .set(user);

              Navigator.pop(context);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Failed to add: $e")),
              );
            }
          }

          return AlertDialog(
            title: const Text("Add Contact"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                      hintText: "Enter user email"),
                ),
                const SizedBox(height: 10),

                // tombol search
                ElevatedButton(
                  onPressed: searchUser,
                  child: isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("Search"),
                ),

                const SizedBox(height: 20),

                // hasil pencarian
                if (searchedUser != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(searchedUser!["email"]),
                      IconButton(
                        icon: const Icon(Icons.person_add),
                        onPressed: () => addContact(searchedUser!),
                      ),
                    ],
                  )
                else if (statusMessage.isNotEmpty)
                  Text(statusMessage),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              ),
            ],
          );
        },
      );
    },
  );
}


}