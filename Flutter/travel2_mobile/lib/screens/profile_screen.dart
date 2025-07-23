import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  final String? initialName;
  final String? initialEmail;

  const ProfileScreen({Key? key, this.initialName, this.initialEmail})
    : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String email = '';
  String password = '';
  String? avatarUrl =
      'https://img.freepik.com/free-vector/smiling-young-man-illustration_1308-174669.jpg?semt=ais_hybrid&w=740';
  XFile? avatarFile;
  String? successMsg;
  String? errorMsg;

  @override
  void initState() {
    super.initState();
    // Simuler la récupération des infos utilisateur
    name = widget.initialName ?? 'Utilisateur';
    email = widget.initialEmail ?? 'user@email.com';
  }

  Future<void> pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        avatarFile = picked;
        avatarUrl = picked.path;
      });
    }
  }

  void handleSave() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        successMsg = 'Profil mis à jour avec succès !';
        errorMsg = null;
      });
      Future.delayed(const Duration(seconds: 3), () {
        setState(() {
          successMsg = null;
        });
      });
    } else {
      setState(() {
        errorMsg = 'Erreur lors de la mise à jour du profil.';
        successMsg = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF7FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF10a7a7),
        elevation: 0,
        title: const Text('Mon Profil', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.home, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        children: [
          // Profile Hero
          Stack(
            children: [
              Container(
                height: 180,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF10a7a7), Color(0xFF2dd4bf)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              Positioned.fill(
                child: Opacity(
                  opacity: 0.18,
                  child: Image.network(
                    'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?auto=format&fit=crop&w=1200&q=80',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned.fill(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: pickAvatar,
                      child: CircleAvatar(
                        radius: 55,
                        backgroundColor: Colors.white,
                        backgroundImage:
                            avatarFile != null
                                ? Image.file(
                                  File(avatarFile!.path),
                                  fit: BoxFit.cover,
                                ).image
                                : NetworkImage(avatarUrl!),
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.teal,
                            child: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        foreground:
                            Paint()
                              ..shader = LinearGradient(
                                colors: [Colors.white, Colors.white],
                              ).createShader(
                                Rect.fromLTWH(0, 0, 200, 70),
                              ),
                      ),
                    ),
                    Text(
                      email,
                      style: const TextStyle(
                        color: Color(0xFFE0F7FA),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Profile Form
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 0),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 28),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.92),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF10a7a7).withOpacity(0.13),
                  blurRadius: 32,
                  offset: const Offset(0, 6),
                ),
                const BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 1.5),
                ),
              ],
              border: Border.all(color: const Color(0xFFE0F2F1), width: 1.5),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Text(
                    'Mon Profil',
                    style: TextStyle(
                      color: Color(0xFF10a7a7),
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Name
                  TextFormField(
                    initialValue: name,
                    decoration: const InputDecoration(
                      labelText: 'Nom',
                      prefixIcon: Icon(Icons.person, color: Color(0xFF10a7a7)),
                      border: OutlineInputBorder(),
                    ),
                    validator:
                        (v) => v == null || v.isEmpty ? 'Nom requis' : null,
                    onChanged: (v) => name = v,
                  ),
                  const SizedBox(height: 18),
                  // Email
                  TextFormField(
                    initialValue: email,
                    enabled: false,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email, color: Color(0xFF10a7a7)),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 18),
                  // Avatar
                  Row(
                    children: [
                      const Icon(Icons.image, color: Color(0xFF10a7a7)),
                      const SizedBox(width: 8),
                      const Text('Avatar'),
                      const Spacer(),
                      TextButton(
                        onPressed: pickAvatar,
                        child: const Text(
                          'Changer',
                          style: TextStyle(color: Color(0xFF10a7a7)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Password
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Nouveau mot de passe',
                      prefixIcon: Icon(Icons.lock, color: Color(0xFF10a7a7)),
                      border: OutlineInputBorder(),
                      hintText: 'Laisser vide pour ne pas changer',
                    ),
                    obscureText: true,
                    onChanged: (v) => password = v,
                  ),
                  const SizedBox(height: 22),
                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: const Text('Enregistrer les modifications'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10a7a7),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      onPressed: handleSave,
                    ),
                  ),
                  if (successMsg != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 18),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Color(0xFF10a7a7),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            successMsg!,
                            style: const TextStyle(color: Color(0xFF10a7a7)),
                          ),
                        ],
                      ),
                    ),
                  if (errorMsg != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 18),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error, color: Colors.red),
                          const SizedBox(width: 8),
                          Text(
                            errorMsg!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
