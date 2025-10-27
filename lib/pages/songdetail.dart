import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SongDetailPage extends StatefulWidget {
  final String title;
  final String composer;
  final double rating;
  final String description;
  final String? imageUrl;

  const SongDetailPage({
    super.key,
    required this.title,
    required this.composer,
    required this.rating,
    required this.description,
    this.imageUrl,
  });

  @override
  State<SongDetailPage> createState() => _SongDetailPageState();
}

class _SongDetailPageState extends State<SongDetailPage> {
  bool isFavorite = false;
  bool isLoadingFavorite = true;
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  /// 🔍 Cek apakah lagu ini sudah difavoritkan oleh user
  Future<void> _checkFavoriteStatus() async {
    if (user == null) return;

    final favDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('favorites')
        .doc(widget.title);

    final snapshot = await favDoc.get();

    if (mounted) {
      setState(() {
        isFavorite = snapshot.exists;
        isLoadingFavorite = false;
      });
    }
  }

  /// ❤️ Tambah / hapus dari favorit (per user)
  Future<void> toggleFavorite() async {
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to add favorites')),
      );
      return;
    }

    final favRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('favorites')
        .doc(widget.title);

    final doc = await favRef.get();

    if (doc.exists) {
      // ❌ Hapus dari favorites
      await favRef.delete();
      setState(() => isFavorite = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.title} removed from favorites')),
      );
    } else {
      // ✅ Tambah ke favorites
      await favRef.set({
        'title': widget.title,
        'composer': widget.composer,
        'rating': widget.rating,
        'description': widget.description,
        'imageUrl': widget.imageUrl ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });
      setState(() => isFavorite = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.title} added to favorites')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: Colors.white,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  isLoadingFavorite
                      ? const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : IconButton(
                          icon: Icon(
                            isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: isFavorite ? Colors.red : Colors.grey,
                          ),
                          onPressed: toggleFavorite,
                        ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 56, bottom: 12),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        widget.composer,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),

              // Konten lagu
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    Container(
                      height: 280,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: widget.imageUrl != null &&
                              widget.imageUrl!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                widget.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const Center(child: Icon(Icons.broken_image)),
                              ),
                            )
                          : const Center(
                              child: Text(
                                "🎵 Music Sheet Preview\n(placeholder)",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        widget.description,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 200),
                  ],
                ),
              ),
            ],
          ),

          // Bottom sheet
          DraggableScrollableSheet(
            initialChildSize: 0.25,
            minChildSize: 0.15,
            maxChildSize: 0.85,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star,
                                color: Colors.orange, size: 18),
                            const SizedBox(width: 4),
                            Text(widget.rating.toStringAsFixed(1)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text("By ${widget.composer}",
                        style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 16),
                    const Text("Description",
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 8),
                    Text(widget.description,
                        style: const TextStyle(color: Colors.black87)),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
