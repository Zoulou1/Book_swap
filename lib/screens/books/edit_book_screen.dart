import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/book_service.dart';
import '../../services/auth_service.dart';
import '../../models/book.dart';

class EditBookScreen extends StatefulWidget {
  final Book book;
  
  const EditBookScreen({super.key, required this.book});

  @override
  State<EditBookScreen> createState() => _EditBookScreenState();
}

class _EditBookScreenState extends State<EditBookScreen> {
  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _swapForController;
  late String _selectedCondition;
  XFile? _selectedImage;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.book.title);
    _authorController = TextEditingController(text: widget.book.author);
    _swapForController = TextEditingController(text: widget.book.swapFor);
    _selectedCondition = widget.book.condition;
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  Future<void> _updateBook() async {
    if (_titleController.text.isEmpty || _authorController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final bookService = Provider.of<BookService>(context, listen: false);
      
      String imageUrl = widget.book.imageUrl;
      if (_selectedImage != null) {
        imageUrl = await bookService.uploadImage(
          _selectedImage!,
          authService.currentUser!.uid,
        );
      }

      await bookService.updateBook(widget.book.id, {
        'title': _titleController.text,
        'author': _authorController.text,
        'condition': _selectedCondition,
        'swapFor': _swapForController.text,
        'imageUrl': imageUrl,
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Book updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Book'),
        backgroundColor: const Color(0xFF1E2139),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  image: widget.book.imageUrl.isNotEmpty && _selectedImage == null
                      ? DecorationImage(
                          image: NetworkImage(widget.book.imageUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _selectedImage != null
                    ? const Center(child: Text('New image selected ✓', style: TextStyle(fontSize: 18)))
                    : widget.book.imageUrl.isEmpty
                        ? const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate, size: 50, color: Colors.grey),
                              SizedBox(height: 8),
                              Text('Tap to add book cover'),
                            ],
                          )
                        : null,
              ),
            ),
            const SizedBox(height: 20),
            
            const Text('Book Title', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Enter book title',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 16),
            
            const Text('Author', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _authorController,
              decoration: InputDecoration(
                hintText: 'Enter author name',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 16),
            
            const Text('Swap For', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _swapForController,
              decoration: InputDecoration(
                hintText: 'What book are you looking for?',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 16),
            
            const Text('Condition', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _buildConditionChip('New'),
                _buildConditionChip('Like New'),
                _buildConditionChip('Good'),
                _buildConditionChip('Used'),
              ],
            ),
            const SizedBox(height: 30),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updateBook,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF4B942),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Color(0xFF1E2139))
                    : const Text(
                        'Update',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E2139),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConditionChip(String condition) {
    bool isSelected = _selectedCondition == condition;
    return GestureDetector(
      onTap: () => setState(() => _selectedCondition = condition),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF4B942) : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          condition,
          style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _swapForController.dispose();
    super.dispose();
  }
}
