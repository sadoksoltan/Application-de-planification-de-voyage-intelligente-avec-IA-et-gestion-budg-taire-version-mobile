import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class BannerWidget extends StatefulWidget {
  const BannerWidget({super.key});

  @override
  State<BannerWidget> createState() => _BannerWidgetState();
}
String iaCity = '';
String iaStartDate = '';
String iaEndDate = '';
double iaBudget = 1500;
List<String> iaInterests = [];
bool iaLoading = false;
String iaResult = '';
String iaError = '';
class _BannerWidgetState extends State<BannerWidget> {
  String selectedType = 'flights';
  int hotelAdults = 1;
  int adults = 1;
  double budget = 1500;
  String hotelQuery = '';
  String hotelArrivalDate = '';
  String hotelDepartureDate = '';
  String origin = '';
  String destination = '';
  String departureDate = '';
  String travelType = '';
  String tourDuration = '';
  List<String> interests = [];
  bool loading = false;
  String error = '';
  List<dynamic> hotels = [];
  List<dynamic> flights = [];

  // Ajoute une variable pour stocker la date sélectionnée
  DateTime? selectedDate;
Future<void> searchTravelIA() async {
    setState(() {
      iaLoading = true;
      iaError = '';
      iaResult = '';
    });
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/ai/museums'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'city': iaCity,
          'start_date': iaStartDate,
          'end_date': iaEndDate,
          'budget': iaBudget,
          'interests': iaInterests,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          iaResult =
              data['answer'] ??
              data['recommendations'] ??
              'Aucune suggestion trouvée.';
        });
      } else {
        final data = jsonDecode(response.body);
        setState(() {
          iaError = data['error'] ?? 'Erreur lors de la génération du plan';
        });
      }
    } catch (e) {
      setState(() {
        iaError = 'Erreur lors de la génération du plan';
      });
    } finally {
      setState(() {
        iaLoading = false;
      });
    }
  }

  void resetTravelIA() {
    setState(() {
      iaCity = '';
      iaStartDate = '';
      iaEndDate = '';
      iaBudget = 1500;
      iaInterests = [];
      iaResult = '';
      iaError = '';
    });
  }
  final List<Map<String, dynamic>> bannerList = [
    {
      'id': 1,
      'image': 'assets/images/icons/004-camping-tent.png',
      'text': 'Camping',
    },
    {'id': 2, 'image': 'assets/images/icons/003-hiking.png', 'text': 'Hiking'},
    {
      'id': 3,
      'image': 'assets/images/icons/005-sunbed.png',
      'text': 'Beach Tours',
    },
    {'id': 4, 'image': 'assets/images/icons/006-surf.png', 'text': 'Surfing'},
    {'id': 5, 'image': 'assets/images/icons/002-safari.png', 'text': 'Safari'},
    {
      'id': 6,
      'image': 'assets/images/icons/008-cycling.png',
      'text': 'Cycling',
    },
    {
      'id': 7,
      'image': 'assets/images/icons/001-cityscape.png',
      'text': 'Trekings',
    },
  ];

  void toggleInterest(String interest) {
    setState(() {
      if (interests.contains(interest)) {
        interests.remove(interest);
      } else {
        interests.add(interest);
      }
    });
  }

  Future<void> searchFlights() async {
    print('==> Recherche de vols lancée');
    print('origin=$origin, destination=$destination, departureDate=$departureDate, adults=$adults, budget=$budget, travelType=$travelType, tourDuration=$tourDuration, interests=${interests.join(",")}');
    setState(() {
      loading = true;
      error = '';
      flights = [];
    });
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/flights/search').replace(queryParameters: {
          'origin': origin,
          'destination': destination,
          'departure_date': departureDate,
          'adults': adults.toString(),
          'budget': budget.toInt().toString(),
          'travel_type': travelType,
          'tour_duration': tourDuration,
          'interests': interests.join(','),
        }),
      );
      print('Status code: ${response.statusCode}');
      print('Réponse API: ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List allFlights = data['data'] ?? [];
        print('Nombre de vols reçus: ${allFlights.length}');
        flights = allFlights.where((f) {
          final price = double.tryParse(f['price']?['grandTotal'] ?? '') ?? 0;
          return price <= budget;
        }).toList();
        setState(() {});
      } else {
        setState(() {
          error = 'Erreur ${response.statusCode} : ${response.body}';
        });
      }
    } catch (e) {
      print('Exception: $e');
      setState(() {
        error = 'Erreur lors de la recherche : $e';
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> bookFlight(dynamic flight) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null || token.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vous devez être connecté pour réserver.')),
        );
        Navigator.pushNamed(context, '/login');
        return;
      }
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/bookings'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'flight': flight}),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vol réservé avec succès !')),
        );
        Navigator.pushNamed(context, '/destination-list');
      } else if (response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session expirée, veuillez vous reconnecter.')),
        );
        Navigator.pushNamed(context, '/login');
      } else {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['error'] ?? 'Erreur lors de la réservation')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la réservation : $e')),
      );
    }
  }

  Future<void> searchHotels() async {
    setState(() {
      loading = true;
      error = '';
      hotels = [];
    });
    // Utilise la valeur du contrôleur pour la recherche
    final city = hotelQueryController.text.split(',').first.trim();
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/hotels/search').replace(queryParameters: {
          'query': city,
          'arrival_date': hotelArrivalDate,
          'departure_date': hotelDepartureDate,
          'adults': hotelAdults.toString(),
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        hotels = data['data']?['hotels'] ?? [];
        setState(() {});
      } else {
        setState(() {
          error = 'Erreur ${response.statusCode} : ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        error = 'Erreur lors de la recherche : $e';
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }


  // Ajoute les contrôleurs :
  final TextEditingController originController = TextEditingController();
  final TextEditingController destinationController = TextEditingController();
  final TextEditingController hotelQueryController = TextEditingController();

  @override
  void dispose() {
    originController.dispose();
    destinationController.dispose();
    hotelQueryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/testimonial.png'),
          fit: BoxFit.cover,
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      child: Column(
        children: [
          // Titre et sous-titre
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Explore The World',
                style: TextStyle(
                  color: Color(0xFF10a7a7),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Start Planning Your Dream Trip Today!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 26,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore',
                style: TextStyle(color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Switch Hotels / Flights / Travel.IA
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _typeButton('Hotels', 'hotels'),
              const SizedBox(width: 12),
              _typeButton('Flights', 'flights'),
              const SizedBox(width: 12),
              _typeButton('Travel.IA', 'travel-ia'),
            ],
          ),
          const SizedBox(height: 16),

          // Formulaire selon le type sélectionné
          if (selectedType == 'hotels') ...[
            TextField(
              controller: hotelQueryController,
              decoration: const InputDecoration(
                labelText: 'Enter hotel name or city',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => hotelQuery = v,
            ),
            const SizedBox(height: 8),
            // ARRIVAL DATE: Sélecteur calendrier
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  setState(() {
                    hotelArrivalDate =
                        "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                  });
                }
              },
              child: AbsorbPointer(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Arrival date',
                    border: const OutlineInputBorder(),
                    suffixIcon: const Icon(Icons.calendar_today),
                    hintText: hotelArrivalDate.isNotEmpty ? hotelArrivalDate : 'YYYY-MM-DD',
                  ),
                  controller: TextEditingController(text: hotelArrivalDate),
                  readOnly: true,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // DEPARTURE DATE: Sélecteur calendrier (déjà OK)
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  setState(() {
                    hotelDepartureDate =
                        "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                  });
                }
              },
              child: AbsorbPointer(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Departure date',
                    border: const OutlineInputBorder(),
                    suffixIcon: const Icon(Icons.calendar_today),
                    hintText: hotelDepartureDate.isNotEmpty ? hotelDepartureDate : 'YYYY-MM-DD',
                  ),
                  controller: TextEditingController(text: hotelDepartureDate),
                  readOnly: true,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Adults:'),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () {
                    if (hotelAdults > 1) setState(() => hotelAdults--);
                  },
                ),
                Text('$hotelAdults'),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () => setState(() => hotelAdults++),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // CORRECTION: bouton Search Hotels
            ElevatedButton(
              onPressed: loading ? null : searchHotels,
              child: loading
                  ? const CircularProgressIndicator()
                  : const Text('Search Hotels'),
            ),
          ] else if (selectedType == 'flights') ...[
            TextField(
              controller: originController,
              decoration: const InputDecoration(
                labelText: 'Ville de départ (ex: Casablanca)',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => origin = v,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: destinationController,
              decoration: const InputDecoration(
                labelText: 'Destination (ville)',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => destination = v,
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  setState(() {
                    departureDate =
                        "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                  });
                }
              },
              child: AbsorbPointer(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Departure date',
                    border: const OutlineInputBorder(),
                    suffixIcon: const Icon(Icons.calendar_today),
                    hintText:
                        departureDate.isNotEmpty ? departureDate : 'YYYY-MM-DD',
                  ),
                  controller: TextEditingController(text: departureDate),
                  readOnly: true,
                ),
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: travelType.isEmpty ? null : travelType,
              decoration: const InputDecoration(labelText: 'Travel Type'),
              items: const [
                DropdownMenuItem(value: '', child: Text('Travel Type')),
                DropdownMenuItem(value: 'City Tour', child: Text('City Tour')),
                DropdownMenuItem(
                  value: 'Family Tour',
                  child: Text('Family Tour'),
                )
              ],
              onChanged: (v) => setState(() => travelType = v ?? ''),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: tourDuration.isEmpty ? null : tourDuration,
              decoration: const InputDecoration(labelText: 'Tour Duration'),
              items: const [
                DropdownMenuItem(value: '', child: Text('Tour Duration')),
                DropdownMenuItem(value: '5 days', child: Text('5 days')),
                DropdownMenuItem(value: '7 Days', child: Text('7 Days')),
                DropdownMenuItem(value: '30 days', child: Text('30 days')),
              ],
              onChanged: (v) => setState(() => tourDuration = v ?? ''),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Adults:'),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () {
                    if (adults > 1) setState(() => adults--);
                  },
                ),
                Text('$adults'),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () => setState(() => adults++),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Budget: \$${budget.toInt()}'),
            Slider(
              value: budget,
              min: 100,
              max: 5000,
              divisions: 98,
              label: '\$${budget.toInt()}',
              onChanged: (v) => setState(() => budget = v),
            ),
            const SizedBox(height: 8),
            const Text('Choose Interests:'),
            Wrap(
              spacing: 8,
              children:
                  bannerList
                      .map(
                        (interest) => ChoiceChip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                interest['image'],
                                width: 20,
                                height: 20,
                              ),
                              const SizedBox(width: 4),
                              Text(interest['text']),
                            ],
                          ),
                          selected: interests.contains(interest['text']),
                          onSelected: (_) => toggleInterest(interest['text']),
                          selectedColor: const Color(0xFF10a7a7),
                          backgroundColor: Colors.white,
                          labelStyle: TextStyle(
                            color:
                                interests.contains(interest['text'])
                                    ? Colors.white
                                    : Colors.black,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                            side: const BorderSide(color: Color(0xFF10a7a7)),
                          ),
                        ),
                      )
                      .toList(),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: loading ? null : searchFlights,
              child: loading
                  ? const CircularProgressIndicator()
                  : const Text('Search Now'),
            ),
          ] else if (selectedType == 'travel-ia') ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.smart_toy, color: Colors.teal, size: 32),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Planifiez avec Travel.IA\nLaissez l’IA vous proposer un itinéraire sur mesure',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Ville ou pays',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_city),
                    ),
                    onChanged: (v) => iaCity = v,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() {
                                iaStartDate =
                                    "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                              });
                            }
                          },
                          child: AbsorbPointer(
                            child: TextField(
                              decoration: InputDecoration(
                                labelText: 'Date début',
                                border: const OutlineInputBorder(),
                                suffixIcon: const Icon(Icons.calendar_today),
                                hintText:
                                    iaStartDate.isNotEmpty
                                        ? iaStartDate
                                        : 'YYYY-MM-DD',
                              ),
                              controller: TextEditingController(
                                text: iaStartDate,
                              ),
                              readOnly: true,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() {
                                iaEndDate =
                                    "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                              });
                            }
                          },
                          child: AbsorbPointer(
                            child: TextField(
                              decoration: InputDecoration(
                                labelText: 'Date fin',
                                border: const OutlineInputBorder(),
                                suffixIcon: const Icon(Icons.calendar_today),
                                hintText:
                                    iaEndDate.isNotEmpty
                                        ? iaEndDate
                                        : 'YYYY-MM-DD',
                              ),
                              controller: TextEditingController(
                                text: iaEndDate,
                              ),
                              readOnly: true,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Budget: \$${iaBudget.toInt()}'),
                  Slider(
                    value: iaBudget,
                    min: 100,
                    max: 5000,
                    divisions: 98,
                    label: '\$${iaBudget.toInt()}',
                    onChanged: (v) => setState(() => iaBudget = v),
                  ),
                  const SizedBox(height: 8),
                  const Text('Centres d\'intérêt :'),
                  Wrap(
                    spacing: 8,
                    children:
                        bannerList.map((interest) {
                          final selected = iaInterests.contains(
                            interest['text'],
                          );
                          return ChoiceChip(
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  interest['image'],
                                  width: 20,
                                  height: 20,
                                ),
                                const SizedBox(width: 4),
                                Text(interest['text']),
                              ],
                            ),
                            selected: selected,
                            onSelected: (_) {
                              setState(() {
                                if (selected) {
                                  iaInterests.remove(interest['text']);
                                } else {
                                  iaInterests.add(interest['text']);
                                }
                              });
                            },
                            selectedColor: const Color(0xFF10a7a7),
                            backgroundColor: Colors.white,
                            labelStyle: TextStyle(
                              color: selected ? Colors.white : Colors.black,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                              side: const BorderSide(color: Color(0xFF10a7a7)),
                            ),
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 12),
                  if (iaError.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        iaError,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  if (iaResult.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.teal.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.teal),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Votre itinéraire IA personnalisé',
                            style: TextStyle(
                              color: Colors.teal,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SelectableText(iaResult),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: resetTravelIA,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Réinitialiser'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ElevatedButton.icon(
                      onPressed: iaLoading ? null : searchTravelIA,
                      icon: const Icon(Icons.auto_awesome),
                      label: Text(
                        iaLoading ? 'Génération...' : 'Générer mon plan IA',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        minimumSize: const Size.fromHeight(48),
                      ),
                    ),
                ],
              ),
            ),
          ],

          // Carousel d’activités
          const SizedBox(height: 24),
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: bannerList.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, i) {
                final banner = bannerList[i];
                return GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/tour-grid');
                  },
                  child: Container(
                    width: 110,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(banner['image'], width: 40, height: 40),
                        const SizedBox(height: 8),
                        Text(
                          banner['text'],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (error.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(error, style: const TextStyle(color: Colors.red)),
            ),
          if (hotels.isNotEmpty)
            Column(
              children: hotels.asMap().entries.map((entry) {
                final idx = entry.key;
                final hotel = entry.value;
                final property = hotel['property'] ?? {};
                final photoUrl = property['photoUrls'] != null && property['photoUrls'].isNotEmpty
                    ? property['photoUrls'][0]
                    : null;
                final name = property['name'] ?? (hotel['accessibilityLabel']?.split('\n')[0] ?? 'Hotel');
                final address = property['address'] ?? 'Address not available';
                final stars = property['class'];
                final price = property['priceBreakdown']?['grossPrice']?['value'];
                final currency = property['priceBreakdown']?['grossPrice']?['currency'];
                final reviewScore = property['reviewScore'];
                final reviewCount = property['reviewCount'];
                final description = hotel['accessibilityLabel']?.split('\n')[1] ?? property['description'] ?? 'No description available';
                final url = property['url'];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: idx < 3 ? 4 : 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: idx < 3
                        ? const BorderSide(color: Color(0xFF10a7a7), width: 2)
                        : BorderSide.none,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image
                      Container(
                        width: 120,
                        height: 120,
                        margin: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey[100],
                          image: photoUrl != null
                              ? DecorationImage(
                                  image: NetworkImage(photoUrl),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: photoUrl == null
                            ? const Icon(Icons.hotel, size: 48, color: Colors.grey)
                            : null,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (idx < 3)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.teal,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text('TOP ${idx + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                ),
                              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              if (stars != null)
                                Row(
                                  children: [
                                    ...List.generate(
                                      stars > 5 ? 5 : stars,
                                      (i) => const Icon(Icons.star, color: Colors.amber, size: 16),
                                    ),
                                    const SizedBox(width: 4),
                                    Text('$stars stars', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                  ],
                                ),
                              const SizedBox(height: 4),
                              Text(address, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              if (reviewScore != null)
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.teal,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text('$reviewScore/10', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                    ),
                                    const SizedBox(width: 6),
                                    Text('$reviewCount reviews', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                  ],
                                ),
                              const SizedBox(height: 4),
                              Text(description, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  if (price != null)
                                    Text(
                                      '\$${double.tryParse(price.toString())?.toStringAsFixed(2) ?? price} $currency',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF10a7a7),
                                        fontSize: 16,
                                      ),
                                    ),
                                  if (url != null)
                                    TextButton(
                                      onPressed: () {
                                        // Ouvre le lien dans le navigateur
                                        // (nécessite url_launcher)
                                        // launchUrl(Uri.parse(url));
                                      },
                                      child: const Text('View Deal'),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          if (flights.isNotEmpty)
            Column(
               children:
                  flights.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final flight = entry.value;
                    if (flight == null)
                      return const SizedBox.shrink(); // Sécurité
                    final price = flight['price']?['grandTotal'] ?? 'N/A';
                    final currency = flight['price']?['currency'] ?? '';
                    final itineraries = flight['itineraries'] ?? [];
                    final segments =
                        itineraries.isNotEmpty
                            ? itineraries[0]['segments']
                            : [];
                    final departure =
                        segments.isNotEmpty ? segments[0]['departure'] : {};
                    final arrival =
                        segments.isNotEmpty ? segments[0]['arrival'] : {};
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: idx == 0 ? 6 : 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: idx == 0
                        ? const BorderSide(color: Color(0xFF10a7a7), width: 2)
                        : BorderSide.none,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.flight, color: Color(0xFF10a7a7), size: 40),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (idx == 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.orange,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text('Best Price', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                ),
                              Text(
                                "${departure['iataCode'] ?? ''} → ${arrival['iataCode'] ?? ''}",
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Départ: ${departure['at'] ?? ''}\nArrivée: ${arrival['at'] ?? ''}",
                                style: const TextStyle(fontSize: 13, color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "$price $currency",
                              style: const TextStyle(
                                color: Color(0xFF10a7a7),
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: () => bookFlight(flight),
                              icon: const Icon(Icons.shopping_cart, size: 16),
                              label: const Text('Book Now', style: TextStyle(fontSize: 13)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF10a7a7),
                                minimumSize: const Size(100, 36),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          if (loading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  Widget _typeButton(String label, String value) {
    final bool active = selectedType == value;
    return OutlinedButton.icon(
      icon: Icon(
        value == 'hotels'
            ? Icons.hotel
            : value == 'flights'
            ? Icons.flight
            : Icons.smart_toy,
        color: active ? Colors.white : const Color(0xFF10a7a7),
      ),
      label: Text(
        label,
        style: TextStyle(
          color: active ? Colors.white : const Color(0xFF10a7a7),
          fontWeight: FontWeight.bold,
        ),
      ),
      style: OutlinedButton.styleFrom(
        backgroundColor: active ? const Color(0xFF10a7a7) : Colors.white,
        side: const BorderSide(color: Color(0xFF10a7a7)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      ),
      onPressed: () => setState(() {
        selectedType = value;
        error = '';
        loading = false;
        if (value == 'flights') {
          hotelQuery = '';
          hotelArrivalDate = '';
          hotelDepartureDate = '';
          hotels = [];
          hotelQueryController.clear();
          // Vide aussi les dates d'hôtel si tu utilises des contrôleurs
        } else if (value == 'hotels') {
          origin = '';
          destination = '';
          departureDate = '';
          travelType = '';
          tourDuration = '';
          flights = [];
          originController.clear();
          destinationController.clear();
          // Vide aussi la date de vol si tu utilises un contrôleur
        }
      }),
    );
  }

  String formatDateTime(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return iso;
    }
  }

  void printParams() {
    print('origin=$origin, destination=$destination, departureDate=$departureDate');
  }
}
