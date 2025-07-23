import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Tour {
  final int id;
  final String title;
  final String location;
  final int reviews;
  final int price;
  final String image;

  Tour({
    required this.id,
    required this.title,
    required this.location,
    required this.reviews,
    required this.price,
    required this.image,
  });

  factory Tour.fromJson(Map<String, dynamic> json) {
    return Tour(
      id:
          json['id'] is int
              ? json['id']
              : int.tryParse(json['id'].toString()) ?? 0,
      title: json['title'] ?? '',
      location: json['location'] ?? '',
      reviews:
          json['reviews'] is int
              ? json['reviews']
              : int.tryParse(json['reviews'].toString()) ?? 0,
      price:
          json['price'] is int
              ? json['price']
              : (json['price'] is String
                  ? double.tryParse(json['price'])?.toInt() ?? 0
                  : 0),
      image: json['image'] ?? '',
    );
  }
}

class TourListScreen extends StatefulWidget {
  const TourListScreen({super.key});

  @override
  State<TourListScreen> createState() => _TourListScreenState();
}

class _TourListScreenState extends State<TourListScreen> {
  final List<Tour> staticTours = [
    Tour(
      id: 1,
      title: 'Leeds Castle, Cliffs of Dover',
      location: 'Crotia',
      reviews: 200,
      price: 200,
      image: 'assets/images/destination/destination17.jpg',
    ),
    Tour(
      id: 2,
      title: 'Adriatic Adventure-Zagreb To Athens',
      location: 'Greece',
      reviews: 200,
      price: 200,
      image: 'assets/images/destination/destination15.jpg',
    ),
    Tour(
      id: 3,
      title: 'The Spanish Riviera Cost Bay',
      location: 'Spain',
      reviews: 200,
      price: 200,
      image: 'assets/images/destination/destination11.jpg',
    ),
  ];

  late Future<List<Tour>> apiTours;
  bool loading = true;
  bool isGridView = false; // Ajoute cette variable

  @override
  void initState() {
    super.initState();
    apiTours = fetchTours();
  }

