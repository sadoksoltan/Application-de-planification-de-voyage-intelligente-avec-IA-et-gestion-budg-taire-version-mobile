import 'package:flutter/material.dart';
import 'widgets/appbar_widget.dart';
import 'widgets/banner_widget.dart';
import 'screens/login_register_screen.dart';
import 'screens/tour_list_screen.dart';
import 'screens/post_list_screen.dart';
import 'screens/destination_list_screen.dart';
import 'screens/booking_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/reset_password_screen.dart';
import 'screens/about_screen.dart';
import 'screens/ia_tunisia.dart';
void main() {
  runApp(const Travel2App());
}

class Travel2App extends StatefulWidget {
  const Travel2App({super.key});
  @override
  State<Travel2App> createState() => _Travel2AppState();
}

class _Travel2AppState extends State<Travel2App> {
  bool isAuthenticated = false;
  String? userName;
  String? userEmail;

  void setAuth(bool auth, String? name, [String? email]) {
    setState(() {
      isAuthenticated = auth;
      userName = name;
      userEmail = email;
    });
  }

  void handleLogout() {
    setAuth(false, null);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TRAVEL',
      initialRoute: '/',
      routes: {
        '/':
            (context) => HomeScreen(
              isAuthenticated: isAuthenticated,
              userName: userName,
              userEmail: userEmail,
              onLogout: handleLogout,
            ),
        '/about':
            (context) => AboutScreen(),
            
        '/destination-list': (context) => DestinationListScreen(),
        '/tour-list': (context) => TourListScreen(),
        '/team':
            (context) => DummyScreen(
              title: 'Our Guide',
              isAuthenticated: isAuthenticated,
              userName: userName,
              onLogout: handleLogout,
            ),
        '/booking': (context) => BookingScreen(),
        '/404':
            (context) => DummyScreen(
              title: 'Error',
              isAuthenticated: isAuthenticated,
              userName: userName,
              onLogout: handleLogout,
            ),
        '/login':
            (context) => LoginRegisterScreen(
              onLogin: (name) => setAuth(true, name),
              onLogout: handleLogout,
            ),
        '/register':
            (context) => LoginRegisterScreen(
              onLogin: (name) => setAuth(true, name),
              onLogout: handleLogout,
            ),
        '/services':
            (context) => DummyScreen(
              title: 'Services',
              isAuthenticated: isAuthenticated,
              userName: userName,
              onLogout: handleLogout,
            ),
        '/blog': (context) => PostListScreen(),
        '/profile': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map?;
          return ProfileScreen(
            initialName: args?['name'],
            initialEmail: args?['email'],
          );
        },
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/reset-password': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map?;
          return ResetPasswordScreen(token: args?['token']);
        },
        '/ia_tunisia': (context) => IaTunisiaScreen(),
      },
      onUnknownRoute:
          (settings) => MaterialPageRoute(
            builder:
                (context) => DummyScreen(
                  title: '404 Not Found',
                  isAuthenticated: isAuthenticated,
                  userName: userName,
                  onLogout: handleLogout,
                ),
          ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final bool isAuthenticated;
  final String? userName;
  final String? userEmail;
  final VoidCallback? onLogout;
  const HomeScreen({
    super.key,
    this.isAuthenticated = false,
    this.userName,
    this.userEmail,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarWidget(
        isAuthenticated: isAuthenticated,
        userName: userName,
        onLogout: onLogout,
      ),
      drawer: buildMainDrawer(context),
      body: SingleChildScrollView(
        child: Column(
          children: const [
            BannerWidget(),
            // ...
          ],
        ),
      ),
    );
  }
}

class DummyScreen extends StatelessWidget {
  final String title;
  final bool isAuthenticated;
  final String? userName;
  final VoidCallback? onLogout;
  const DummyScreen({
    super.key,
    required this.title,
    this.isAuthenticated = false,
    this.userName,
    this.onLogout,
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarWidget(
        isAuthenticated: isAuthenticated,
        userName: userName,
        onLogout: onLogout,
      ),
      drawer: buildMainDrawer(context),
      body: Center(child: Text(title, style: const TextStyle(fontSize: 24))),
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
                'Travel',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        ListTile(
          leading: const Icon(Icons.home, color: Color(0xFF10a7a7)),
          title: const Text('Home'),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/');
          },
        ),
        ListTile(
          leading: const Icon(Icons.info, color: Color(0xFF10a7a7)),
          title: const Text('About Us'),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/about');
          },
        ),
        ListTile(
          leading: const Icon(Icons.place, color: Color(0xFF10a7a7)),
          title: const Text('Destinations'),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/destination-list');
          },
        ),
        ListTile(
          leading: const Icon(Icons.article, color: Color(0xFF10a7a7)),
          title: const Text('Blog'),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/blog');
          },
        ),
        ListTile(
          leading: const Icon(Icons.tour, color: Color(0xFF10a7a7)),
          title: const Text('Tours'),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/tour-list');
          },
        ),
        ListTile(
          leading: const Icon(Icons.tour, color: Color(0xFF10a7a7)),
          title: const Text('Tunisie avec l’IA'),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/ia_tunisia');
          },
        ),
        ListTile(
          leading: const Icon(Icons.people, color: Color(0xFF10a7a7)),
          title: const Text('Our Guide'),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/team');
          },
        ),
        ListTile(
          leading: const Icon(Icons.book, color: Color(0xFF10a7a7)),
          title: const Text('Booking'),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/booking');
          },
        ),
        ListTile(
          leading: const Icon(
            Icons.miscellaneous_services,
            color: Color(0xFF10a7a7),
          ),
          title: const Text('Services'),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/services');
          },
        ),
      ],
    ),
  );
}
