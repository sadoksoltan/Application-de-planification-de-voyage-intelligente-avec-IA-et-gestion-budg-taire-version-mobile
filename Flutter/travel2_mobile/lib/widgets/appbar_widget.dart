import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


class AppbarWidget extends StatelessWidget implements PreferredSizeWidget {
  final bool isAuthenticated;
  final String? userName;
  final String? userEmail; 
  final VoidCallback? onLogout;

  const AppbarWidget({
    super.key,
    this.isAuthenticated = false,
    this.userName,
    this.userEmail, 
    this.onLogout,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  Future<void> _handleLogout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token != null) {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      await prefs.remove('auth_token');
      await prefs.remove('name');
      await prefs.remove('role');
      await prefs.remove('email');
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vous avez été déconnecté.')),
        );
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la déconnexion.'), backgroundColor: Colors.red),
        );
      }
    }
    if (onLogout != null) onLogout!();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Builder(
        builder:
            (context) => IconButton(
              icon: const Icon(Icons.menu, color: Color(0xFF10a7a7)),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
      ),
      title: const Text(
        'Travel',
        style: TextStyle(
          color: Color(0xFF10a7a7),
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
      ),
      actions: [
        isAuthenticated
            ? PopupMenuButton<String>(
                child: Row(
                  children: [
                    const Icon(Icons.account_circle, color: Color(0xFF10a7a7)),
                    const SizedBox(width: 4),
                    Text(
                      userName ?? 'Profil',
                      style: const TextStyle(color: Color(0xFF10a7a7)),
                    ),
                    const Icon(Icons.arrow_drop_down, color: Color(0xFF10a7a7)),
                  ],
                ),
                onSelected: (value) {
                  if (value == 'profile') {
                    Navigator.pushNamed(
                    context,
                    '/profile',
                    arguments: {
                      'name':
                          userName,
                      'email':
                          userEmail,
                    },
                  );
                  } else if (value == 'logout') {
                    _handleLogout(context);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'profile',
                    child: Text('Profile'),
                  ),
                  const PopupMenuItem(value: 'logout', child: Text('Logout')),
                ],
              )
            : TextButton(
                onPressed: () async {
                  final result = await Navigator.pushNamed(context, '/login');
                  if (result == true && onLogout != null) {
                    onLogout!();
                  }
                },
                child: const Text(
                  'Login/Register',
                  style: TextStyle(color: Color(0xFF10a7a7)),
                ),
              ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10a7a7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              elevation: 2,
              shadowColor: Colors.black12,
            ),
            onPressed: () => Navigator.pushNamed(context, '/booking'),
            child: const Text(
              'Book Now',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
Drawer buildMainDrawer(BuildContext context) {
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          decoration: const BoxDecoration(color: Color(0xFF10a7a7)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              SizedBox(height: 8),
              Text(
                'Travel2',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        _drawerItem(context, Icons.home, 'Home', '/'),
        _drawerItem(context, Icons.info, 'About Us', '/about'),
        _drawerItem(context, Icons.place, 'Destinations', '/destination-list'),
        _drawerItem(context, Icons.tour, 'Tours', '/tour-list'),
        _drawerItem(context, Icons.people, 'Our Guide', '/team'),
        _drawerItem(context, Icons.book, 'Booking', '/booking'),
        _drawerItem(
          context,
          Icons.confirmation_num,
          'Confirmation',
          '/confirmation',
        ),
        _drawerItem(
          context,
          Icons.miscellaneous_services,
          'Services',
          '/services',
        ),
        _drawerItem(context, Icons.photo, 'Gallery', '/gallery1'),
        _drawerItem(context, Icons.error, 'Error', '/404'),
        _drawerItem(context, Icons.login, 'Login/Register', '/login'),
        _drawerItem(context, Icons.new_releases, 'Coming Soon', '/comingsoon'),
        _drawerItem(context, Icons.star, 'Testimonial', '/testimonial'),
        _drawerItem(context, Icons.help, 'FAQ', '/faq'),
        _drawerItem(context, Icons.contact_mail, 'Contact Us', '/contact'),
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(
                  FontAwesomeIcons.facebook,
                  color: Color(0xFF10a7a7),
                ),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(
                  FontAwesomeIcons.twitter,
                  color: Color(0xFF10a7a7),
                ),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(
                  FontAwesomeIcons.instagram,
                  color: Color(0xFF10a7a7),
                ),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(
                  FontAwesomeIcons.linkedin,
                  color: Color(0xFF10a7a7),
                ),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

ListTile _drawerItem(
  BuildContext context,
  IconData icon,
  String label,
  String route,
) {
  return ListTile(
    leading: Icon(icon, color: const Color(0xFF10a7a7)),
    title: Text(label),
    onTap: () {
      Navigator.pop(context);
      Navigator.pushNamed(context, route);
    },
  );
}