  Future<List<Tour>> fetchTours() async {
    setState(() => loading = true);
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/tours'),
      );
      print('API response: ${response.body}');
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() => loading = false);
        return data.map((e) => Tour.fromJson(e)).toList();
      }
    } catch (e) {
      print('Error fetching tours: $e');
    }
    setState(() => loading = false);
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tour List')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Desktop/tablette : sidebar à droite
          if (constraints.maxWidth > 900) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: SingleChildScrollView(child: _buildTourList(context)),
                ),
                Expanded(
                  flex: 1,
                  child: SingleChildScrollView(child: _buildSidebar(context)),
                ),
              ],
            );
          }
          // Mobile : sidebar en dessous
          return SingleChildScrollView(
            child: Column(
              children: [_buildTourList(context), _buildSidebar(context)],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTourList(BuildContext context) {
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
                  : FutureBuilder<List<Tour>>(
                      future: apiTours,
                      builder: (context, snapshot) {
                        final totalTours = (snapshot.data?.length ?? 0) + staticTours.length;
                        return Text('Showing 1-$totalTours results');
                      },
                    ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.list, color: !isGridView ? Colors.teal : Colors.grey),
                    onPressed: () {
                      setState(() {
                        isGridView = false;
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.grid_view, color: isGridView ? Colors.teal : Colors.grey),
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
                      DropdownMenuItem(value: '2', child: Text('Average rating')),
                      DropdownMenuItem(value: '3', child: Text('Price: low to high')),
                      DropdownMenuItem(value: '4', child: Text('Price: high to low')),
                    ],
                    onChanged: (v) {},
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // API tours + static tours
          FutureBuilder<List<Tour>>(
            future: apiTours,
            builder: (context, snapshot) {
              final apiToursList = snapshot.data ?? [];
              final tours = [...apiToursList, ...staticTours];

              if (loading && apiToursList.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (tours.isEmpty) {
                return const Center(child: Text('Aucun tour trouvé.'));
              }

              if (isGridView) {
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: tours.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.55, // Plus petit = plus de hauteur pour chaque carte
                  ),
                  itemBuilder: (context, i) {
                    final tour = tours[i];
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
                                height: 90,
                                child: tour.image.startsWith('assets/')
                                    ? Image.asset(
                                        tour.image,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return const Icon(Icons.image_not_supported);
                                        },
                                      )
                                    : Image.network(
                                        'http://10.0.2.2:8000/storage/${tour.image}',
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return const Icon(Icons.image_not_supported);
                                        },
                                      ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              tour.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF1a2230),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Row(
                              children: [
                                const Icon(Icons.location_on, color: Colors.teal, size: 16),
                                const SizedBox(width: 2),
                                Expanded(
                                  child: Text(
                                    tour.location,
                                    style: const TextStyle(
                                      color: Colors.teal,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: List.generate(
                                5,
                                (i) => const Icon(Icons.star, color: Colors.amber, size: 14),
                              ),
                            ),
                            Text('${tour.reviews} Reviews', style: const TextStyle(fontSize: 11)),
                            const SizedBox(height: 8),
                            Text(
                              '\$${tour.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Color(0xFF1a2230),
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/tour-single');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF10a7a7),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                ),
                                child: const Text('View', style: TextStyle(fontSize: 11)),
                              ),
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
                  itemCount: tours.length,
                  itemBuilder: (context, i) {
                    final tour = tours[i];
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
                                child: tour.image.startsWith('assets/')
                                    ? Image.asset(
                                        tour.image,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return const Icon(Icons.image_not_supported);
                                        },
                                      )
                                    : Image.network(
                                        'http://10.0.2.2:8000/storage/${tour.image}',
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return const Icon(Icons.image_not_supported);
                                        },
                                      ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '6+ Hours | Full Day Tours',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    tour.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Color(0xFF1a2230),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        color: Colors.teal,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        tour.location,
                                        style: const TextStyle(
                                          color: Colors.teal,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Taking Safety Measures',
                                    style: TextStyle(fontSize: 13),
                                  ),
                                  const Text(
                                    'Free cancellation',
                                    style: TextStyle(
                                      color: Colors.teal,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  children: List.generate(
                                    5,
                                    (i) => const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 16,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${tour.reviews} Reviews',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'From',
                                  style: TextStyle(fontSize: 12),
                                ),
                                Text(
                                  '\$${tour.price.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Color(0xFF1a2230),
                                  ),
                                ),
                                const Text(
                                  'Per Adult',
                                  style: TextStyle(fontSize: 12),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/tour-single');
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF10a7a7),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                  ),
                                  child: const Text(
                                    'View Detail',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
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
        children: [
          const Text(
            'Categories Type',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          ...[
            'Tours',
            'Attractions',
            'Day Trips',
            'Outdoor Activities',
            'Concert & Show',
            'Indoor',
            'Sight Seeing',
            'Travels',
          ].map(
            (cat) => CheckboxListTile(
              value: true,
              onChanged: (_) {},
              title: Text(cat),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),
          ),
          const Divider(),
          const Text(
            'Duration Type',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          ...[
            'up to 1 hour',
            '1 to 2 hour',
            '2 to 4 hour',
            '4 to 8 hour',
            '8 to 1 Day',
            '1 Day to 2 Days',
          ].map(
            (cat) => CheckboxListTile(
              value: false,
              onChanged: (_) {},
              title: Text(cat),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),
          ),
          const Divider(),
          const Text(
            'Price Range',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          RangeSlider(
            values: const RangeValues(0, 2000),
            min: 0,
            max: 2000,
            divisions: 20,
            labels: const RangeLabels('\$0', '\$2000'),
            onChanged: (v) {},
          ),
          const Divider(),
          const Text(
            'Related Destinations',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(
            height: 120,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _relatedDestination(
                  'Tokyo',
                  'Japan',
                  'assets/images/destination/destination17.jpg',
                ),
                _relatedDestination(
                  'Cairo',
                  'Egypt',
                  'assets/images/destination/destination14.jpg',
                ),
                _relatedDestination(
                  'Paris',
                  'France',
                  'assets/images/destination/destination11.jpg',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _relatedDestination(String city, String country, String image) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              image,
              width: 100,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 100,
                  height: 60,
                  color: Colors.grey,
                  child: const Icon(Icons.image_not_supported),
                );
              },
            ),
          ),
          const SizedBox(height: 4),
          Text(
            city,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            country,
            style: const TextStyle(color: Colors.grey, fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
