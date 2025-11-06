import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/book_service.dart';
import '../../models/book.dart';
import '../books/post_book_screen.dart';
import '../books/edit_book_screen.dart';

class MyListingsScreen extends StatelessWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bookService = Provider.of<BookService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Listings'),
        backgroundColor: const Color(0xFF1E2139),
        foregroundColor: Colors.white,
      ),
      body: bookService.myBooks.isEmpty
          ? const Center(
              child: Text('You haven\'t posted any books yet'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bookService.myBooks.length,
              itemBuilder: (context, index) {
                Book book = bookService.myBooks[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        // Book Cover
                        Container(
                          width: 80,
                          height: 100,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E2139),
                            borderRadius: BorderRadius.circular(8),
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
                                  size: 40,
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        
                        // Book Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                book.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                book.author,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF4B942),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  book.condition,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Actions
                        PopupMenuButton(
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ],
                          onSelected: (value) async {
                            if (value == 'edit') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditBookScreen(book: book),
                                ),
                              );
                            } else if (value == 'delete') {
                              bool? confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete Book'),
                                  content: const Text(
                                    'Are you sure you want to delete this book?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                await bookService.deleteBook(book.id);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Book deleted'),
                                    ),
                                  );
                                }
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PostBookScreen()),
          );
        },
        backgroundColor: const Color(0xFFF4B942),
        child: const Icon(Icons.add, color: Color(0xFF1E2139)),
      ),
    );
  }
}
