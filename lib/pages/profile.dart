import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/login_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        toolbarHeight: 60,
        centerTitle: false,
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (user != null)
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.black),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  builder: (context) => Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Settings",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.logout, color: Colors.red),
                          title: const Text("Logout"),
                          onTap: () {
                            Navigator.pop(context);
                            _logout(context);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),

      // BODY
      body: user == null
          ? _buildNotLoggedIn(context)
          : StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final userData = snapshot.data!.data() as Map<String, dynamic>? ?? {};
                final name = userData['name'] ?? user.displayName ?? 'Anonymous';
                final photoUrl = userData['photoUrl'] ??
                    'https://cdn-icons-png.flaticon.com/512/706/706830.png';
                final followers = userData['followers'] ?? 0;
                final following = userData['following'] ?? 0;

                return SafeArea(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 16),

                          // --- Profile Header ---
                          Column(
                            children: [
                              CircleAvatar(
                                radius: 45,
                                backgroundColor: Colors.grey.shade200,
                                backgroundImage: NetworkImage(photoUrl),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                name,
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w600),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // --- Stats (Reordered) ---
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('posts')
                                .where('userId', isEqualTo: user.uid)
                                .snapshots(),
                            builder: (context, postSnapshot) {
                              final postsCount =
                                  postSnapshot.data?.docs.length ?? 0;

                              return StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('extracted_images')
                                    .where('userId', isEqualTo: user.uid)
                                    .snapshots(),
                                builder: (context, extractSnapshot) {
                                  final scoresCount =
                                      extractSnapshot.data?.docs.length ?? 0;

                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _ProfileStat(count: '$postsCount', label: 'posts'),
                                      const SizedBox(width: 24),
                                      _ProfileStat(count: '$scoresCount', label: 'scores'),
                                      const SizedBox(width: 24),
                                      _ProfileStat(count: '$followers', label: 'followers'),
                                      const SizedBox(width: 24),
                                      _ProfileStat(count: '$following', label: 'following'),
                                    ],
                                  );
                                },
                              );
                            },
                          ),

                          const SizedBox(height: 20),
                          Divider(color: Colors.grey.shade300, thickness: 1),

                          // --- TABS SECTION (moved here) ---
                          DefaultTabController(
                            length: 2,
                            child: Column(
                              children: const [
                                TabBar(
                                  indicatorColor: Color(0xFF5E4B8B),
                                  labelColor: Colors.black,
                                  unselectedLabelColor: Colors.grey,
                                  tabs: [
                                    Tab(text: "Posts"),
                                    Tab(text: "Extracts"),
                                  ],
                                ),
                                SizedBox(
                                  height: 400,
                                  child: TabBarView(
                                    physics: BouncingScrollPhysics(),
                                    children: [
                                      _PostsTab(),
                                      _ExtractsTab(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildNotLoggedIn(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_outline, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              "Login first to see your profile",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5E4B8B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.login),
              label: const Text("Login"),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Profile Stat Widget ---
class _ProfileStat extends StatelessWidget {
  final String count;
  final String label;
  const _ProfileStat({required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(count, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
      ],
    );
  }
}

// --- Posts Section ---
class _PostsTab extends StatelessWidget {
  const _PostsTab();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .where('userId', isEqualTo: user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text('No posts yet'),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 10),
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final data = docs[i].data() as Map<String, dynamic>;
            final imageUrl = data['imageUrl'] ?? '';
            final desc = data['description'] ?? '';
            final isPrivate = data['isPrivate'] ?? false;
            final allowComments = data['allowComments'] ?? true;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🖼️ Jika ada gambar
                  if (imageUrl.isNotEmpty)
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: Image.network(
                        imageUrl,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 200,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                        ),
                      ),
                    ),

                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (desc.isNotEmpty)
                          Text(
                            desc,
                            style: const TextStyle(fontSize: 14),
                          ),
                        const SizedBox(height: 6),

                        Row(
                          children: [
                            if (isPrivate)
                              const Icon(Icons.lock, size: 16, color: Colors.grey),
                            if (!allowComments)
                              const Padding(
                                padding: EdgeInsets.only(left: 8),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}


// --- Extract Section ---
class _ExtractsTab extends StatelessWidget {
  const _ExtractsTab();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('extracted_images')
          .where('userId', isEqualTo: user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('No extracted images yet')));
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 10),
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final data = docs[i].data() as Map<String, dynamic>;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              child: _ScoreTile(
                imageUrl: data['imageUrl'] ?? '',
                title: data['title'] ?? 'Untitled',
                subtitle: data['composer'] ?? '',
                rating: 0,
                tag: 'Extracted',
              ),
            );
          },
        );
      },
    );
  }
}

// --- Score Tile Widget ---
class _ScoreTile extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String subtitle;
  final double rating;
  final String tag;

  const _ScoreTile({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.rating,
    required this.tag,
  });

  @override
  Widget build(BuildContext context) {
    const placeholder =
        'https://upload.wikimedia.org/wikipedia/commons/thumb/5/52/Swan_Lake_Sheet_Music.png/640px-Swan_Lake_Sheet_Music.png';

    final ImageProvider imageProvider =
        (imageUrl.isEmpty || !imageUrl.startsWith('http'))
            ? const NetworkImage(placeholder)
            : NetworkImage(imageUrl);

    return Container(
      height: 110,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image(
              image: imageProvider,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 100,
                height: 100,
                color: Colors.grey[200],
                child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 4),
                Text(subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Colors.orange),
                    const SizedBox(width: 4),
                    Text(rating.toStringAsFixed(1), style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text('• $tag',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}