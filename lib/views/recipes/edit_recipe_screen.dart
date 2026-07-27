import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/recipe_model.dart';
import '../../widgets/pixel_panel.dart';

class EditRecipeScreen extends StatefulWidget {
  final Recipe recipe;

  const EditRecipeScreen({super.key, required this.recipe});

  @override
  State<EditRecipeScreen> createState() => _EditRecipeScreenState();
}

class _EditRecipeScreenState extends State<EditRecipeScreen> {
  late TextEditingController titleController;
  late List<TextEditingController> ingredientControllers;
  late List<TextEditingController> instructionControllers;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.recipe.title);
    ingredientControllers = widget.recipe.ingredients
        .map((e) => TextEditingController(text: e))
        .toList();
    instructionControllers = widget.recipe.instructions
        .map((e) => TextEditingController(text: e))
        .toList();
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  void addIngredient() => setState(() => ingredientControllers.add(TextEditingController()));
  
  void removeIngredient(int index) => setState(() {
    ingredientControllers.removeAt(index);
  });

  void addInstruction() => setState(() => instructionControllers.add(TextEditingController()));
  
  void removeInstruction(int index) => setState(() {
    instructionControllers.removeAt(index);
  });

  Future<void> saveChanges() async {
    setState(() => isSaving = true);
    final updatedIngredients = ingredientControllers.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList();
    final updatedInstructions = instructionControllers.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList();

    try {
      await FirebaseFirestore.instance.collection('recipes').doc(widget.recipe.id).update({
        'title': titleController.text.trim(),
        'ingredients': updatedIngredients,
        'instructions': updatedInstructions,
      });
      if (mounted) {
        Navigator.pop(context); 
        Navigator.pop(context); 
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        setState(() => isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4EAD4),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: PixelPanel(
                baseColor: const Color(0xFF1A0F08),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Color(0xFFF4EAD4)),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'EDIT TOME',
                      style: GoogleFonts.pixelifySans(fontSize: 24, color: const Color(0xFFF4EAD4)),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                children: [
                  PixelPanel(
                    baseColor: const Color(0xFFFFFFFF),
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: titleController,
                      style: GoogleFonts.vt323(fontSize: 28, color: const Color(0xFF1A0F08)),
                      decoration: InputDecoration(
                        labelText: 'Tome Title',
                        labelStyle: GoogleFonts.pixelifySans(color: const Color(0xFF8B5A2B)),
                        border: const OutlineInputBorder(),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF8B5A2B), width: 2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  PixelPanel(
                    baseColor: const Color(0xFFFFFFFF),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Reagents', style: GoogleFonts.pixelifySans(fontSize: 22, color: const Color(0xFF1A0F08))),
                        const SizedBox(height: 12),
                        ...ingredientControllers.asMap().entries.map((entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: entry.value,
                                  style: GoogleFonts.vt323(fontSize: 22),
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => removeIngredient(entry.key),
                              ),
                            ],
                          ),
                        )),
                        ElevatedButton.icon(
                          onPressed: addIngredient,
                          icon: const Icon(Icons.add),
                          label: Text('Add Reagent', style: GoogleFonts.pixelifySans()),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8B5A2B),
                            foregroundColor: const Color(0xFFF4EAD4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  PixelPanel(
                    baseColor: const Color(0xFFFFFFFF),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ritual Steps', style: GoogleFonts.pixelifySans(fontSize: 22, color: const Color(0xFF1A0F08))),
                        const SizedBox(height: 12),
                        ...instructionControllers.asMap().entries.map((entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: entry.value,
                                  style: GoogleFonts.vt323(fontSize: 22),
                                  maxLines: null,
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => removeInstruction(entry.key),
                              ),
                            ],
                          ),
                        )),
                        ElevatedButton.icon(
                          onPressed: addInstruction,
                          icon: const Icon(Icons.add),
                          label: Text('Add Step', style: GoogleFonts.pixelifySans()),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8B5A2B),
                            foregroundColor: const Color(0xFFF4EAD4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  isSaving
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF8B5A2B)))
                      : ElevatedButton(
                          onPressed: saveChanges,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A0F08),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(
                            'SEAL THE TOME (SAVE)',
                            style: GoogleFonts.pixelifySans(fontSize: 24, color: const Color(0xFFDAA520)),
                          ),
                        ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}