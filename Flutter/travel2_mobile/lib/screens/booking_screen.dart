import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
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

class _BookingScreenState extends State<BookingScreen> {
  // Form fields
  String title = '';
  String firstName = '';
  String lastName = '';
  String email = '';
  String phone = '';
  String gender = '';
  DateTime? dob;
  String country = '';
  String city = '';
  String address1 = '';
  String address2 = '';
  bool agreeTerms = false;
  int paymentTab = 0; // 0: Card, 1: Digital

  // Booking logic
  bool isLoading = false;
  bool isConfirmed = false;
  String errorMsg = '';

  // Pour le reçu
  DateTime? bookingDate;

  // Réservations utilisateur
  List<Booking> userBookings = [];
  double totalAmount = 0.0;
  String currency = 'USD';

  @override
  void initState() {
    super.initState();
    _loadUserBookings();
  }

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') ?? '';
  }

  Future<void> _loadUserBookings() async {
    final token = await _getToken();
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/bookings'),
        headers: token.isNotEmpty ? {'Authorization': 'Bearer $token'} : {},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List bookingsData = data['bookings'] ?? [];
        setState(() {
          userBookings = bookingsData.map((e) => Booking.fromJson(e)).toList();
          totalAmount = userBookings.fold(0.0, (sum, b) {
            final price = double.tryParse(b.price) ?? 0.0;
            return sum + price;
          });
          currency = userBookings.isNotEmpty ? userBookings[0].currency : 'USD';
        });
      }
    } catch (e) {
      // ignore error
    }
  }

  // Vérifie que le formulaire est complet
  bool get isFormComplete =>
      title.isNotEmpty &&
      firstName.isNotEmpty &&
      lastName.isNotEmpty &&
      email.isNotEmpty &&
      phone.isNotEmpty &&
      gender.isNotEmpty &&
      dob != null &&
      country.isNotEmpty &&
      city.isNotEmpty &&
      address1.isNotEmpty &&
      agreeTerms;

  Future<void> confirmBooking() async {
    if (!isFormComplete) return;
    setState(() {
      isConfirmed = true;
      bookingDate = DateTime.now();
      errorMsg = '';
    });

    await _printReceipt();
  }

  Future<void> _printReceipt() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Reçu de paiement', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 16),
            pw.Text('Nom : $title $firstName $lastName'),
            pw.Text('Email : $email'),
            pw.Text('Téléphone : $phone'),
            pw.Text('Genre : $gender'),
            pw.Text('Date de naissance : ${dob != null ? "${dob!.year}-${dob!.month.toString().padLeft(2, '0')}-${dob!.day.toString().padLeft(2, '0')}" : ''}'),
            pw.Text('Pays : $country'),
            pw.Text('Ville : $city'),
            pw.Text('Adresse : $address1 $address2'),
            pw.Divider(),
            pw.Text('Nombre de réservations : ${userBookings.length}'),
            pw.Text('Montant total : ${totalAmount.toStringAsFixed(2)} $currency'),
            pw.Text('Tax & fee : 50.00 $currency'),
            pw.Text('Booking Fee : Free'),
            pw.Text('Total : ${(totalAmount + 50).toStringAsFixed(2)} $currency'),
            pw.Divider(),
            pw.Text('Statut : Payé'),
            pw.Text('Date : ${bookingDate != null ? bookingDate!.toLocal().toString() : DateTime.now().toLocal().toString()}'),
          ],
        ),
      ),
    );
    await Printing.layoutPdf(onLayout: (format) => pdf.save());
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
    final isWide = MediaQuery.of(context).size.width > 700;
    return Scaffold(
      appBar: AppBar(title: const Text('Booking')),
      body:
          isConfirmed
              ? _buildReceipt()
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child:
                    isWide
                        ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 2, child: _buildMainForm()),
                            const SizedBox(width: 24),
                            Expanded(flex: 1, child: _buildSidebar()),
                          ],
                        )
                        : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildMainForm(),
                            const SizedBox(height: 24),
                            _buildSidebar(),
                            const SizedBox(height: 24),
                            _buildBookingList(),
                          ],
                        ),
              ),
    );
  }

  Widget _buildMainForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Traveller Information
        Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Traveller Information',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: title.isEmpty ? null : title,
                        decoration: const InputDecoration(labelText: 'Title'),
                        items: const [
                          DropdownMenuItem(value: 'Mr.', child: Text('Mr.')),
                          DropdownMenuItem(value: 'Mrs.', child: Text('Mrs.')),
                        ],
                        onChanged: (v) => setState(() => title = v ?? ''),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'First Name',
                        ),
                        onChanged: (v) => firstName = v,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'Last Name',
                        ),
                        onChanged: (v) => lastName = v,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(labelText: 'Email'),
                        onChanged: (v) => email = v,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(labelText: 'Phone'),
                        onChanged: (v) => phone = v,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: gender.isEmpty ? null : gender,
                        decoration: const InputDecoration(labelText: 'Gender'),
                        items: const [
                          DropdownMenuItem(value: 'Male', child: Text('Male')),
                          DropdownMenuItem(
                            value: 'Female',
                            child: Text('Female'),
                          ),
                        ],
                        onChanged: (v) => setState(() => gender = v ?? ''),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime(2000),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) setState(() => dob = picked);
                        },
                        child: AbsorbPointer(
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: 'DOB',
                              hintText:
                                  dob != null
                                      ? "${dob!.year}-${dob!.month.toString().padLeft(2, '0')}-${dob!.day.toString().padLeft(2, '0')}"
                                      : 'YYYY-MM-DD',
                            ),
                            controller: TextEditingController(
                              text:
                                  dob != null
                                      ? "${dob!.year}-${dob!.month.toString().padLeft(2, '0')}-${dob!.day.toString().padLeft(2, '0')}"
                                      : '',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: country.isEmpty ? null : country,
                        decoration: const InputDecoration(labelText: 'Country'),
                        items: const [
                          DropdownMenuItem(
                            value: 'Albania',
                            child: Text('Albania'),
                          ),
                          DropdownMenuItem(
                            value: 'Malaysia',
                            child: Text('Malaysia'),
                          ),
                          DropdownMenuItem(
                            value: 'Singapore',
                            child: Text('Singapore'),
                          ),
                          DropdownMenuItem(
                            value: 'Japan',
                            child: Text('Japan'),
                          ),
                          DropdownMenuItem(
                            value: 'Thailand',
                            child: Text('Thailand'),
                          ),
                        ],
                        onChanged: (v) => setState(() => country = v ?? ''),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: city.isEmpty ? null : city,
                        decoration: const InputDecoration(labelText: 'City'),
                        items: const [
                          DropdownMenuItem(
                            value: 'Istanbul',
                            child: Text('Istanbul'),
                          ),
                          DropdownMenuItem(
                            value: 'London',
                            child: Text('London'),
                          ),
                          DropdownMenuItem(
                            value: 'Texas',
                            child: Text('Texas'),
                          ),
                          DropdownMenuItem(
                            value: 'Tokyo',
                            child: Text('Tokyo'),
                          ),
                          DropdownMenuItem(
                            value: 'Bangkok',
                            child: Text('Bangkok'),
                          ),
                        ],
                        onChanged: (v) => setState(() => city = v ?? ''),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'Address Line 1',
                        ),
                        onChanged: (v) => address1 = v,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'Address Line 2',
                        ),
                        onChanged: (v) => address2 = v,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Good to know
        Card(
          margin: const EdgeInsets.only(bottom: 16),
          color: Colors.grey[100],
          child: ListTile(
            leading: const Icon(
              Icons.emoji_emotions,
              color: Colors.teal,
              size: 40,
            ),
            title: const Text('Good To Know:'),
            subtitle: const Text(
              'Free Cancellation until 14:00 on 30 Jul 2025',
            ),
          ),
        ),
        // Payment
        Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'How do you want to pay?',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 8),
                ToggleButtons(
                  isSelected: [paymentTab == 0, paymentTab == 1],
                  onPressed: (i) => setState(() => paymentTab = i),
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('Credit/Debit card'),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('Digital Payment'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (paymentTab == 0)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Credit Card',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: const InputDecoration(
                                labelText: 'Card Holder Number',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              decoration: const InputDecoration(
                                labelText: 'Card Number',
                                hintText: '**** **** **** ****',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: const InputDecoration(
                                labelText: 'Expiry Date',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              decoration: const InputDecoration(
                                labelText: 'CVC/CVV',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Paypal',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'To make the payment process secure and complete you will be redirected to Paypal Website.',
                      ),
                      SizedBox(height: 8),
                      Text(
                        'The total Amount you will be charged is: \$245.50',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(
                      value: agreeTerms,
                      onChanged: (v) => setState(() => agreeTerms = v ?? false),
                    ),
                    const Expanded(
                      child: Text(
                        'By continuing, you agree to the Terms and Conditions.',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (errorMsg.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      errorMsg,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ElevatedButton(
                  onPressed:
                      isFormComplete && !isLoading ? confirmBooking : null,
                  child:
                      isLoading
                          ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Text('CONFIRM BOOKING'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(40),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSidebar() {
    const taxFee = 50.0;
    const bookingFee = 0.0;
    final totalWithTax = totalAmount + taxFee;
    return Column(
      children: [
        Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Price Summary',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Amount'),
                    Text('${totalAmount.toStringAsFixed(2)} $currency'),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Nombre de réservations'),
                    Text('${userBookings.length}'),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tax & fee'),
                    Text('${taxFee.toStringAsFixed(2)} $currency'),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Booking Fee'),
                    Text(
                      bookingFee == 0
                          ? 'Free'
                          : '${bookingFee.toStringAsFixed(2)} $currency',
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${totalWithTax.toStringAsFixed(2)} $currency',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text("Before you stay you'll pay"),
                Text('\$40.00'),
              ],
            ),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Do you have a promo code?',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Promo code',
                    suffixIcon: TextButton(
                      onPressed: () {},
                      child: const Text('Apply'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBookingList() {
    if (userBookings.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Text(
          "Mes vols réservés",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF10a7a7),
          ),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: userBookings.length,
          itemBuilder: (context, i) {
            final booking = userBookings[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const Icon(Icons.flight, color: Color(0xFF10a7a7)),
                title: Text(
                  "${booking.from} → ${booking.to}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text("Réservé le ${formatDate(booking.date)}"),
                trailing: Text(
                  "${booking.price} ${booking.currency}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildReceipt() {
    const taxFee = 50.0;
    final totalWithTax = totalAmount + taxFee;
    return Center(
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Reçu de paiement',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 16),
              _receiptRow('Nom', '$title $firstName $lastName'),
              _receiptRow('Email', email),
              _receiptRow('Téléphone', phone),
              _receiptRow('Genre', gender),
              _receiptRow(
                'Date de naissance',
                dob != null
                    ? "${dob!.year}-${dob!.month.toString().padLeft(2, '0')}-${dob!.day.toString().padLeft(2, '0')}"
                    : '',
              ),
              _receiptRow('Pays', country),
              _receiptRow('Ville', city),
              _receiptRow('Adresse', '$address1 $address2'),
              const Divider(),
              _receiptRow('Nombre de réservations', '${userBookings.length}'),
              _receiptRow(
                'Montant total',
                '${totalAmount.toStringAsFixed(2)} $currency',
              ),
              _receiptRow(
                'Tax & fee',
                '${taxFee.toStringAsFixed(2)} $currency',
              ),
              _receiptRow('Booking Fee', 'Free'),
              _receiptRow(
                'Total',
                '${totalWithTax.toStringAsFixed(2)} $currency',
              ),
              const Divider(),
              _receiptRow('Statut', 'Payé', valueColor: Colors.green),
              _receiptRow(
                'Date',
                bookingDate != null
                    ? bookingDate!.toLocal().toString()
                    : DateTime.now().toLocal().toString(),
              ),
              const SizedBox(height: 24),
              const Text(
                'Merci pour votre réservation !',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _receiptRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label : ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: valueColor ?? Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
