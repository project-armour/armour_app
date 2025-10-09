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

  void updateAddContactButton() {
    setState(() {
      showAddButton = _tabController.index == 2;
    });
  }

  @override
  void initState() {
    super.initState();
    getProfile();
    getContacts(supabase.auth.currentUser!.id, ContactsQueryType.accepted).then(
      (value) {
        setState(() {
          contacts = value;
        });
      },
    );
    getContacts(
      supabase.auth.currentUser!.id,
      ContactsQueryType.recievedRequests,
    ).then((value) {
      setState(() {
        requests = value;
      });
    });
    getContacts(
      supabase.auth.currentUser!.id,
      ContactsQueryType.sentRequests,
    ).then((value) {
      setState(() {
        sentRequests = value;
      });
    });
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(updateAddContactButton);
  }

  @override
  void dispose() {
    _tabController.removeListener(updateAddContactButton);
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
                onPressed: () async {},
                child: Icon(LucideIcons.userRoundPlus),
              )
              : null,
      body: TabBarView(
        controller: _tabController,
        children: [
          // Contacts Tab
          RefreshIndicator(
            onRefresh: () async {
              await getContacts(
                supabase.auth.currentUser!.id,
                ContactsQueryType.accepted,
              ).then((value) {
                setState(() {
                  contacts = value;
                });
              });
            },
            child: ListView(
              children: [
                for (int i = 0; i < contacts.length; i++)
                  ContactListItem(
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
              await getContacts(
                supabase.auth.currentUser!.id,
                ContactsQueryType.recievedRequests,
              ).then((value) {
                setState(() {
                  requests = value;
                });
              });
            },
            child: ListView(
              children: [
                if (myProfile.isNotEmpty)
                  ListTile(title: Text('Your Profile'), dense: true),
                if (myProfile.isNotEmpty &&
                    myProfile['name'] != null &&
                    myProfile['username'] != null)
                  ContactListItem(
                    name: myProfile['name'],
                    username: myProfile['username'],
                    isUser: true,
                  ),
                ListTile(title: Text('Received Requests')),
                for (int i = 0; i < requests.length; i++)
                  ContactListItem(
                    name: requests[i]['name'],
                    username: requests[i]['username'],
                    profilePhotoUrl: requests[i]['profile_photo_url'],
                    isSharing: requests[i]['is_sharing'],
                  ),
              ],
            ),
          ),
          // Add Contact Tab
          RefreshIndicator(
            onRefresh: () async {
              await getContacts(
                supabase.auth.currentUser!.id,
                ContactsQueryType.sentRequests,
              ).then((value) {
                setState(() {
                  sentRequests = value;
                });
              });
            },
            child: ListView(
              children: [
                ListTile(title: Text('Sent Requests')),
                for (int i = 0; i < sentRequests.length; i++)
                  ContactListItem(
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
  final String name;
  final String username;
  final String? profilePhotoUrl;
  final bool? isSharing;
  final bool isUser;

  const ContactListItem({
    super.key,
    required this.name,
    required this.username,
    this.isSharing,
    this.profilePhotoUrl,
    this.isUser = false,
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
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
