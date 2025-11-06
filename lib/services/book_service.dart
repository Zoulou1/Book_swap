import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/book.dart';
import '../models/swap_offer.dart';

class BookService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  List<Book> _allBooks = [];
  List<Book> _myBooks = [];
  List<SwapOffer> _myOffers = [];

  List<Book> get allBooks => _allBooks;
  List<Book> get myBooks => _myBooks;
  List<SwapOffer> get myOffers => _myOffers;

  void listenToBooks() {
    _firestore
        .collection('books')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      _allBooks = snapshot.docs.map((doc) => Book.fromFirestore(doc)).toList();
      notifyListeners();
    });
  }

  void listenToMyBooks(String userId) {
    _firestore
        .collection('books')
        .where('ownerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      _myBooks = snapshot.docs.map((doc) => Book.fromFirestore(doc)).toList();
      notifyListeners();
    });
  }

  void listenToMyOffers(String userId) {
    _firestore
        .collection('swapOffers')
        .where('senderId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      _myOffers = snapshot.docs.map((doc) => SwapOffer.fromFirestore(doc)).toList();
      notifyListeners();
    });
  }

  Future<String> uploadImage(dynamic imageData, String userId) async {
    String fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    Reference ref = _storage.ref().child('book_covers/$fileName');
    await ref.putData(await imageData.readAsBytes());
    return await ref.getDownloadURL();
  }

  Future<void> createBook({
    required String title,
    required String author,
    required String condition,
    required String swapFor,
    required String imageUrl,
    required String ownerId,
    required String ownerEmail,
  }) async {
    await _firestore.collection('books').add({
      'title': title,
      'author': author,
      'condition': condition,
      'swapFor': swapFor,
      'imageUrl': imageUrl,
      'ownerId': ownerId,
      'ownerEmail': ownerEmail,
      'status': 'available',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateBook(String bookId, Map<String, dynamic> data) async {
    await _firestore.collection('books').doc(bookId).update(data);
  }

  Future<void> deleteBook(String bookId) async {
    await _firestore.collection('books').doc(bookId).delete();
  }

  Future<void> createSwapOffer({
    required String bookId,
    required String bookTitle,
    required String senderId,
    required String senderEmail,
    required String receiverId,
    required String receiverEmail,
  }) async {
    await _firestore.collection('swapOffers').add({
      'bookId': bookId,
      'bookTitle': bookTitle,
      'senderId': senderId,
      'senderEmail': senderEmail,
      'receiverId': receiverId,
      'receiverEmail': receiverEmail,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _firestore.collection('books').doc(bookId).update({
      'status': 'pending',
    });
  }

  Future<void> updateSwapStatus(String offerId, String status) async {
    await _firestore.collection('swapOffers').doc(offerId).update({
      'status': status,
    });
  }
}
