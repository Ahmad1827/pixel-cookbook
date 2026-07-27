import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../models/recipe_model.dart';
import '../../widgets/pixel_panel.dart';
import '../../widgets/pixel_button.dart';
import '../../widgets/guild_auth_dialog.dart';
import '../recipes/add_recipe_screen.dart';
import '../recipes/recipe_detail_screen.dart';
import '../menus/main_menu_screen.dart';
import '../profile/profile_screen.dart';

class TavernScreen extends StatefulWidget {
  const TavernScreen({super.key});

  @override
  State<TavernScreen> createState() => _TavernScreenState();
}

class _TavernScreenState extends State<TavernScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  bool _showPending = false;
  List<String> _hiddenRecipes = [];
  SharedPreferences? _prefs;
  
  final List<String> _categories = ['All', 'Meat', 'Veggie', 'Dessert', 'Drinks', 'General'];

  @override
  void initState() {
    super.initState();
    _loadHiddenRecipes();
  }

  Future<void> _loadHiddenRecipes() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _hiddenRecipes = _prefs?.getStringList('hidden_recipes') ?? [];
    });
  }

  void _hideRecipeLocal(String recipeId) {
    setState(() {
      _hiddenRecipes.add(recipeId);
      _prefs?.setStringList('hidden_recipes', _hiddenRecipes);
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    final dbService = Provider.of<DatabaseService>(context, listen: false);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth > 800;

    return Scaffold(
      backgroundColor: const Color(0xFF2B1D14),
      floatingActionButton: !isDesktop && !_showPending
          ? FloatingActionButton(
              backgroundColor: const Color(0xFF2E8B57),
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: Color(0xFF1A0F08), width: 3),
                borderRadius: BorderRadius.circular(0),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 32),
              onPressed: () {
                if (user == null) {
                  showGuildAuthDialog(context);
                } else {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const AddRecipeScreen()));
                }
              },
            )
          : null,
      body: isDesktop
          ? _buildDesktopLayout(context, user, dbService)
          : _buildMobileLayout(context, user, dbService),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, User? user, DatabaseService dbService) {
    return Row(
      children: [
        Container(
          width: 320,
          decoration: const BoxDecoration(
            color: Color(0xFF1A0F08),
            border: Border(right: BorderSide(color: Color(0xFF5C3A21), width: 4)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Text(
                _showPending ? 'PENDING\nQUESTS' : 'THE\nTAVERN\nBOARD',
                textAlign: TextAlign.center,
                style: GoogleFonts.pixelifySans(
                  color: _showPending ? const Color(0xFFCD5C5C) : const Color(0xFFFFD700),
                  fontSize: 42,
                  height: 1.1,
                  shadows: const [Shadow(color: Colors.black, offset: Offset(3, 3))],
                ),
              ).animate(target: _showPending ? 1 : 0).tint(color: Colors.red).moveY(begin: -2, end: 2, duration: 2.seconds),
              const SizedBox(height: 20),
              _buildControlPanel(context, user),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: PixelButton(
                  text: 'LEAVE TAVERN',
                  color: const Color(0xFF8B5A2B),
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const MainMenuScreen()),
                      (Route<dynamic> route) => false,
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                color: const Color(0xFF3A2311),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (user == null) {
                          showGuildAuthDialog(context);
                        } else {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
                        }
                      },
                      behavior: HitTestBehavior.opaque, 
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        width: double.infinity,
                        color: const Color(0xFF3A2311),
                        child: Column(
                          children: [
                            Icon(user != null ? Icons.person : Icons.person_outline, color: const Color(0xFFF4EAD4), size: 32),
                            const SizedBox(height: 8),
                            Text(
                              user != null ? 'Chef Logged In\n(Click for Profile)' : 'Wandering Guest\n(Click to Login)',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.vt323(fontSize: 20, color: const Color(0xFFF4EAD4)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (user != null) ...[
                      const SizedBox(height: 16),
                      PixelButton(
                        text: 'LEAVE GUILD',
                        color: const Color(0xFFCD5C5C),
                        onPressed: () async {
                          await Provider.of<AuthService>(context, listen: false).signOut();
                          if (context.mounted) {
                            Navigator.of(context).popUntil((route) => route.isFirst);
                          }
                        },
                      ),
                    ]
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            color: const Color(0xFF3A2311),
            child: _buildRecipeGrid(dbService, user, isDesktop: true),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, User? user, DatabaseService dbService) {
    return SafeArea(
      child: Column(
        children: [
          PixelPanel(
            baseColor: const Color(0xFF1A0F08),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Color(0xFFF4EAD4)),
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const MainMenuScreen()),
                      (Route<dynamic> route) => false,
                    );
                  },
                ),
                Expanded(
                  child: Text(
                    _showPending ? 'PENDING QUESTS' : 'TAVERN BOARD',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.pixelifySans(
                      color: _showPending ? const Color(0xFFCD5C5C) : const Color(0xFFFFD700),
                      fontSize: 24,
                      shadows: const [Shadow(color: Colors.black, offset: Offset(2, 2))],
                    ),
                  ),
                ),
                if (user != null) ...[
                  IconButton(
                    icon: const Icon(Icons.person, color: Color(0xFFF4EAD4)),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Color(0xFFF4EAD4)),
                    onPressed: () async {
                      await Provider.of<AuthService>(context, listen: false).signOut();
                      if (context.mounted) {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      }
                    },
                  ),
                ] else
                  IconButton(
                    icon: const Icon(Icons.person_outline, color: Color(0xFFF4EAD4), size: 32),
                    padding: const EdgeInsets.all(8), 
                    constraints: const BoxConstraints(), 
                    onPressed: () {
                      showGuildAuthDialog(context);
                    },
                  ),
              ],
            ),
          ),
          Container(
            color: const Color(0xFF2B1D14),
            padding: const EdgeInsets.all(8),
            child: _buildControlPanel(context, user),
          ),
          Expanded(
            child: Container(
              color: const Color(0xFF3A2311),
              child: _buildRecipeGrid(dbService, user, isDesktop: false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlPanel(BuildContext context, User? user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            onChanged: (val) => setState(() => _searchQuery = val),
            style: GoogleFonts.vt323(fontSize: 20, color: const Color(0xFFF4EAD4)),
            decoration: InputDecoration(
              hintText: 'Search Scrolls...',
              hintStyle: GoogleFonts.vt323(fontSize: 20, color: const Color(0xFF8B5A2B)),
              filled: true,
              fillColor: const Color(0xFF1A0F08),
              prefixIcon: const Icon(Icons.search, color: Color(0xFFF4EAD4)),
              enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF5C3A21), width: 2)),
              focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFFF4EAD4), width: 2)),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategory == cat;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF8B5A2B) : const Color(0xFF1A0F08),
                      border: Border.all(color: isSelected ? const Color(0xFFF4EAD4) : const Color(0xFF5C3A21), width: 2),
                    ),
                    child: Center(
                      child: Text(
                        cat,
                        style: GoogleFonts.vt323(
                          fontSize: 18,
                          color: isSelected ? const Color(0xFFF4EAD4) : const Color(0xFF8B5A2B),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () {
              if (user == null) {
                showGuildAuthDialog(context);
              } else {
                setState(() => _showPending = !_showPending);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFD4C3A3),
                border: Border.all(color: const Color(0xFF1A0F08), width: 4),
                boxShadow: const [BoxShadow(color: Colors.black54, offset: Offset(4, 4))],
              ),
              child: Column(
                children: [
                  Icon(_showPending ? Icons.door_back_door : Icons.mail, color: const Color(0xFF5C3A21), size: 32),
                  const SizedBox(height: 8),
                  Text(
                    _showPending ? 'RETURN TO TAVERN' : 'TOUCH HERE FOR PENDING RECIPES',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.pixelifySans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1A0F08)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeGrid(DatabaseService dbService, User? user, {required bool isDesktop}) {
    return StreamBuilder<List<Recipe>>(
      stream: dbService.publicRecipes,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'DATABASE ERROR:\n\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: GoogleFonts.vt323(fontSize: 24, color: const Color(0xFFCD5C5C)),
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF2E8B57)));
        }
        
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              'The board is empty...',
              textAlign: TextAlign.center,
              style: GoogleFonts.vt323(fontSize: isDesktop ? 32 : 24, color: const Color(0xFFE2D6B5)),
            ),
          );
        }

        var recipes = snapshot.data!;
        
        recipes = recipes.where((r) => !_hiddenRecipes.contains(r.id)).toList();

        if (user == null) {
          recipes = recipes.where((r) => r.status == 'approved').toList();
        } else {
          recipes = recipes.where((r) => _showPending ? r.status == 'pending' : r.status == 'approved').toList();
        }
        
        if (_selectedCategory != 'All') {
          recipes = recipes.where((r) => r.category == _selectedCategory).toList();
        }
        
        if (_searchQuery.isNotEmpty) {
          recipes = recipes.where((r) => r.title.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
        }

        if (user == null && recipes.length > 4) {
          recipes = recipes.sublist(0, 4);
        }

        if (recipes.isEmpty) {
          return Center(
            child: Text(
              'No scrolls found...',
              textAlign: TextAlign.center,
              style: GoogleFonts.vt323(fontSize: isDesktop ? 32 : 24, color: const Color(0xFFE2D6B5)),
            ),
          );
        }

        return GridView.builder(
          padding: EdgeInsets.all(isDesktop ? 32 : 16),
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: isDesktop ? 280 : 200,
            childAspectRatio: isDesktop ? 0.75 : 0.8,
            crossAxisSpacing: isDesktop ? 24 : 16,
            mainAxisSpacing: isDesktop ? 24 : 16,
          ),
          itemCount: recipes.length,
          itemBuilder: (context, index) {
            return _buildRecipeCard(context, recipes[index], dbService, user);
          },
        );
      },
    );
  }

  Widget _buildRecipeCard(BuildContext context, Recipe recipe, DatabaseService dbService, User? user) {
    final isAuthor = user != null && user.uid == recipe.authorId;

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => RecipeDetailScreen(recipe: recipe)));
      },
      onLongPress: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF2B1D14),
            title: Text(isAuthor ? 'BURN SCROLL?' : 'HIDE SCROLL?', style: GoogleFonts.pixelifySans(color: const Color(0xFFCD5C5C))),
            content: Text(
              isAuthor 
                ? 'Throw this recipe into the Tavern fire forever?' 
                : 'Hide this recipe from your personal view?', 
              style: GoogleFonts.vt323(fontSize: 20, color: const Color(0xFFF4EAD4))
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('CANCEL', style: GoogleFonts.vt323(fontSize: 18, color: const Color(0xFF8B5A2B))),
              ),
              TextButton(
                onPressed: () {
                  if (isAuthor) {
                    dbService.deleteRecipe(recipe.id);
                  } else {
                    _hideRecipeLocal(recipe.id);
                  }
                  Navigator.pop(context);
                },
                child: Text(isAuthor ? 'BURN' : 'HIDE', style: GoogleFonts.vt323(fontSize: 18, color: const Color(0xFFCD5C5C))),
              ),
            ],
          ),
        );
      },
      child: PixelPanel(
        padding: const EdgeInsets.all(8),
        baseColor: const Color(0xFFF4EAD4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5A2B),
                      border: Border.all(color: const Color(0xFF1A0F08), width: 2),
                    ),
                    child: const Center(
                      child: Icon(Icons.local_dining, color: Color(0xFFF4EAD4), size: 36),
                    ),
                  ),
                  if (isAuthor)
                    const Positioned(
                      top: 4,
                      right: 4,
                      child: Icon(Icons.delete_outline, color: Color(0xFF1A0F08), size: 16),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              recipe.title,
              style: GoogleFonts.pixelifySans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1A0F08)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'By ${recipe.authorName}',
              style: GoogleFonts.vt323(fontSize: 16, color: const Color(0xFF5C3A21)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (_showPending && user != null) ...[
              const SizedBox(height: 8),
              PixelButton(
                text: 'ACCEPT',
                color: const Color(0xFF2E8B57),
                onPressed: () {
                  dbService.updateRecipeStatus(recipe.id, 'approved');
                },
              ),
            ]
          ],
        ),
      ),
    );
  }
}