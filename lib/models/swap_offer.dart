import 'package:cloud_firestore/cloud_firestore.dart';

class SwapOffer {
  final String id;
  final String bookId;
  final String bookTitle;
  final String senderId;
  final String senderEmail;
  final String receiverId;
  final String receiverEmail;
  final String status; // pending, accepted, rejected
  final DateTime createdAt;

  SwapOffer({
    required this.id,
    required this.bookId,
    required this.bookTitle,
    required this.senderId,
    required this.senderEmail,
    required this.receiverId,
    required this.receiverEmail,
    required this.status,
    required this.createdAt,
  });

  factory SwapOffer.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return SwapOffer(
      id: doc.id,
      bookId: data['bookId'] ?? '',
      bookTitle: data['bookTitle'] ?? '',
      senderId: data['senderId'] ?? '',
      senderEmail: data['senderEmail'] ?? '',
      receiverId: data['receiverId'] ?? '',
      receiverEmail: data['receiverEmail'] ?? '',
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bookId': bookId,
      'bookTitle': bookTitle,
      'senderId': senderId,
      'senderEmail': senderEmail,
      'receiverId': receiverId,
      'receiverEmail': receiverEmail,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
