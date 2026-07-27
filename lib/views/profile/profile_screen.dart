import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../widgets/pixel_panel.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();
  late TextEditingController nameController;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = _auth.currentUser;
    nameController = TextEditingController(text: user?.displayName ?? 'Tavern Guest');
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 600);
      if (image == null) return;

      setState(() => isLoading = true);

      final ref = FirebaseStorage.instance.ref().child('avatars/${user.uid}.jpg');
      await ref.putFile(File(image.path));
      final url = await ref.getDownloadURL();

      await user.updatePhotoURL(url);
      await user.reload();

      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Avatar Updated!')));
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload Error: $e')));
      }
    }
  }

  Future<void> saveProfile() async {
    setState(() => isLoading = true);
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(nameController.text.trim());
        await user.reload();
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile Updated!')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    return Scaffold(
      backgroundColor: const Color(0xFFF4EAD4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A0F08),
        title: Text('MY CHARACTER', style: GoogleFonts.pixelifySans(color: const Color(0xFFF4EAD4))),
        iconTheme: const IconThemeData(color: Color(0xFFF4EAD4)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            PixelPanel(
              baseColor: const Color(0xFFFFFFFF),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickAndUploadImage,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: const Color(0xFF8B5A2B),
                          backgroundImage: user?.photoURL != null && user!.photoURL!.isNotEmpty 
                              ? NetworkImage(user.photoURL!) 
                              : null,
                          child: user?.photoURL == null || user!.photoURL!.isEmpty
                              ? const Icon(Icons.person, size: 60, color: Color(0xFFF4EAD4))
                              : null,
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFF1A0F08),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, color: Color(0xFFDAA520), size: 20),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: nameController,
                    style: GoogleFonts.vt323(fontSize: 24),
                    decoration: const InputDecoration(labelText: 'Character Name', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 24),
                  isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: saveProfile,
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A0F08)),
                          child: Text('UPDATE NAME', style: GoogleFonts.pixelifySans(color: const Color(0xFFDAA520), fontSize: 20)),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}