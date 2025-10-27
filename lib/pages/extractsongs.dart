import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ExtractSongsPage extends StatefulWidget {
  const ExtractSongsPage({super.key});

  @override
  State<ExtractSongsPage> createState() => _ExtractSongsPageState();
}

class _ExtractSongsPageState extends State<ExtractSongsPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _composerController = TextEditingController();
  XFile? _selectedImage;
  bool _isUploading = false;
  final picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked != null) setState(() => _selectedImage = picked);
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> _submitExtract() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSnack('⚠️ Please log in first.');
      return;
    }
    if (_selectedImage == null) {
      _showSnack('⚠️ Please select an image first.');
      return;
    }

    setState(() => _isUploading = true);

    try {
      final imagePath = _selectedImage!.path;
      await FirebaseFirestore.instance.collection('extracted_images').add({
        'userId': user.uid,
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'composer': _composerController.text.trim(),
        'localPath': imagePath,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _showSnack('✅ Image added for extraction!');
      _titleController.clear();
      _composerController.clear();
      _descriptionController.clear();
      setState(() => _selectedImage = null);
    } catch (e) {
      _showSnack('❌ Upload failed: $e');
    } finally {
      setState(() => _isUploading = false);
    }
  }

  void _showSnack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final width = MediaQuery.of(context).size.width;
    final isWide = width > 600;

    // 🟣 Jika belum login
    if (user == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF9F8FB),
        appBar: _buildAppBar(),
        body: _buildLoginPrompt(),
      );
    }

    // 🟣 Kalau sudah login
    return Scaffold(
      backgroundColor: const Color(0xFFF9F8FB),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isWide ? 520 : double.infinity),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInputField('Title ...', _titleController),
                const SizedBox(height: 14),
                _buildInputField('Compose by ...', _composerController),
                const SizedBox(height: 14),
                _buildInputField('Add description ...', _descriptionController, maxLines: 3),
                const SizedBox(height: 20),

                // 🖼️ Upload area
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: _selectedImage == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.image_search, size: 40, color: Color(0xFF6B4EFF)),
                              SizedBox(height: 10),
                              Text('Tap to add image for extraction',
                                  style: TextStyle(color: Colors.grey, fontSize: 14)),
                            ],
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: kIsWeb
                                ? Image.network(
                                    _selectedImage!.path,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  )
                                : Image.file(
                                    File(_selectedImage!.path),
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                          ),
                  ),
                ),
                const SizedBox(height: 28),

                // 🔘 Extract button
                Center(
                  child: _isUploading
                      ? const CircularProgressIndicator(color: Color(0xFF6B4EFF))
                      : ElevatedButton.icon(
                          onPressed: _submitExtract,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6B4EFF),
                            foregroundColor: Colors.white,
                            elevation: 3,
                            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: const Icon(Icons.auto_awesome, size: 20),
                          label: const Text('Extract from Image',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w600)),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🟪 Input Field Builder
  Widget _buildInputField(String hint, TextEditingController controller,
      {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.grey.shade100, blurRadius: 5, offset: const Offset(0, 2))
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }

  // 🟣 AppBar (sama gaya dengan ScoresPage)
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      automaticallyImplyLeading: false,
      toolbarHeight: 80,
      title: const Text(
        'Extract from Image',
        style: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
      ),
    );
  }

  // 🔐 Tampilan jika belum login
  Widget _buildLoginPrompt() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'You must log in to use this feature',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 26),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B4EFF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.login),
              label: const Text('Login', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}
