import 'package:armour_app/helpers/contacts_helper.dart';
import 'package:armour_app/main.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<Map<String, dynamic>> contacts = [];
  List<Map<String, dynamic>> requests = [];
  List<Map<String, dynamic>> sentRequests = [];
  Map<String, dynamic> myProfile = {};

  bool showAddButton = false;

  void getProfile() async {
    final profile =
        await supabase
            .from('profiles')
            .select()
            .eq('id', supabase.auth.currentUser?.id as String)
            .single();
    setState(() {
      myProfile = profile;
    });
  }

  void tabChange() {
    refreshContacts(ContactsQueryType.values[_tabController.index]);
    setState(() {
      showAddButton = _tabController.index == 2;
    });
  }

  Future<void> refreshContacts(ContactsQueryType type) async {
    final value = await getContacts(supabase.auth.currentUser!.id, type);
    setState(() {
      if (type == ContactsQueryType.accepted) {
        contacts = value;
      } else if (type == ContactsQueryType.recievedRequests) {
        requests = value;
      } else if (type == ContactsQueryType.sentRequests) {
        sentRequests = value;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getProfile();
    refreshContacts(ContactsQueryType.accepted);
    refreshContacts(ContactsQueryType.recievedRequests);
    refreshContacts(ContactsQueryType.sentRequests);
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(tabChange);
  }

  @override
  void dispose() {
    _tabController.removeListener(tabChange);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Contacts', icon: Icon(LucideIcons.users)),
            Tab(text: 'Requests', icon: Icon(LucideIcons.inbox)),
            Tab(text: 'Add', icon: Icon(LucideIcons.userRoundPlus)),
          ],
        ),
      ),
      floatingActionButton:
          showAddButton
              ? FloatingActionButton(
                onPressed: () async {
                  await showDialog(
                    context: context,
                    builder: (context) => const AddContactDialog(),
                  ).then((result) {
                    if (result) {
                      refreshContacts(ContactsQueryType.sentRequests);
                    }
                  });
                },
                child: Icon(LucideIcons.userRoundPlus),
              )
              : null,
      body: TabBarView(
        controller: _tabController,
        children: [
          // Contacts Tab
          RefreshIndicator(
            onRefresh: () async {
              await refreshContacts(ContactsQueryType.accepted);
            },
            child: ListView(
              children: [
                for (int i = 0; i < contacts.length; i++)
                  ContactListItem(
                    id: contacts[i]['id'],
                    name: contacts[i]['name'],
                    username: contacts[i]['username'],
                    profilePhotoUrl: contacts[i]['profile_photo_url'],
                    isSharing: contacts[i]['is_sharing'],
                  ),
              ],
            ),
          ),
          // Requests Tab
          RefreshIndicator(
            onRefresh: () async {
              await refreshContacts(ContactsQueryType.recievedRequests);
            },
            child: ListView(
              children: [
                if (myProfile.isNotEmpty)
                  ListTile(title: Text('Your Profile'), dense: true),
                if (myProfile.isNotEmpty &&
                    myProfile['name'] != null &&
                    myProfile['username'] != null)
                  ContactListItem(
                    id: myProfile['id'],
                    name: myProfile['name'],
                    username: myProfile['username'],
                    isUser: true,
                  ),
                ListTile(title: Text('Received Requests')),
                for (int i = 0; i < requests.length; i++)
                  ContactListItem(
                    id: requests[i]['id'],
                    name: requests[i]['name'],
                    username: requests[i]['username'],
                    profilePhotoUrl: requests[i]['profile_photo_url'],
                    isSharing: requests[i]['is_sharing'],
                    contactRequest: true,
                    refreshFunction: () {
                      print("REFRESH");
                      refreshContacts(ContactsQueryType.recievedRequests);
                    },
                  ),
              ],
            ),
          ),
          // Add Contact Tab
          RefreshIndicator(
            onRefresh: () async {
              await refreshContacts(ContactsQueryType.sentRequests);
            },
            child: ListView(
              children: [
                ListTile(title: Text('Sent Requests')),
                for (int i = 0; i < sentRequests.length; i++)
                  ContactListItem(
                    id: sentRequests[i]['id'],
                    name: sentRequests[i]['name'],
                    username: sentRequests[i]['username'],
                    profilePhotoUrl: sentRequests[i]['profile_photo_url'],
                    isSharing: sentRequests[i]['is_sharing'],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ContactListItem extends StatelessWidget {
  final String id;
  final String name;
  final String username;
  final String? profilePhotoUrl;
  final bool? isSharing;
  final bool isUser;
  final bool contactRequest;
  final VoidCallback? refreshFunction;

  const ContactListItem({
    super.key,
    required this.id,
    required this.name,
    required this.username,
    this.isSharing,
    this.profilePhotoUrl,
    this.isUser = false,
    this.contactRequest = false,
    this.refreshFunction,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        radius: 24,
        backgroundImage:
            profilePhotoUrl != null && profilePhotoUrl!.isNotEmpty
                ? NetworkImage(profilePhotoUrl!)
                : null,
        backgroundColor: Theme.of(context).colorScheme.surfaceBright,
        child:
            profilePhotoUrl == null || profilePhotoUrl!.isEmpty
                ? Icon(Icons.person, size: 20, color: Colors.grey)
                : null,
      ),
      title: Text(name),
      subtitle: Text(username),
      trailing:
          isUser
              ? IconButton(
                onPressed: () {
                  SharePlus.instance.share(
                    ShareParams(
                      title: 'Add my contact on ARMOUR',
                      text:
                          'Add my contact on ARMOUR, The personal safety app for the modern age.\nName: $name\nUsername: $username',
                    ),
                  );
                },
                icon: Icon(
                  LucideIcons.share2,
                  color: ColorScheme.of(context).primary,
                ),
              )
              : contactRequest
              ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton.filled(
                    onPressed: () async {
                      await rejectContact(context, id);
                      print(id);
                      if (refreshFunction != null) {
                        refreshFunction!();
                      }
                    },
                    icon: Icon(
                      LucideIcons.x,
                      color: ColorScheme.of(context).error,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: ColorScheme.of(
                        context,
                      ).errorContainer.withValues(alpha: 0.5),
                    ),
                  ),
                  IconButton.filled(
                    onPressed: () async {
                      acceptContact(context, id);
                      if (refreshFunction != null) {
                        refreshFunction!();
                      }
                    },
                    icon: Icon(LucideIcons.check, color: Colors.greenAccent),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.greenAccent.withValues(
                        alpha: 0.25,
                      ),
                    ),
                  ),
                ],
              )
              : Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color:
                      isSharing == true
                          ? Colors.greenAccent.withValues(alpha: 0.25)
                          : isSharing == false
                          ? Colors.grey.withValues(alpha: 0.25)
                          : ColorScheme.of(
                            context,
                          ).primary.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isSharing == true
                      ? "Sharing Location"
                      : isSharing == false
                      ? "Not Sharing Location"
                      : "Receiver",
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        isSharing == true
                            ? Colors.greenAccent
                            : isSharing == false
                            ? Colors.grey
                            : ColorScheme.of(context).primary,
                  ),
                ),
              ),
    );
  }
}

