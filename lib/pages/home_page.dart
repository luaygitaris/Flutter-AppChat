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
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text("Tambah Kontak"),
      content: TextField(
        controller: emailController,
        decoration: InputDecoration(hintText: "Masukkan email"),
      ),
      actions: [
        TextButton(
          child: Text("Batal"),
          onPressed: () => Navigator.pop(context),
        ),
        TextButton(
          child: Text("Tambah"),
          onPressed: () async {
            try {
              await _chatService.addContactByEmail(emailController.text.trim());
              Navigator.pop(context);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Gagal: ${e.toString()}")),
              );
            }
          },
        ),
      ],
    ),
  );
}

}