import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
        backgroundColor: Color(0xFF10a7a7),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(
                'assets/images/elyos_digital_logo.png',
                height: 100,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Elyos Digital is a Tunisian web agency specialized in the design and development of custom digital solutions. It supports its clients in the digital transformation of their projects through strong technical expertise and a results-oriented approach.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              "Elyos Digital operates in the following areas:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const ListTile(
              leading: Icon(Icons.lightbulb_outline, color: Color(0xFF10a7a7)),
              title: Text(
                "Digital Strategy Consulting",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                "Supporting businesses in defining their digital needs and planning their web and mobile projects.",
              ),
            ),
            const ListTile(
              leading: Icon(Icons.web, color: Color(0xFF10a7a7)),
              title: Text(
                "Web Development",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                "Building robust and scalable websites and web applications using modern technologies.",
              ),
            ),
            const ListTile(
              leading: Icon(Icons.phone_android, color: Color(0xFF10a7a7)),
              title: Text(
                "Mobile Development",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                "Creation of cross-platform mobile applications using Flutter, ensuring performance, smoothness, and Android/iOS compatibility.",
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Technologies Used",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const ListTile(
              leading: Icon(Icons.flutter_dash, color: Color(0xFF10a7a7)),
              title: Text("Flutter"),
              subtitle: Text(
                "An open-source framework for cross-platform mobile development.",
              ),
            ),
            const ListTile(
              leading: Icon(Icons.code, color: Color(0xFF10a7a7)),
              title: Text("Laravel"),
              subtitle: Text(
                "A modern PHP framework used for developing secure and modular backends.",
              ),
            ),
            const ListTile(
              leading: Icon(Icons.view_quilt, color: Color(0xFF10a7a7)),
              title: Text("Vue.js"),
              subtitle: Text(
                "A reactive JavaScript framework, ideal for creating dynamic user interfaces.",
              ),
            ),
            const ListTile(
              leading: Icon(Icons.shopping_cart, color: Color(0xFF10a7a7)),
              title: Text("PrestaShop"),
              subtitle: Text(
                "An e-commerce solution that allows the creation of customized online stores.",
              ),
            ),
            const ListTile(
              leading: Icon(Icons.design_services, color: Color(0xFF10a7a7)),
              title: Text(
                "Adobe Suite (Photoshop, Illustrator, XD, After Effects, etc.)",
              ),
              subtitle: Text(
                "Tools used for interface design, graphic creation, and more.",
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Company Profile",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Table(
              border: TableBorder.all(color: Colors.grey),
              columnWidths: const {
                0: FixedColumnWidth(140),
                1: FlexColumnWidth(),
              },
              children: const [
                TableRow(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "Company name",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("Elyos Digital"),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "Sector",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("Information Technology and Services"),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "Technical Director",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("Mr. Maher Sakka"),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "Headquarters",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("Monastir, Tunis"),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "Address",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("Rue Mohamed Slim, Monastir 5000"),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "Phone",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("+216 73 449 596"),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "Email",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("contact@elyosdigital.com"),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "Website",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("https://www.elyosdigital.com/"),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "LinkedIn",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "https://www.linkedin.com/company/elyosdigital/",
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              "App developed by Sadok Soltan",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Color(0xFF10a7a7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
