import 'package:flutter/material.dart';
import 'extractsongs.dart';
import 'library.dart';
import 'profile.dart';
import 'post.dart';
import 'songdetail.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const ScoresPage(),
    const ExtractSongsPage(),
    const LibraryPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F8FB),
      appBar: _currentIndex == 0
          ? AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              centerTitle: false,
              automaticallyImplyLeading: false,
              title: const Text(
                'SongExtractor',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_none, color: Colors.black87),
                  onPressed: () {},
                ),
                const SizedBox(width: 8),
              ],
            )
          : null,
      floatingActionButton: _currentIndex != 1
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const PostPage()));
              },
              backgroundColor: const Color(0xFF6B4EFF),
              shape: const CircleBorder(),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      body: SafeArea(child: _pages[_currentIndex]),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          selectedItemColor: const Color(0xFF6B4EFF),
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.library_music), label: 'Scores'),
            BottomNavigationBarItem(icon: Icon(Icons.add_box_outlined), label: 'Extract'),
            BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Library'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

class ScoresPage extends StatefulWidget {
  const ScoresPage({super.key});

  @override
  State<ScoresPage> createState() => _ScoresPageState();
}

class _ScoresPageState extends State<ScoresPage> {
  String _searchQuery = '';
  String _selectedCategory = 'All';

  final List<String> _categories = ['All', 'Violin', 'Piano', 'Flute', 'Guitar'];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;

    bool filterItem(ScoreItem item) {
      final matchSearch = item.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.subtitle.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchCategory = _selectedCategory == 'All' || item.tag == _selectedCategory;
      return matchSearch && matchCategory;
    }

    final filteredRecent = recentItems.where(filterItem).toList();
    final filteredRecommend = recommendItems.where(filterItem).toList();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        _buildSearchBar(),
        const SizedBox(height: 20),
        _buildCategorySelector(),
        const SizedBox(height: 24),
        const SectionHeader(title: 'Recent View'),
        const SizedBox(height: 10),
        _buildRecentSection(filteredRecent),
        const SizedBox(height: 28),
        const SectionHeader(title: 'Recommended'),
        const SizedBox(height: 10),
        _buildRecommendSection(filteredRecommend, isWide),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 6)],
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          const Icon(Icons.search, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search Scores...',
                border: InputBorder.none,
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.filter_alt_outlined, color: Colors.grey),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final category = _categories[i];
          final selected = _selectedCategory == category;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = category),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? const Color(0xFF6B4EFF) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: selected
                    ? [BoxShadow(color: Colors.purple.shade100, blurRadius: 8)]
                    : [BoxShadow(color: Colors.grey.shade200, blurRadius: 4)],
              ),
              child: Center(
                child: Text(
                  category,
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecentSection(List<ScoreItem> items) {
    if (items.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Text("No recent songs found", style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (_, i) => Padding(
          padding: const EdgeInsets.only(right: 12),
          child: _RecentCard(item: items[i]),
        ),
      ),
    );
  }

  Widget _buildRecommendSection(List<ScoreItem> items, bool isWide) {
    if (items.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Text("No recommendations found", style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    if (isWide) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 3.6,
        ),
        itemBuilder: (_, i) => _RecommendTile(item: items[i]),
      );
    } else {
      return Column(
        children: items
            .map((e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: _RecommendTile(item: e),
                ))
            .toList(),
      );
    }
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17, color: Colors.black87)),
        const Spacer(),
        Icon(Icons.chevron_right, color: Colors.grey.shade500),
      ],
    );
  }
}

class _RecentCard extends StatelessWidget {
  final ScoreItem item;
  const _RecentCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SongDetailPage(
            title: item.title,
            composer: item.subtitle,
            rating: item.rating,
            description: "A masterpiece by ${item.subtitle}.",
          ),
        ),
      ),
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 6)],
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              child: Container(
                height: 100,
                color: const Color(0xFFEDE7F6),
                child: const Icon(Icons.music_note, color: Color(0xFF6B4EFF), size: 40),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  Text(item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  Text(item.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  const SizedBox(height: 4),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.star, size: 12, color: Colors.orange),
                    const SizedBox(width: 4),
                    Text(item.rating.toString(), style: const TextStyle(fontSize: 11)),
                  ]),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _RecommendTile extends StatelessWidget {
  final ScoreItem item;
  const _RecommendTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SongDetailPage(
            title: item.title,
            composer: item.subtitle,
            rating: item.rating,
            description: "‘${item.title}’ is composed by ${item.subtitle}.",
          ),
        ),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 8)],
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE7F6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.library_music, size: 38, color: Color(0xFF6B4EFF)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                    const SizedBox(height: 4),
                    Text(item.subtitle,
                        style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    const SizedBox(height: 8),
                    Row(children: [
                      const Icon(Icons.star, size: 14, color: Colors.orange),
                      const SizedBox(width: 4),
                      Text(item.rating.toString(), style: const TextStyle(fontSize: 13)),
                      const Spacer(),
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2EFFF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          item.tag,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF6B4EFF)),
                        ),
                      ),
                    ])
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ScoreItem {
  final String image;
  final String title;
  final String subtitle;
  final double rating;
  final String tag;

  const ScoreItem({
    required this.image,
    required this.title,
    required this.subtitle,
    required this.rating,
    required this.tag,
  });
}

final recentItems = [
  const ScoreItem(image: '', title: 'River Flows In You', subtitle: 'Yiruma', rating: 4.8, tag: 'Piano'),
  const ScoreItem(image: '', title: 'Swan Lake', subtitle: 'Tchaikovsky', rating: 5.0, tag: 'Violin'),
  const ScoreItem(image: '', title: 'Merry-Go-Round', subtitle: 'Joe Hisaishi', rating: 4.6, tag: 'Piano'),
  const ScoreItem(image: '', title: 'Canon in D', subtitle: 'Pachelbel', rating: 4.9, tag: 'Violin'),
];

final recommendItems = [
  const ScoreItem(image: '', title: 'Clair de Lune', subtitle: 'Debussy', rating: 4.9, tag: 'Piano'),
  const ScoreItem(image: '', title: 'Swan Lake', subtitle: 'Tchaikovsky', rating: 5.0, tag: 'Violin'),
  const ScoreItem(image: '', title: 'Nocturne Op.9 No.2', subtitle: 'Chopin', rating: 4.8, tag: 'Piano'),
  const ScoreItem(image: '', title: 'Canon in D', subtitle: 'Pachelbel', rating: 4.9, tag: 'Violin'),
  const ScoreItem(image: '', title: 'Aria in D Minor', subtitle: 'Bach', rating: 4.7, tag: 'Flute'),
];
