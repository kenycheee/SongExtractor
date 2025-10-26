import 'package:flutter/material.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ListView(
            children: [
              const SizedBox(height: 20),
              // Search bar
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
                    const Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Recent Favorites
              _SectionHeader(title: 'Recent Favorites'),
              const SizedBox(height: 8),
              SizedBox(
                height: 160,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: const [
                    _LibraryCard(
                      imageUrl:
                          'https://upload.wikimedia.org/wikipedia/commons/5/52/Swan_Lake_Sheet_Music.png',
                      title: 'Swan Lake',
                      subtitle: 'Pyotr Ilyich Tchaikovsky',
                      rating: 5.0,
                      tag: 'Violin',
                    ),
                    _LibraryCard(
                      imageUrl:
                          'https://upload.wikimedia.org/wikipedia/commons/9/9c/Moonlight_Sonata_Sheet_Music.png',
                      title: 'Moonlight Sonata',
                      subtitle: 'Beethoven',
                      rating: 4.8,
                      tag: 'Piano',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Created by Me
              _SectionHeader(title: 'Created by Me'),
              const SizedBox(height: 8),
              SizedBox(
                height: 160,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: const [
                    _LibraryCard(
                      imageUrl:
                          'https://upload.wikimedia.org/wikipedia/commons/5/52/Swan_Lake_Sheet_Music.png',
                      title: 'Swan Lake',
                      subtitle: 'Pyotr Ilyich Tchaikovsky',
                      rating: 5.0,
                      tag: 'Violin',
                    ),
                  ],
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        const Icon(Icons.chevron_right),
      ],
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
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.network(
              imageUrl,
              width: 120,
              height: 90,
              fit: BoxFit.cover,
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
              Text(
                rating.toStringAsFixed(1),
                style: const TextStyle(fontSize: 11),
              ),
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