class AddContactDialog extends StatefulWidget {
  const AddContactDialog({super.key});

  @override
  State<AddContactDialog> createState() => _AddContactDialogState();
}

class _AddContactDialogState extends State<AddContactDialog> {
  String? usernameError;
  final RegExp _usernameRegex = RegExp(r'^[a-zA-Z_]+$');
  TextEditingController usernameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          spacing: 12,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Add Contact", style: TextTheme.of(context).titleLarge),
            Text(
              "Enter the username of the person you want to add as a contact below.",
              style: TextTheme.of(context).bodyMedium,
              textAlign: TextAlign.justify,
            ),
            TextField(
              controller: usernameController,
              onChanged: (value) {
                setState(() {
                  usernameError = null;
                });
                if (value.isEmpty) {
                  setState(() {
                    usernameError = "Cannot be empty";
                  });
                } else if (!_usernameRegex.hasMatch(value)) {
                  setState(() {
                    usernameError = "Can only contain letters and underscore";
                  });
                } else if (value.length < 4 || value.length > 32) {
                  setState(() {
                    usernameError = "Must be between 4 and 32 characters";
                  });
                }
              },
              decoration: InputDecoration(
                labelText: "Username",
                errorText: usernameError,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text("Cancel"),
                ),
                TextButton(
                  onPressed: () async {
                    if (usernameController.text.isEmpty) {
                      setState(() {
                        usernameError = "Cannot be empty";
                      });
                    }
                    if (usernameError == null) {
                      final result = await addContact(
                        context,
                        usernameController.text,
                      );
                      if (result != "success") {
                        setState(() {
                          usernameError = result;
                        });
                      }
                      if (context.mounted && result == "success") {
                        Navigator.of(context).pop(result == "success");
                      }
                    }
                  },
                  child: Text("Add"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
