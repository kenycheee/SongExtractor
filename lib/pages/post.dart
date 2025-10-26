import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostPage extends StatefulWidget {
  const PostPage({super.key});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final TextEditingController _descriptionController = TextEditingController();
  File? _selectedImage;
  Uint8List? _webImage;
  bool _isPrivate = false;
  bool _allowComments = true;
  bool _loading = false;

  Future<void> _pickImage() async {
    try {
      if (kIsWeb) {
        // 🖥️ Flutter Web pakai file_picker
        final result = await FilePicker.platform.pickFiles(type: FileType.image);
        if (result != null && result.files.single.bytes != null) {
          setState(() => _webImage = result.files.single.bytes);
        }
      } else {
        // 📱 Flutter Mobile pakai image_picker
        final picker = ImagePicker();
        final picked = await picker.pickImage(source: ImageSource.gallery);
        if (picked != null) {
          setState(() => _selectedImage = File(picked.path));
        }
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error picking image: $e")),
      );
    }
  }

  Future<void> _uploadPost() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to post')),
      );
      return;
    }

    if ((_selectedImage == null && _webImage == null) ||
        _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image and add description')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      // 🔹 Upload ke Firebase Storage
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef =
          FirebaseStorage.instance.ref().child('posts/${user.uid}/$fileName');

      String imageUrl;

      if (kIsWeb) {
        await storageRef.putData(_webImage!);
      } else {
        await storageRef.putFile(_selectedImage!);
      }

      imageUrl = await storageRef.getDownloadURL();

      // 🔹 Simpan data ke Firestore
      await FirebaseFirestore.instance.collection('posts').add({
        'userId': user.uid,
        'description': _descriptionController.text.trim(),
        'imageUrl': imageUrl,
        'isPrivate': _isPrivate,
        'allowComments': _allowComments,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Post uploaded successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading post: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final imagePreview = kIsWeb
        ? (_webImage != null
            ? Image.memory(_webImage!, fit: BoxFit.cover)
            : const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('Upload Image', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ))
        : (_selectedImage != null
            ? Image.file(_selectedImage!, fit: BoxFit.cover)
            : const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('Upload Image', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ));

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Create Post',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: imagePreview,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: "Write something about your post...",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                SwitchListTile(
                  value: _isPrivate,
                  onChanged: (v) => setState(() => _isPrivate = v),
                  title: const Text("Private"),
                  subtitle: const Text("Only you can see this post"),
                ),
                SwitchListTile(
                  value: _allowComments,
                  onChanged: (v) => setState(() => _allowComments = v),
                  title: const Text("Allow Comments"),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loading ? null : _uploadPost,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: const Color(0xFF5E4B8B),
                    foregroundColor: Colors.white,
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Post'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
