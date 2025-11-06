import 'package:cloud_firestore/cloud_firestore.dart';

class Book {
  final String id;
  final String title;
  final String author;
  final String condition;
  final String swapFor;
  final String imageUrl;
  final String ownerId;
  final String ownerEmail;
  final DateTime createdAt;
  final String status; // available, pending, swapped

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.condition,
    required this.swapFor,
    required this.imageUrl,
    required this.ownerId,
    required this.ownerEmail,
    required this.createdAt,
    this.status = 'available',
  });

  factory Book.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Book(
      id: doc.id,
      title: data['title'] ?? '',
      author: data['author'] ?? '',
      condition: data['condition'] ?? '',
      swapFor: data['swapFor'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      ownerId: data['ownerId'] ?? '',
      ownerEmail: data['ownerEmail'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      status: data['status'] ?? 'available',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'author': author,
      'condition': condition,
      'swapFor': swapFor,
      'imageUrl': imageUrl,
      'ownerId': ownerId,
      'ownerEmail': ownerEmail,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status,
    };
  }
}
