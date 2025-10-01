import 'package:armour_app/main.dart';

Future<List<Map<String, dynamic>>> getContacts(String userId) async {
  var contacts = <Map<String, dynamic>>[];

  await supabase
      .from("contacts")
      .select()
      .or('sender.eq.$userId,receiver.eq.$userId')
      .then((value) async {
        List<Map<String, dynamic>> contactsList =
            List<Map<String, dynamic>>.from(value);

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
                'id:sender, name:sender_name, profile_photo_url, is_sharing',
              )
              .inFilter('sender', senderUserIds.toList());
          contacts.addAll(profilesResponse);
        }

        return contacts;
      });

  return Future.value(contacts);
}
