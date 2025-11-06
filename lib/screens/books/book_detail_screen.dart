import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/book.dart';
import '../../services/auth_service.dart';
import '../../services/book_service.dart';
import '../chat/chat_detail_screen.dart';

class BookDetailScreen extends StatelessWidget {
  final Book book;

  const BookDetailScreen({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final bookService = Provider.of<BookService>(context);
    final currentUserId = authService.currentUser?.uid ?? '';
    final isMyBook = book.ownerId == currentUserId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Details'),
        backgroundColor: const Color(0xFF1E2139),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book Cover
            Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                color: const Color(0xFF1E2139),
                image: book.imageUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(book.imageUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: book.imageUrl.isEmpty
                  ? const Icon(
                      Icons.book,
                      color: Colors.white,
                      size: 100,
                    )
                  : null,
            ),
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    book.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Author
                  Text(
                    'By ${book.author}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Condition
                  Row(
                    children: [
                      const Text(
                        'Condition: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4B942),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          book.condition,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Swap For
                  if (book.swapFor.isNotEmpty) ...[
                    const Text(
                      'Looking to swap for:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(book.swapFor),
                    const SizedBox(height: 16),
                  ],
                  
                  // Owner
                  const Text(
                    'Owner:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(book.ownerEmail),
                  const SizedBox(height: 16),
                  
                  // Status
                  Row(
                    children: [
                      const Text(
                        'Status: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        book.status.toUpperCase(),
                        style: TextStyle(
                          color: book.status == 'available'
                              ? Colors.green
                              : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  
                  // Action Buttons
                  if (!isMyBook && book.status == 'available') ...[
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          await bookService.createSwapOffer(
                            bookId: book.id,
                            bookTitle: book.title,
                            senderId: currentUserId,
                            senderEmail: authService.currentUser!.email!,
                            receiverId: book.ownerId,
                            receiverEmail: book.ownerEmail,
                          );

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Swap offer sent!'),
                              ),
                            );
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF4B942),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Request Swap',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E2139),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatDetailScreen(
                                otherUserId: book.ownerId,
                                otherUserEmail: book.ownerEmail,
                              ),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF1E2139)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Message Owner',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E2139),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
