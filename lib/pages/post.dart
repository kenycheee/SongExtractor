import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostPage extends StatefulWidget {
  const PostPage({super.key});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final _descriptionController = TextEditingController();

  XFile? _selectedImage;
  bool _isUploading = false;
  final picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked != null) {
        setState(() => _selectedImage = picked);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> _submitPost() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Please log in first.")),
      );
      return;
    }

    if (_descriptionController.text.trim().isEmpty && _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Description or image required.")),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      // kalau user nggak pilih gambar, simpan null aja
      final imagePath = _selectedImage != null ? _selectedImage!.path : null;

      final postData = {
        'userId': user.uid,
        'description': _descriptionController.text.trim(),
        'localPath': imagePath ?? '', // biar aman tetep ada field
        'createdAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('post').add(postData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Post uploaded successfully!")),
      );

      // Reset form
      _descriptionController.clear();
      setState(() {
        _selectedImage = null;
      });
    } catch (e) {
      debugPrint('Error submitting post: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Upload failed: $e")),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final width = MediaQuery.of(context).size.width;
    final isWide = width > 600;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          toolbarHeight: 80,
          title: const Text(
            'Create Post',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 80, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'You must login first to create a post',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5E4B8B),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.login),
                label: const Text('Login'),
              )
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 80,
        title: const Text(
          'Create Post',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints:
                BoxConstraints(maxWidth: isWide ? 500 : double.infinity),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: _inputDecoration('Add description ...'),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: _selectedImage == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.image, size: 36, color: Colors.grey),
                              SizedBox(height: 8),
                              Text('Add image for post (optional) ...',
                                  style: TextStyle(color: Colors.grey)),
                            ],
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(6),
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
                const SizedBox(height: 24),
                Center(
                  child: _isUploading
                      ? const CircularProgressIndicator()
                      : ElevatedButton.icon(
                          onPressed: _submitPost,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: const Color(0xFF5E4B8B),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            minimumSize: const Size(180, 45),
                          ),
                          icon: const Icon(Icons.cloud_upload),
                          label: const Text(
                            'Upload Post',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(6)),
        borderSide: BorderSide(color: Color(0xFF5E4B8B)),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }
}