import 'package:armour_app/helpers/contacts_helper.dart';
import 'package:armour_app/main.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ContactsView extends StatefulWidget {
  const ContactsView({super.key});

  @override
  State<ContactsView> createState() => _ContactsViewState();
}

class _ContactsViewState extends State<ContactsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<Map<String, dynamic>> contacts = [];

  @override
  void initState() {
    super.initState();
    getContacts(supabase.auth.currentUser!.id).then((value) {
      setState(() {
        contacts = value;
      });
    });
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
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
      body: TabBarView(
        controller: _tabController,
        children: [
          // Contacts Tab
          RefreshIndicator(
            onRefresh: () async {
              await getContacts(supabase.auth.currentUser!.id).then((value) {
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
          // Add Contact Tab
          Center(child: Text('Add Contact Page')),
          // Requests Tab
          Center(child: Text('Requests Page')),
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

  const ContactListItem({
    super.key,
    required this.name,
    required this.username,
    this.isSharing,
    this.profilePhotoUrl,
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
      trailing: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color:
              isSharing == true
                  ? Colors.greenAccent.withValues(alpha: 0.25)
                  : isSharing == false
                  ? Colors.grey.withValues(alpha: 0.25)
                  : ColorScheme.of(context).primary.withValues(alpha: 0.25),
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
