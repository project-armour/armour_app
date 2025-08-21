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

  @override
  void initState() {
    super.initState();
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
          ListView(
            padding: const EdgeInsets.all(16),
            children: const [
              SampleContactWidget(
                name: 'Jane Doe',
                email: 'jane.doe@email.com',
                profilePhotoUrl: 'https://i.pravatar.cc/150?img=3',
              ),
              SampleContactWidget(
                name: 'John Smith',
                email: 'john.smith@email.com',
                profilePhotoUrl: 'https://i.pravatar.cc/150?img=5',
              ),
            ],
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

class SampleContactWidget extends StatelessWidget {
  final String name;
  final String email;
  final String profilePhotoUrl;

  const SampleContactWidget({
    super.key,
    required this.name,
    required this.email,
    required this.profilePhotoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(backgroundImage: NetworkImage(profilePhotoUrl)),
      title: Text(name),
      subtitle: Text(email),
    );
  }
}
