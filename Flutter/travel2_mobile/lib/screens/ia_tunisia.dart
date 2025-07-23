import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class IaTunisiaScreen extends StatefulWidget {
  const IaTunisiaScreen({super.key});

  @override
  State<IaTunisiaScreen> createState() => _IaTunisiaScreenState();
}

class _IaTunisiaScreenState extends State<IaTunisiaScreen> {
  final List<String> villesTunisie = [
    'Tunis',
    'La Goulette',
    'Le Bardo',
    'Carthage',
    'Manouba',
    'Hrairia',
    'Cite Ettadhamen',
    'Fouchana',
    'Le Kram',
    'Mourouj',
    'Sijoumi',
    'Ghazela',
    'Radès',
    'Ariana',
    'Ezzahra',
    'Rades',
    'Ezzhouhour',
    'Mnihla',
    'Khalidia',
    'Ariana Ville',
    'Kalatin',
    'Saouaf',
    'Raoued',
    'Bizerte',
    'Tinja',
    'Menzel Abderrahmane',
    'Dugga',
    'Teboulba',
    'El Alia',
    'El Battah',
    'Beja',
    'Testour',
    'Oum-Hadjer',
    'El Ksour',
    'Teboursouk',
    'Tlet',
    'Jendouba',
    'Boussalem',
    'Aïn Draham',
    'Fériana',
    'Menzel Bouzelfa',
    'Tella',
    'Aïn Kercha',
    'Kairouan',
    'Chebika',
    'Baghdadi',
    'Hajeb El Ayoun',
    'Hammam-Lif',
    'Hicheur',
    'Haffouz',
    'Sousse',
    'Kanta',
    'Sidi Bou Ali',
    'Hergla',
    'Msaken',
    'Marsa Sghira',
    'Hammam Sousse',
    'Monastir',
    'Ksar Said',
    'El Hamma',
    'Ksar Hellal',
    'Sahline',
    'Sidi El Hadj El Bedi',
    'Zeramdine',
    'Mahdia',
    'Sayada',
    'Sidi Alouane',
    'Ouled Chamekh',
    'El Jem',
    'Sfax',
    'Menzel Chaker',
    'Skhira',
    'Chihia',
    'El Ain',
    'Ghraia',
    'Bir Ali Ben Kheli',
    'Agareb',
    'Gabès',
    'Matmata',
    'Hamma',
    'Zarat',
    'Menzel Hayoun',
    'Medenine',
    'Ben Gardane',
    'Zarzis',
    'Remada',
    'Djerba',
    'Tataouine',
    'Ksar Morra',
    'Tozeur',
    'Nefta',
    'Degache',
    'Hamat',
    'Kasserine',
    'Sbeïtla',
    'Sbitla',
    'Djelfa',
    'Gafsa',
    'Metlaoui',
    'Redeyef',
    'El Ksar',
    'El Guettar',
    'Siliana',
    'El Aroussa',
    'El Ksiba',
    'Rafraf',
    'Zaghouan',
    'Bir Mcherga',
    'El Fahs',
    'Nabeul',
    'Kélibia',
    'Hammamet',
    'Sidi Bou Rhail',
    'Menzel Jemil',
    'Menzel Bourguiba',
    'El Kef',
    'Tajerouine',
    'Kef',
    'Jandouba',
    'La Marsa',
    'Mateur',
    'Ksar es-Sid',
    'Douz',
    'Kebili',
    'Tabarka'
  ];

  final List<Map<String, dynamic>> interetsTunisie = [
    {'text': 'Plage', 'icon': Icons.beach_access},
    {'text': 'Culture', 'icon': Icons.account_balance},
    {'text': 'Nature', 'icon': Icons.park},
    {'text': 'Gastronomie', 'icon': Icons.restaurant},
    {'text': 'Aventure', 'icon': Icons.directions_bike},
    {'text': 'Shopping', 'icon': Icons.shopping_bag},
    {'text': 'Bien-être', 'icon': Icons.spa},
  ];

  String? iaCity;
  DateTime? iaStartDate;
  int iaPeriod = 2;
  double iaBudget = 1500;
  List<String> iaInterests = [];
  String iaTypeSejour = 'Solo';
  bool iaLoading = false;
  String? iaError;
  List<dynamic> iaResultList = [];
  String? iaResult;

  void toggleIaInterest(String interest) {
    setState(() {
      if (iaInterests.contains(interest)) {
        iaInterests.remove(interest);
      } else {
        iaInterests.add(interest);
      }
    });
  }

