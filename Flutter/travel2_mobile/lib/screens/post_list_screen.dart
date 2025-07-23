import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Post {
  final int id;
  final String title;
  final String description;
  final String category;
  final String? image;
  final String author;
  final String publishedDate;

  Post({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.image,
    required this.author,
    required this.publishedDate,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id:
          json['id'] is int
              ? json['id']
              : int.tryParse(json['id'].toString()) ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      image: json['image'],
      author: json['author'] ?? '',
      publishedDate: json['published_date'] ?? '',
    );
  }
}

class PostListScreen extends StatefulWidget {
  const PostListScreen({super.key});

  @override
  State<PostListScreen> createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> {
  final String apiBaseUrl = 'http://10.0.2.2:8000';
  late Future<List<Post>> apiPosts;
  bool loading = true;
  bool isGridView = false;

  // Articles statiques (exemple)
  final List<Post> staticPosts = [
    Post(
      id: 1,
      title: 'Harbour amid a Slowen down in singer city screening',
      description:
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore.',
      category: 'Travel',
      image: 'assets/images/destination/destination16.jpg',
      author: 'Lorem Ipsum',
      publishedDate: 'Mar 15, 2021',
    ),
    Post(
      id: 2,
      title: 'Bring to the table win-win survival strategies',
      description:
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore.',
      category: 'Wedding',
      image: 'assets/images/destination/destination12.jpg',
      author: 'Lorem Ipsum',
      publishedDate: 'Mar 15, 2021',
    ),
    // ... Ajoute d'autres articles statiques si besoin ...
  ];

  @override
  void initState() {
    super.initState();
    apiPosts = fetchPosts();
  }

  Future<List<Post>> fetchPosts() async {
    setState(() => loading = true);
    try {
      final response = await http.get(Uri.parse('$apiBaseUrl/api/posts'));
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() => loading = false);
        return data.map((e) => Post.fromJson(e)).toList();
      }
    } catch (e) {
      print('Error fetching posts: $e');
    }
    setState(() => loading = false);
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Blog List')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 900) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: SingleChildScrollView(child: _buildPostList(context)),
                ),
                Expanded(
                  flex: 1,
                  child: SingleChildScrollView(child: _buildSidebar(context)),
                ),
              ],
            );
          }
          return SingleChildScrollView(
            child: Column(
              children: [_buildPostList(context), _buildSidebar(context)],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPostList(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header & sort
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              loading
                  ? const Text('Chargement...')
                  : FutureBuilder<List<Post>>(
                    future: apiPosts,
                    builder: (context, snapshot) {
                      final total =
                          (snapshot.data?.length ?? 0) + staticPosts.length;
                      return Text('Showing 1-$total results');
                    },
                  ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.list,
                      color: !isGridView ? Colors.teal : Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        isGridView = false;
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.grid_view,
                      color: isGridView ? Colors.teal : Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        isGridView = true;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: '1',
                    items: const [
                      DropdownMenuItem(value: '1', child: Text('Sort By')),
                      DropdownMenuItem(value: '2', child: Text('Date')),
                      DropdownMenuItem(value: '3', child: Text('Category')),
                    ],
                    onChanged: (v) {},
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          FutureBuilder<List<Post>>(
            future: apiPosts,
            builder: (context, snapshot) {
              final apiPostsList = snapshot.data ?? [];
              final posts = [...apiPostsList, ...staticPosts];

              if (loading && apiPostsList.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (posts.isEmpty) {
                return const Center(child: Text('Aucun article trouvé.'));
              }

              if (isGridView) {
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: posts.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.48, // Plus petit = plus de hauteur pour chaque carte
                  ),
                  itemBuilder: (context, i) {
                    final post = posts[i];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: SizedBox(
                                width: double.infinity,
                                height: 100,
                                child: post.image != null && post.image!.startsWith('assets/')
                                    ? Image.asset(
                                        post.image!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return const Icon(Icons.image_not_supported);
                                        },
                                      )
                                    : Image.network(
                                        post.image != null
                                            ? (post.image!.startsWith('http')
                                                ? post.image!
                                                : '$apiBaseUrl/storage/${post.image}')
                                            : 'https://via.placeholder.com/150',
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return const Icon(Icons.image_not_supported);
                                        },
                                      ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              post.category,
                              style: const TextStyle(
                                color: Colors.teal,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              post.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF1a2230),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              post.publishedDate,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              post.description,
                              maxLines: 2, // Limite à 2 lignes
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'By ${post.author}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              } else {
                // Vue liste
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: posts.length,
                  itemBuilder: (context, i) {
                    final post = posts[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: SizedBox(
                                width: 120,
                                height: 90,
                                child:
                                    post.image != null &&
                                            post.image!.startsWith('assets/')
                                        ? Image.asset(
                                          post.image!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (
                                            context,
                                            error,
                                            stackTrace,
                                          ) {
                                            return const Icon(
                                              Icons.image_not_supported,
                                            );
                                          },
                                        )
                                        : Image.network(
                                          post.image != null
                                              ? (post.image!.startsWith('http')
                                                  ? post.image!
                                                  : '$apiBaseUrl/storage/${post.image}')
                                              : 'https://via.placeholder.com/150',
                                          fit: BoxFit.cover,
                                          errorBuilder: (
                                            context,
                                            error,
                                            stackTrace,
                                          ) {
                                            return const Icon(
                                              Icons.image_not_supported,
                                            );
                                          },
                                        ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    post.category,
                                    style: const TextStyle(
                                      color: Colors.teal,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    post.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Color(0xFF1a2230),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    post.publishedDate,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    post.description,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'By ${post.author}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
            },
          ),
          const SizedBox(height: 16),
          // Pagination statique (exemple)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {},
              ),
              Text('1', style: TextStyle(fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          bottomLeft: Radius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Categories',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 8),
          Text('Travel'),
          Text('Wedding'),
          Text('Tech'),
          Text('Electronic'),
          Text('Health'),
          Text('Fashion'),
          Text('Food'),
          Text('Public'),
        ],
      ),
    );
  }
}
