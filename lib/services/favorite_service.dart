import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoritesService {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static Future<void> addToFavorites(Map<String, dynamic> songData) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final favoritesRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites');

    await favoritesRef.doc(songData['title']).set({
      'title': songData['title'],
      'composer': songData['composer'],
      'rating': songData['rating'],
      'description': songData['description'],
      'imageUrl': songData['imageUrl'],
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> removeFromFavorites(String title) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final docRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(title);

    await docRef.delete();
  }

  static Future<bool> isFavorite(String title) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final docRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(title);

    final docSnap = await docRef.get();
    return docSnap.exists;
  }
}