  Future<void> searchTravelIA() async {
    setState(() {
      iaLoading = true;
      iaError = null;
      iaResult = null;
      iaResultList = [];
    });
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/recommander'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'ville': iaCity,
          'budget': iaBudget.round(),
          'interets': iaInterests.map((e) => e.toLowerCase()).join(','),
          'periode': '${iaPeriod}j',
          'top_k': 2,
        }),
      );
      final data = jsonDecode(response.body);
      if (data['result'] != null && data['result'] is List && data['result'].isNotEmpty) {
        setState(() {
          iaResultList = data['result'];
        });
      } else {
        setState(() {
          iaResult = 'Aucune suggestion trouvée.';
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

  void resetForm() {
    setState(() {
      iaCity = null;
      iaStartDate = null;
      iaPeriod = 2;
      iaBudget = 1500;
      iaInterests = [];
      iaTypeSejour = 'Solo';
      iaResult = null;
      iaResultList = [];
      iaError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Planifiez votre voyage en Tunisie avec l’IA'),
        backgroundColor: const Color(0xFF10a7a7),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                "🇹🇳 Planifiez votre voyage en Tunisie avec l’IA",
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                "Laissez notre assistant intelligent vous proposer un itinéraire sur-mesure, selon vos envies tunisiennes !",
                style: TextStyle(color: Colors.teal[700]),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: iaCity,
                      decoration: const InputDecoration(labelText: "Ville de départ"),
                      items: villesTunisie
                          .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                          .toList(),
                      onChanged: (v) => setState(() => iaCity = v),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Date début"),
                              const SizedBox(height: 4),
                              InkWell(
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: iaStartDate ?? DateTime.now(),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime.now().add(
                                      const Duration(days: 365),
                                    ),
                                  );
                                  if (picked != null) {
                                    setState(() => iaStartDate = picked);
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    iaStartDate != null
                                        ? "${iaStartDate!.day}/${iaStartDate!.month}/${iaStartDate!.year}"
                                        : "Choisir une date",
                                    style: TextStyle(
                                      color:
                                          iaStartDate != null
                                              ? Colors.black
                                              : Colors.grey[600],
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: iaPeriod,
                            decoration: const InputDecoration(labelText: "Période"),
                            items: const [
                              DropdownMenuItem(value: 2, child: Text("2 jours")),
                              DropdownMenuItem(value: 7, child: Text("7 jours")),
                              DropdownMenuItem(value: 14, child: Text("14 jours")),
                              DropdownMenuItem(value: 21, child: Text("21 jours")),
                            ],
                            onChanged: (v) => setState(() => iaPeriod = v ?? 2),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Budget (TND): ${iaBudget.round()}"),
                        Slider(
                          value: iaBudget,
                          min: 100,
                          max: 5000,
                          divisions: 98,
                          label: iaBudget.round().toString(),
                          onChanged: (v) => setState(() => iaBudget = v),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Centres d'intérêt"),
                        Wrap(
                          spacing: 8,
                          children: interetsTunisie.map((interest) {
                            final selected = iaInterests.contains(interest['text']);
                            return ChoiceChip(
                              label: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(interest['icon'], size: 18, color: selected ? Colors.white : Colors.teal),
                                  const SizedBox(width: 4),
                                  Text(interest['text']),
                                ],
                              ),
                              selected: selected,
                              selectedColor: Colors.teal,
                              onSelected: (_) => toggleIaInterest(interest['text']),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: iaTypeSejour,
                      decoration: const InputDecoration(labelText: "Type de séjour"),
                      items: const [
                        DropdownMenuItem(value: "Solo", child: Text("Solo")),
                        DropdownMenuItem(value: "Famille", child: Text("Famille")),
                        DropdownMenuItem(value: "Couple", child: Text("Couple")),
                        DropdownMenuItem(value: "Groupe", child: Text("Groupe")),
                      ],
                      onChanged: (v) => setState(() => iaTypeSejour = v ?? "Solo"),
                    ),
                    const SizedBox(height: 18),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.auto_awesome),
                      label: Text(iaLoading ? "Génération..." : "Générer mon itinéraire IA"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10a7a7),
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      onPressed: iaLoading ? null : searchTravelIA,
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text("Réinitialiser"),
                      onPressed: iaLoading ? null : resetForm,
                    ),
                    if (iaError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(iaError!, style: const TextStyle(color: Colors.red)),
                      ),
                    if (iaResultList.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 18),
                        child: Card(
                          color: Colors.teal[50],
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: const [
                                    Icon(Icons.lightbulb, color: Colors.amber),
                                    SizedBox(width: 8),
                                    Text("Votre itinéraire IA tunisien", style: TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ...iaResultList.map((hotel) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("${hotel['nom']} à ${hotel['ville']} (Note: ${hotel['note']}/10, Prix: ${hotel['prix']} TND)", style: const TextStyle(fontWeight: FontWeight.bold)),
                                      Text("Intérêts: ${hotel['interets']}"),
                                      if (hotel['lien'] != null)
                                        InkWell(
                                          child: Text("Voir l'hôtel", style: TextStyle(color: Colors.blue[700], decoration: TextDecoration.underline)),
                                          onTap: () => launchUrl(Uri.parse(hotel['lien'])),
                                        ),
                                    ],
                                  ),
                                )),
                              ],
                            ),
                          ),
                        ),
                      ),
                    if (iaResult != null && iaResultList.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 18),
                        child: Card(
                          color: Colors.teal[50],
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: const [
                                    Icon(Icons.lightbulb, color: Colors.amber),
                                    SizedBox(width: 8),
                                    Text("Votre itinéraire IA tunisien", style: TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(iaResult!),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
