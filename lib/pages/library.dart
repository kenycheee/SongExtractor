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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: user == null
              ? const Center(
                  child: Text(
                    'Please sign in to see your library ❤️',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // 🔍 Search bar
                    Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: Colors.grey),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              decoration: const InputDecoration(
                                hintText: 'Search favorites or creations...',
                                border: InputBorder.none,
                              ),
                              onChanged: (value) {
                                setState(() => searchQuery = value.toLowerCase());
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ❤️ FAVORITES SECTION
                    const _SectionHeader(title: 'Recent Favorites'),
                    const SizedBox(height: 8),
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(user.uid)
                            .collection('favorites')
                            .orderBy('createdAt', descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return const Center(
                                child: Text('No favorites found ❤️'));
                          }

                          final docs = snapshot.data!.docs;
                          final filtered = docs.where((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            final title =
                                (data['title'] ?? '').toString().toLowerCase();
                            final composer =
                                (data['composer'] ?? '').toString().toLowerCase();
                            return title.contains(searchQuery) ||
                                composer.contains(searchQuery);
                          }).toList();

                          if (filtered.isEmpty) {
                            return const Center(
                                child: Text('No matching results'));
                          }

                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final data =
                                  filtered[index].data() as Map<String, dynamic>;
                              return GestureDetector(
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
                                child: _LibraryCard(
                                  imageUrl: data['imageUrl'] ?? '',
                                  title: data['title'] ?? 'Untitled',
                                  subtitle: data['composer'] ?? 'Unknown',
                                  rating:
                                      (data['rating'] as num?)?.toDouble() ?? 0.0,
                                  tag: 'Favorite',
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 🧑‍🎤 CREATED BY ME SECTION
                    const _SectionHeader(title: 'Created by Me'),
                    const SizedBox(height: 8),
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('extracted_images')
                            .where('userId', isEqualTo: user.uid)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return const Center(
                                child: Text('No creations found 🪄'));
                          }

                          final docs = snapshot.data!.docs;
                          final filtered = docs.where((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            final title =
                                (data['title'] ?? '').toString().toLowerCase();
                            final composer =
                                (data['composer'] ?? '').toString().toLowerCase();
                            return title.contains(searchQuery) ||
                                composer.contains(searchQuery);
                          }).toList();

                          if (filtered.isEmpty) {
                            return const Center(
                                child: Text('No matching results'));
                          }

                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final data =
                                  filtered[index].data() as Map<String, dynamic>;
                              return GestureDetector(
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
                                child: _LibraryCard(
                                  imageUrl: data['localPath'] ?? '',
                                  title: data['title'] ?? 'Untitled',
                                  subtitle: data['composer'] ?? 'Unknown',
                                  rating: 0.0,
                                  tag: 'My Creation',
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          const Icon(Icons.chevron_right),
        ],
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

  const _LibraryCard({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.rating,
    required this.tag,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: imageUrl.isNotEmpty
                ? Image.network(imageUrl,
                    width: 140, height: 90, fit: BoxFit.cover)
                : Container(
                    width: 140,
                    height: 90,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.music_note, color: Colors.grey),
                  ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          ),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
          Row(
            children: [
              const Icon(Icons.star, size: 12, color: Colors.orange),
              const SizedBox(width: 4),
              Text(rating.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 11)),
              const SizedBox(width: 4),
              Text('• $tag',
                  style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}
