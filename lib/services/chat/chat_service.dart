import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test2/models/message.dart';

class ChatService {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<Map<String,dynamic>>> getUsersStream() {
    return _firestore.collection("Users").snapshots().map((snapshots) {
      return snapshots.docs.map((doc) {
        final user = doc.data();

        return user;
      }).toList();
    });
  }

  Future<void> sendMessage(String receiverID, message) async {
    // get current user info
    final String currentUserID = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    // create message
    Message newMessage = Message(
      senderID: currentUserID,
      senderEmail: currentUserEmail,
      receiverID: receiverID, 
      message: message,
      timestamp: timestamp
    );

    // construct chat room ID  for two users (sorted to)
    List<String> ids = [currentUserID, receiverID];
    ids.sort();
    String chatRoomID = ids.join('_');

    // add new message
    await _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .add(newMessage.toMap());

    // Get message
  }

  Stream<QuerySnapshot> getMessages(String userID, otherUserID) {
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join('_');

    return _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }

  Future<void> addContactByEmail(String email) async {
  try {
    // cari user berdasarkan email
    final userQuery = await _firestore
        .collection("Users")
        .where("email", isEqualTo: email)
        .get();

    if (userQuery.docs.isEmpty) {
      throw Exception("User tidak ditemukan");
    }

    final userDoc = userQuery.docs.first;
    final String currentUserID = _auth.currentUser!.uid;

    // simpan ke subcollection contacts
    await _firestore
        .collection("Users")
        .doc(currentUserID)
        .collection("contacts")
        .doc(userDoc.id)
        .set({
      "uid": userDoc.id,
      "email": userDoc["email"],
    });
  } catch (e) {
    rethrow;
  }
}

  Stream<List<Map<String, dynamic>>> getContactsStream() {
  final String currentUserID = _auth.currentUser!.uid;
  return _firestore
      .collection("Users")
      .doc(currentUserID)
      .collection("contacts")
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => doc.data()).toList());
}


}