import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../widgets/pixel_panel.dart';
import '../../models/recipe_model.dart';
import '../recipes/recipe_detail_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String? uid;

  const ProfileScreen({super.key, this.uid});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  
  late String targetUid;
  late bool isOwner;
  bool isLoading = true;
  
  String displayName = 'Wandering Guest';
  String photoUrl = '';
  List<String> userTraits = [];
  List<Recipe> userRecipes = [];

  final List<String> availableTraits = [
    'Pyromaniac (Grill Master)',
    'Sweet Tooth',
    'Alchemist (Mixologist)',
    'Herbologist (Veggie)',
    'Carnivore',
    'Speedrunner (Fast Meals)',
    'Perfectionist',
    'Tavern Brawler (Spicy Food)',
  ];

  @override
  void initState() {
    super.initState();
    targetUid = widget.uid ?? _auth.currentUser?.uid ?? '';
    isOwner = targetUid == _auth.currentUser?.uid;
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    if (targetUid.isEmpty) return;
    
    try {
      final userDoc = await _firestore.collection('users').doc(targetUid).get();
      
      if (userDoc.exists) {
        final data = userDoc.data()!;
        displayName = data['displayName'] ?? 'Unknown Chef';
        photoUrl = data['photoUrl'] ?? '';
        userTraits = List<String>.from(data['traits'] ?? []);
      } else if (isOwner && _auth.currentUser != null) {
        displayName = _auth.currentUser!.displayName ?? 'New Chef';
        photoUrl = _auth.currentUser!.photoURL ?? '';
        await _firestore.collection('users').doc(targetUid).set({
          'displayName': displayName,
          'photoUrl': photoUrl,
          'traits': [],
        });
      }

      final recipesQuery = await _firestore.collection('recipes').where('authorId', isEqualTo: targetUid).get();
      
      userRecipes = recipesQuery.docs.map((doc) {
        final data = doc.data();
        return Recipe(
          id: doc.id,
          title: data['title'] ?? '',
          authorId: data['authorId'] ?? '',
          authorName: data['authorName'] ?? '',
          category: data['category'] ?? 'General',
          ingredients: List<String>.from(data['ingredients'] ?? []),
          instructions: List<String>.from(data['instructions'] ?? []),
          isPublic: data['isPublic'] ?? true,
          status: data['status'] ?? 'approved',
          createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();

    } catch (e) {
      debugPrint(e.toString());
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _pickAndUploadImage() async {
    if (!isOwner) return;
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 600);
      if (image == null) return;

      setState(() => isLoading = true);
      final ref = FirebaseStorage.instance.ref().child('avatars/$targetUid.jpg');
      await ref.putFile(File(image.path));
      final url = await ref.getDownloadURL();

      await _auth.currentUser?.updatePhotoURL(url);
      await _firestore.collection('users').doc(targetUid).update({'photoUrl': url});
      
      setState(() {
        photoUrl = url;
        isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload Error: $e')));
      }
    }
  }

  Future<void> _editName() async {
    if (!isOwner) return;
    TextEditingController controller = TextEditingController(text: displayName);
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2B1D14),
        title: Text('CHANGE NAME', style: GoogleFonts.pixelifySans(color: const Color(0xFFDAA520))),
        content: TextField(
          controller: controller,
          style: GoogleFonts.vt323(fontSize: 24, color: const Color(0xFFF4EAD4)),
          decoration: const InputDecoration(
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF5C3A21))),
            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFFDAA520))),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('CANCEL', style: GoogleFonts.vt323(fontSize: 20, color: Colors.grey))),
          TextButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                await _auth.currentUser?.updateDisplayName(newName);
                await _firestore.collection('users').doc(targetUid).update({'displayName': newName});
                setState(() => displayName = newName);
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: Text('SAVE', style: GoogleFonts.vt323(fontSize: 20, color: const Color(0xFFDAA520))),
          ),
        ],
      ),
    );
  }

  Future<void> _editTraits() async {
    if (!isOwner) return;
    List<String> tempTraits = List.from(userTraits);

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF2B1D14),
            title: Text('SELECT TRAITS (MAX 3)', style: GoogleFonts.pixelifySans(color: const Color(0xFFDAA520))),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: availableTraits.length,
                itemBuilder: (context, index) {
                  final trait = availableTraits[index];
                  final isSelected = tempTraits.contains(trait);
                  return CheckboxListTile(
                    activeColor: const Color(0xFFDAA520),
                    checkColor: const Color(0xFF1A0F08),
                    title: Text(trait, style: GoogleFonts.vt323(fontSize: 20, color: const Color(0xFFF4EAD4))),
                    value: isSelected,
                    onChanged: (bool? val) {
                      setDialogState(() {
                        if (val == true && tempTraits.length < 3) {
                          tempTraits.add(trait);
                        } else if (val == false) {
                          tempTraits.remove(trait);
                        }
                      });
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text('CANCEL', style: GoogleFonts.vt323(fontSize: 20, color: Colors.grey))),
              TextButton(
                onPressed: () async {
                  await _firestore.collection('users').doc(targetUid).update({'traits': tempTraits});
                  setState(() => userTraits = List.from(tempTraits));
                  if (context.mounted) Navigator.pop(context);
                },
                child: Text('SAVE', style: GoogleFonts.vt323(fontSize: 20, color: const Color(0xFFDAA520))),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF4EAD4),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF8B5A2B))),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4EAD4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A0F08),
        title: Text(isOwner ? 'MY CHARACTER' : 'CHEF PROFILE', style: GoogleFonts.pixelifySans(color: const Color(0xFFF4EAD4))),
        iconTheme: const IconThemeData(color: Color(0xFFF4EAD4)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            PixelPanel(
              baseColor: const Color(0xFFFFFFFF),
              padding: const EdgeInsets.all(24.0),
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
                          backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                          child: photoUrl.isEmpty ? const Icon(Icons.person, size: 60, color: Color(0xFFF4EAD4)) : null,
                        ),
                        if (isOwner)
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(color: Color(0xFF1A0F08), shape: BoxShape.circle),
                            child: const Icon(Icons.camera_alt, color: Color(0xFFDAA520), size: 20),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(displayName, style: GoogleFonts.pixelifySans(fontSize: 32, color: const Color(0xFF1A0F08))),
                      if (isOwner)
                        IconButton(icon: const Icon(Icons.edit, color: Color(0xFF8B5A2B)), onPressed: _editName),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Divider(color: Color(0xFF8B5A2B), thickness: 2),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('CHARACTER TRAITS', style: GoogleFonts.pixelifySans(fontSize: 20, color: const Color(0xFF1A0F08))),
                      if (isOwner)
                        IconButton(icon: const Icon(Icons.edit, color: Color(0xFF8B5A2B)), onPressed: _editTraits),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (userTraits.isEmpty)
                    Text('No traits discovered yet...', style: GoogleFonts.vt323(fontSize: 20, color: Colors.grey[600]))
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: userTraits.map((trait) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFE6CE),
                          border: Border.all(color: const Color(0xFF5C3A21), width: 2),
                        ),
                        child: Text(trait, style: GoogleFonts.vt323(fontSize: 18, color: const Color(0xFF1A0F08), fontWeight: FontWeight.bold)),
                      )).toList(),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('AUTHORED TOMES', style: GoogleFonts.pixelifySans(fontSize: 24, color: const Color(0xFF1A0F08), fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (userRecipes.isEmpty)
              Text('This chef hasn\'t penned any recipes yet.', style: GoogleFonts.vt323(fontSize: 22, color: const Color(0xFF5C3A21)))
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: userRecipes.length,
                itemBuilder: (context, index) {
                  final recipe = userRecipes[index];
                  return GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipe))),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFFFF),
                        border: Border.all(color: const Color(0xFF8B5A2B), width: 2),
                        boxShadow: const [BoxShadow(color: Color(0x40000000), offset: Offset(2, 2))],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.menu_book, color: Color(0xFFDAA520), size: 32),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(recipe.title, style: GoogleFonts.pixelifySans(fontSize: 20, color: const Color(0xFF1A0F08))),
                                Text(recipe.category, style: GoogleFonts.vt323(fontSize: 18, color: const Color(0xFF5C3A21))),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, color: Color(0xFF8B5A2B), size: 16),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}