import 'package:armour_app/main.dart';
import 'package:armour_app/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class CreateProfilePage extends StatefulWidget {
  const CreateProfilePage({super.key});

  @override
  State<CreateProfilePage> createState() => _CreateProfilePageState();
}

class _CreateProfilePageState extends State<CreateProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _photoUrlController = TextEditingController();
  bool _photoError = false;
  String? nameError;

  void submitProfile() async {
    nameError = null;
    if (_nameController.text.isEmpty) {
      nameError = "Name cannot be empty";
      return;
    }
    if (nameError == null && !_photoError) {
      var data =
          await supabase.from('profiles').upsert({
            'id': supabase.auth.currentUser?.id,
            'name': _nameController.text,
            'profile_photo_url':
                _photoUrlController.text.isEmpty
                    ? null
                    : _photoUrlController.text,
          }).select();
      if (data.isNotEmpty && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Profile")),
      bottomNavigationBar: BottomAppBar(
        color: ColorScheme.of(context).surfaceContainerLow,
        child: Align(
          alignment: Alignment.bottomRight,
          child: FilledButton.icon(
            onPressed: () {
              submitProfile();
            },
            style: ButtonStyle(
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            label: Text("Continue"),
            icon: Icon(LucideIcons.arrowRight300, size: 24),
            iconAlignment: IconAlignment.end,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: Text(
                "Create your ARMOUR Profile below. A profile photo makes you easier to identify on the map.",
              ),
            ),
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            _photoError && _photoUrlController.text.isNotEmpty
                                ? ColorScheme.of(context).error
                                : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 80,
                      backgroundImage:
                          _photoUrlController.text.isNotEmpty
                              ? NetworkImage(_photoUrlController.text)
                              : null,
                      backgroundColor: ColorScheme.of(context).surfaceContainer,
                      onBackgroundImageError:
                          _photoUrlController.text.isNotEmpty
                              ? (_, __) {
                                setState(() {
                                  _photoError = true;
                                });
                              }
                              : null,
                      child:
                          _photoUrlController.text.isEmpty || _photoError
                              ? Icon(Icons.person, size: 64, color: Colors.grey)
                              : null,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                errorText: nameError,
              ),
              onChanged: (value) {
                setState(() {
                  nameError = null;
                });
                if (value.isEmpty) {
                  setState(() {
                    nameError = "Name cannot be empty";
                  });
                }
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _photoUrlController,
              decoration: InputDecoration(
                labelText: "Profile Photo URL",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                errorText:
                    _photoUrlController.text.isNotEmpty && _photoError
                        ? "Invalid URL"
                        : null,
              ),
              keyboardType: TextInputType.url,
              onChanged: (value) {
                setState(() {
                  _photoError = false;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _photoUrlController.dispose();
    super.dispose();
  }
}
