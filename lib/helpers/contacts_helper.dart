import 'package:armour_app/main.dart';

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
    Set<String> reveiverUserIds = {};

    for (var contact in contactsList) {
      if (contact['receiver'] == userId) {
        senderUserIds.add(contact['sender']);
      } else {
        reveiverUserIds.add(contact['receiver']);
      }
    }

    if (reveiverUserIds.isNotEmpty) {
      final profilesResponse = await supabase
          .from("profiles")
          .select()
          .inFilter('id', reveiverUserIds.toList());
      // add a isSharing parameter and change to false
      for (var profile in profilesResponse) {
        profile['isSharing'] = null;
      }
      contacts.addAll(profilesResponse);
    }

    if (senderUserIds.isNotEmpty) {
      final profilesResponse = await supabase
          .from("location_sharing_with_profiles")
          .select(
            'id:sender, name:sender_name, username:sender_username, profile_photo_url, is_sharing',
          )
          .inFilter('sender', senderUserIds.toList());
      contacts.addAll(profilesResponse);
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
