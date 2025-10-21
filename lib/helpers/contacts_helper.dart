import 'package:armour_app/main.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum ContactsQueryType { accepted, recievedRequests, sentRequests }

Future<List<Map<String, dynamic>>> getContacts(
  String userId,
  ContactsQueryType type,
) async {
  var contacts = <Map<String, dynamic>>[];

  Future<List<Map<String, dynamic>>> handleContacts(value) async {
    List<Map<String, dynamic>> contactsList = List<Map<String, dynamic>>.from(
      value,
    );

    Set<String> senderUserIds = {};
    Set<String> receiverUserIds = {};

    for (var contact in contactsList) {
      if (contact['receiver'] == userId) {
        senderUserIds.add(contact['sender']);
      } else {
        receiverUserIds.add(contact['receiver']);
      }
    }

    if (receiverUserIds.isNotEmpty) {
      final profilesResponse = await supabase
          .from("profiles")
          .select()
          .inFilter('id', receiverUserIds.toList());
      // add a isSharing parameter and change to false
      for (var profile in profilesResponse) {
        profile['isSharing'] = null;
      }
      contacts.addAll(profilesResponse);
    }

    if (senderUserIds.isNotEmpty) {
      var profilesResponse = await supabase
          .from("location_sharing_with_profiles")
          .select(
            'id:sender, name:sender_name, username:sender_username, profile_photo_url, is_sharing',
          )
          .inFilter('sender', senderUserIds.toList());
      if (profilesResponse.isNotEmpty) {
        contacts.addAll(profilesResponse);
      } else {
        profilesResponse = await supabase
            .from("profiles")
            .select()
            .inFilter('id', senderUserIds.toList());
        for (var profile in profilesResponse) {
          profile['isSharing'] = false;
        }
        contacts.addAll(profilesResponse);
      }
    }

    return contacts;
  }

  if (type == ContactsQueryType.accepted) {
    await supabase
        .from("contacts")
        .select()
        .or('sender.eq.$userId,receiver.eq.$userId')
        .filter('accepted', 'eq', true)
        .then(handleContacts);
  } else if (type == ContactsQueryType.recievedRequests) {
    await supabase
        .from("contacts")
        .select()
        .filter('receiver', 'eq', userId)
        .filter('accepted', 'eq', false)
        .then(handleContacts);
  } else if (type == ContactsQueryType.sentRequests) {
    await supabase
        .from("contacts")
        .select()
        .filter('sender', 'eq', userId)
        .filter('accepted', 'eq', false)
        .then(handleContacts);
  }

  return Future.value(contacts);
}

Future<String> addContact(BuildContext context, String username) async {
  try {
    final recieverUuid = await supabase
        .from("profiles")
        .select("id")
        .eq("username", username)
        .single()
        .then((value) => value["id"]);

    await supabase.from("contacts").insert({
      "sender": supabase.auth.currentUser?.id,
      "receiver": recieverUuid,
      "accepted": false,
    });
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Contact request sent to $username")),
      );
    }
  } on PostgrestException catch (e) {
    if (e.code == "PGRST116") {
      return "User not found";
    } else if (e.code == "23505") {
      return "Contact exists or request already sent";
    }
    return "Unknown error";
  }
  return "success";
}

Future<void> acceptContact(BuildContext context, String senderId) async {
  await supabase
      .from("contacts")
      .update({"accepted": true})
      .eq("sender", senderId);
  if (context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Contact request accepted")));
  }
}

Future<void> rejectContact(BuildContext context, String senderId) async {
  await supabase.from("contacts").delete().eq("sender", senderId);
  if (context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Contact request rejected")));
  }
}
