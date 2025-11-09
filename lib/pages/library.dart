import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'songdetail.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        toolbarHeight: 80,
        title: const Text(
          "My Library",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: user == null
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_outline,
                          size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Please sign in to see your library ❤️',
                        style:
                            TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search favorites or creations...',
                          prefixIcon: const Icon(Icons.search,
                              color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 16),
                        ),
                        onChanged: (value) {
                          setState(() => searchQuery = value.toLowerCase());
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _SectionHeader(title: 'Recent Favorites'),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 170,
                              child: _FavoritesList(searchQuery: searchQuery),
                            ),
                            const SizedBox(height: 28),

                            const _SectionHeader(title: 'Created by Me'),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 170,
                              child: _MyCreationsList(searchQuery: searchQuery),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _FavoritesList extends StatelessWidget {
  final String searchQuery;
  const _FavoritesList({required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No favorites found ❤️'));
        }

        final filtered = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final title = (data['title'] ?? '').toString().toLowerCase();
          final composer = (data['composer'] ?? '').toString().toLowerCase();
          return title.contains(searchQuery) ||
              composer.contains(searchQuery);
        }).toList();

        if (filtered.isEmpty) {
          return const Center(child: Text('No matching results'));
        }

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final data = filtered[index].data() as Map<String, dynamic>;
            return _LibraryCard(
              title: data['title'] ?? 'Untitled',
              subtitle: data['composer'] ?? 'Unknown',
              imageUrl: data['imageUrl'] ?? '',
              rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
              tag: 'Favorite',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SongDetailPage(
                      title: data['title'],
                      composer: data['composer'],
                      description: data['description'],
                      imageUrl: data['imageUrl'] ?? '',
                      rating:
                          (data['rating'] as num?)?.toDouble() ?? 0.0,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _MyCreationsList extends StatelessWidget {
  final String searchQuery;
  const _MyCreationsList({required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('extracted_images')
          .where('userId', isEqualTo: user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No creations found 🪄'));
        }

        final filtered = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final title = (data['title'] ?? '').toString().toLowerCase();
          final composer = (data['composer'] ?? '').toString().toLowerCase();
          return title.contains(searchQuery) ||
              composer.contains(searchQuery);
        }).toList();

        if (filtered.isEmpty) {
          return const Center(child: Text('No matching results'));
        }

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final data = filtered[index].data() as Map<String, dynamic>;
            return _LibraryCard(
              title: data['title'] ?? 'Untitled',
              subtitle: data['composer'] ?? 'Unknown',
              imageUrl: data['localPath'] ?? '',
              rating: 0.0,
              tag: 'My Creation',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SongDetailPage(
                      title: data['title'],
                      composer: data['composer'],
                      description: data['description'],
                      imageUrl: data['localPath'] ?? '',
                      rating: 0.0,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
    );
  }
}

class _LibraryCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String subtitle;
  final double rating;
  final String tag;
  final VoidCallback onTap;

  const _LibraryCard({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.rating,
    required this.tag,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      height: 90,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: 90,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.music_note,
                          size: 40, color: Colors.grey),
                    ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star,
                          size: 12, color: Colors.orange),
                      const SizedBox(width: 4),
                      Text(rating.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 11)),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF5E4B8B).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          tag,
                          style: const TextStyle(
                              color: Color(0xFF5E4B8B), fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
