import 'dart:math';

import 'package:armour_app/helpers/contacts_helper.dart';
import 'package:armour_app/main.dart';
import 'package:armour_app/pages/contacts.dart';
import 'package:flutter/material.dart';

class ContactsButton extends StatefulWidget {
  const ContactsButton({super.key});

  @override
  State<ContactsButton> createState() => _ContactsButtonState();
}

class _ContactsButtonState extends State<ContactsButton> {
  List<Map<String, dynamic>> contacts = [];

  @override
  void initState() {
    getContacts(supabase.auth.currentUser!.id, ContactsQueryType.accepted).then(
      (value) {
        setState(() {
          contacts = value;
        });
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(0),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          await Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => ContactsPage()));
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            spacing: 12,
            children: [
              Stack(
                children: [
                  for (int i = min(contacts.length, 3) - 1; i >= 0; i--)
                    ContactItem(
                      name: contacts[i]['name'],
                      isSharing: contacts[i]['is_sharing'],
                      index: i,
                      imageUrl: contacts[i]['profile_photo_url'],
                    ),
                ],
              ),
              Text(
                "My Contacts",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ContactItem extends StatelessWidget {
  const ContactItem({
    super.key,
    required this.name,
    this.isSharing,
    required this.index,
    this.imageUrl,
  });

  final String name;
  final bool? isSharing;
  final int index;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 16.0 * index),
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color:
              isSharing == true
                  ? Colors.lightBlueAccent
                  : isSharing == false
                  ? Colors.grey
                  : Theme.of(context).colorScheme.surfaceBright,
          width: 2,
        ),
        color: Theme.of(context).colorScheme.surfaceBright,
      ),
      child: CircleAvatar(
        radius: 18,
        backgroundImage:
            imageUrl != null && imageUrl!.isNotEmpty
                ? NetworkImage(imageUrl!)
                : null,
        backgroundColor: Theme.of(context).colorScheme.surfaceBright,
        child:
            imageUrl == null || imageUrl!.isEmpty
                ? Icon(Icons.person, size: 20, color: Colors.grey)
                : null,
      ),
    );
  }
}
