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
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _photoUrlController = TextEditingController();
  bool _photoError = false;
  String? nameError;
  String? usernameError;
  final RegExp _usernameRegex = RegExp(r'^[a-zA-Z_]+$');

  void submitProfile() async {
    setState(() {
      nameError = null;
      usernameError = null;
    });

    if (_nameController.text.isEmpty) {
      setState(() {
        nameError = "Display name cannot be empty";
      });
      return;
    }

    if (_usernameController.text.isEmpty) {
      setState(() {
        usernameError = "Username cannot be empty";
      });
      return;
    }

    if (!_usernameRegex.hasMatch(_usernameController.text)) {
      setState(() {
        usernameError = "Username can only contain letters and underscore";
      });
      return;
    }

    if (_usernameController.text.length < 4 ||
        _usernameController.text.length > 32) {
      setState(() {
        usernameError = "Username must be between 4 and 32 characters";
      });
      return;
    }

    if (nameError == null && usernameError == null && !_photoError) {
      try {
        var data =
            await supabase.from('profiles').upsert({
              'id': supabase.auth.currentUser?.id,
              'name': _nameController.text,
              'username': _usernameController.text,
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
      } catch (e) {
        if (e.toString().contains("profiles_username_key") ||
            e.toString().contains("duplicate key value")) {
          setState(() {
            usernameError =
                "Username already taken. Please choose another one.";
          });
        } else {
          // Handle other errors
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("An error occurred: ${e.toString()}")),
          );
        }
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
            const SizedBox(height: 24),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: "Username",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                errorText: usernameError,
              ),
              onChanged: (value) {
                setState(() {
                  usernameError = null;
                });
                if (value.isEmpty) {
                  setState(() {
                    usernameError = "Username cannot be empty";
                  });
                } else if (!_usernameRegex.hasMatch(value)) {
                  setState(() {
                    usernameError =
                        "Username can only contain letters and underscore";
                  });
                } else if (value.length < 4 || value.length > 32) {
                  setState(() {
                    usernameError =
                        "Username must be between 4 and 32 characters";
                  });
                }
              },
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4.0, left: 12.0),
              child: Text(
                "Username can only contain letters (a-z, A-Z) and underscore (_), and must be between 4-32 characters",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Display name",
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
                    nameError = "Display name cannot be empty";
                  });
                }
              },
            ),
            const SizedBox(height: 16),
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
    _usernameController.dispose();
    _photoUrlController.dispose();
    super.dispose();
  }
}
