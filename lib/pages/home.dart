import 'package:flutter/material.dart';
import 'extractsongs.dart';
import 'library.dart';
import 'profile.dart';
import 'post.dart';

// 🏠 Home Screen utama
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    ScoresPage(),
    ExtractSongsPage(),
    LibraryPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _currentIndex == 0
          ? AppBar(
              elevation: 0,
              automaticallyImplyLeading: false,
              toolbarHeight: 60,
              backgroundColor: Colors.transparent,
              centerTitle: false,
              title: const Text(
                'SongExtractor',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_none, color: Colors.black87),
                  onPressed: () {},
                ),
              ],
            )
          : null,

      // 🎯 Floating Button hanya muncul jika BUKAN di Extract page
      floatingActionButton: _currentIndex != 1
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PostPage()),
                );
              },
              backgroundColor: const Color(0xFF5E4B8B),
              shape: const CircleBorder(),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,

      body: SafeArea(child: _pages[_currentIndex]),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        selectedItemColor: const Color(0xFF5E4B8B),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.library_music), label: 'Scores'),
          BottomNavigationBarItem(icon: Icon(Icons.add_box_outlined), label: 'Extract'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Library'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}

//
// --- PAGE: Scores ---
//
class ScoresPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width > 600;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ListView(
        children: [
          const SizedBox(height: 8),

          // 🔍 Search bar
          Row(
            children: [
              Expanded(
                child: Container(
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
                            hintText: 'Search Scores',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      VerticalDivider(width: 1, color: Colors.grey.shade300),
                      IconButton(
                        icon: const Icon(Icons.filter_list),
                        onPressed: () {},
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // 🎻 Categories
          const SectionHeader(title: 'Categories'),
          const SizedBox(height: 8),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: const [
                CategoryChip(label: 'Violin', icon: Icons.music_note),
                CategoryChip(label: 'Piano', icon: Icons.queue_music),
                CategoryChip(label: 'Flute', icon: Icons.audiotrack),
                CategoryChip(label: 'Guitar', icon: Icons.library_music),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // 🕒 Recent View
          const SectionHeader(title: 'Recent View'),
          const SizedBox(height: 8),
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: recentItems.length,
              itemBuilder: (context, index) {
                final item = recentItems[index];
                return RecentCard(item: item);
              },
            ),
          ),

          const SizedBox(height: 18),

          // 💡 Recommend
          const SectionHeader(title: 'Recommend'),
          const SizedBox(height: 8),

          LayoutBuilder(
            builder: (context, constraints) {
              if (isWide) {
                return GridView.builder(
                  itemCount: recommendItems.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemBuilder: (context, index) =>
                      RecommendTile(item: recommendItems[index]),
                );
              } else {
                return Column(
                  children: recommendItems
                      .map((it) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: RecommendTile(item: it),
                          ))
                      .toList(),
                );
              }
            },
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

//
// --- UI Components ---
//
class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        const Icon(Icons.chevron_right)
      ],
    );
  }
}

class CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  const CategoryChip({required this.label, required this.icon, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Chip(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.grey.shade300),
        ),
        backgroundColor: Colors.white,
        avatar: CircleAvatar(
          backgroundColor: Colors.grey.shade200,
          child: Icon(icon, size: 16, color: Colors.black87),
        ),
        label: Text(label),
      ),
    );
  }
}

class RecentCard extends StatelessWidget {
  final ScoreItem item;
  const RecentCard({required this.item, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.network(
                item.image,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(item.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
          Text(item.subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: Colors.grey)),
          Row(
            children: [
              const Icon(Icons.star, size: 12, color: Colors.orange),
              const SizedBox(width: 4),
              Text(item.rating.toString(),
                  style: const TextStyle(fontSize: 11)),
            ],
          )
        ],
      ),
    );
  }
}

class RecommendTile extends StatelessWidget {
  final ScoreItem item;
  const RecommendTile({required this.item, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.grey.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.network(item.image,
                  width: 76, height: 76, fit: BoxFit.cover),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(item.subtitle,
                      style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 8),
                  Row(children: [
                    const Icon(Icons.star, size: 14, color: Colors.orange),
                    const SizedBox(width: 6),
                    Text(item.rating.toString()),
                    const Spacer(),
                    Text(item.tag,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey)),
                  ])
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

//
// --- Dummy Data ---
//
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

final recentItems = List.generate(
  4,
  (i) => ScoreItem(
    image: 'https://picsum.photos/seed/recent$i/200/180',
    title: ['River Flows In You', 'Swan Lake', 'Merry-Go-Round', 'Canon in D'][i],
    subtitle: ['Yiruma', 'Pyotr Ilyich Tchaikovsky', 'Joe Hisaishi', 'Pachelbel'][i],
    rating: [4.8, 5.0, 4.6, 4.9][i],
    tag: ['Piano', 'Violin', 'Piano', 'Piano'][i],
  ),
);

final recommendItems = List.generate(
  6,
  (i) => ScoreItem(
    image: 'https://picsum.photos/seed/reco$i/200/200',
    title: i.isEven ? 'River Flows In You' : 'Swan Lake',
    subtitle: i.isEven ? 'Yiruma' : 'Pyotr Ilyich Tchaikovsky',
    rating: i.isEven ? 4.8 : 5.0,
    tag: i.isEven ? 'Piano' : 'Violin',
  ),
);
