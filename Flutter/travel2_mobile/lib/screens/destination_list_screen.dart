import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Destination {
  final int id;
  final String country;
  final String location;
  final String image;
  final int tourAvailable;

  Destination({
    required this.id,
    required this.country,
    required this.location,
    required this.image,
    required this.tourAvailable,
  });
}

class Booking {
  final int id;
  final String from;
  final String to;
  final String date;
  final String price;
  final String currency;

  Booking({
    required this.id,
    required this.from,
    required this.to,
    required this.date,
    required this.price,
    required this.currency,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    // Adapter selon la structure réelle de l'API
    return Booking(
      id: json['id'],
      from:
          json['flight_data']?['itineraries']?[0]?['segments']?[0]?['departure']?['iataCode'] ??
          '',
      to:
          json['flight_data']?['itineraries']?[0]?['segments']
              ?.last?['arrival']?['iataCode'] ??
          '',
      date: json['created_at'] ?? '',
      price: json['flight_data']?['price']?['grandTotal']?.toString() ?? '',
      currency: json['flight_data']?['price']?['currency'] ?? '',
    );
  }
}

class DestinationListScreen extends StatefulWidget {
  const DestinationListScreen({super.key});

  @override
  State<DestinationListScreen> createState() => _DestinationListScreenState();
}

class _DestinationListScreenState extends State<DestinationListScreen> {
  List<Booking> bookings = [];
  bool loading = true;
  String error = '';

  final List<Destination> destinations = [
    Destination(
      id: 1,
      country: 'Italy',
      location: 'Caspian Valley',
      image: 'assets/images/destination/destination17.jpg',
      tourAvailable: 18,
    ),
    Destination(
      id: 2,
      country: 'Japan',
      location: 'Tokyo',
      image: 'assets/images/destination/destination14.jpg',
      tourAvailable: 21,
    ),
    Destination(
      id: 3,
      country: 'Russia',
      location: 'Moscow',
      image: 'assets/images/destination/destination15.jpg',
      tourAvailable: 15,
    ),
    Destination(
      id: 4,
      country: 'Thailand',
      location: 'Bangkok',
      image: 'assets/images/destination/destination5.jpg',
      tourAvailable: 24,
    ),
    Destination(
      id: 5,
      country: 'America',
      location: 'Florida',
      image: 'assets/images/destination/destination16.jpg',
      tourAvailable: 32,
    ),
    Destination(
      id: 6,
      country: 'Indonesia',
      location: 'Bali',
      image: 'assets/images/destination/destination4.jpg',
      tourAvailable: 14,
    ),
    Destination(
      id: 7,
      country: 'Italy',
      location: 'Caspian Valley',
      image: 'assets/images/destination/destination10.jpg',
      tourAvailable: 18,
    ),
    Destination(
      id: 8,
      country: 'Japan',
      location: 'Tokyo',
      image: 'assets/images/destination/destination11.jpg',
      tourAvailable: 21,
    ),
    Destination(
      id: 9,
      country: 'Russia',
      location: 'Moscow',
      image: 'assets/images/destination/destination7.jpg',
      tourAvailable: 15,
    ),
  ];

  // Ajoute une variable pour stocker la date sélectionnée
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    fetchBookings();
  }

  Future<void> fetchBookings() async {
    setState(() {
      loading = true;
      error = '';
    });
    try {
      // Récupère le token stocké après login
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      print('TOKEN: $token');
      if (token.isEmpty) {
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/bookings'),
        headers: token.isNotEmpty ? {'Authorization': 'Bearer $token'} : {},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List bookingsData = data['bookings'] ?? [];
        bookings = bookingsData.map((e) => Booking.fromJson(e)).toList();
      } else {
        error = 'Erreur ${response.statusCode} : ${response.body}';
      }
    } catch (e) {
      error = 'Exception: $e';
    }
    setState(() {
      loading = false;
    });
  }

  String formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return "${date.day}/${date.month}/${date.year}";
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Destinations'),
        backgroundColor: const Color(0xFF10a7a7),
      ),
      body:
          loading
              ? const Center(child: CircularProgressIndicator())
              : error.isNotEmpty
              ? Center(child: Text(error))
              : Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 12,
                ),
                child: Column(
                  children: [
                    Center(
                      child: Column(
                        children: const [
                          Text(
                            "Mes vols réservés",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF10a7a7),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Vos réservations",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (bookings.isNotEmpty)
                      Expanded(
                        child: ListView.builder(
                          itemCount: bookings.length,
                          itemBuilder: (context, i) {
                            final booking = bookings[i];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: const Icon(
                                  Icons.flight,
                                  color: Color(0xFF10a7a7),
                                ),
                                title: Text(
                                  "${booking.from} → ${booking.to}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  "Réservé le ${formatDate(booking.date)}",
                                ),
                                trailing: Text(
                                  "${booking.price} ${booking.currency}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    else ...[
                      const Text(
                        "Vous n'avez pas encore réservé de vol. Découvrez nos destinations !",
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: GridView.builder(
                          itemCount: destinations.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                childAspectRatio: 0.8,
                              ),
                          itemBuilder: (context, i) {
                            final dest = destinations[i];
                            return Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.asset(
                                      dest.image,
                                      width: double.infinity,
                                      height: 130,
                                      fit: BoxFit.cover,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return Container(
                                          width: double.infinity,
                                          height: 130,
                                          color: Colors.grey[300],
                                          child: const Icon(
                                            Icons.image_not_supported,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  Positioned(
                                    left: 0,
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.5),
                                        borderRadius: const BorderRadius.only(
                                          bottomLeft: Radius.circular(12),
                                          bottomRight: Radius.circular(12),
                                        ),
                                      ),
                                      padding: const EdgeInsets.all(8),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                dest.country,
                                                style: const TextStyle(
                                                  color: Color(0xFF10a7a7),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13,
                                                ),
                                              ),
                                              Text(
                                                dest.location,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF10a7a7),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              "${dest.tourAvailable} Tours",
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
    );
  }
}
