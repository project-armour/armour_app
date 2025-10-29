import 'package:armour_app/main.dart';
import 'package:armour_app/pages/contacts.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<Map<String, dynamic>> notifications = [];

  Future<void> getNotifications() async {
    final notifs = await supabase.from('notifications_with_profiles').select();
    setState(() {
      notifications = notifs;
    });
  }

  void clearNotifications() async {
    await supabase
        .from('notifications')
        .delete()
        .or('receiver.is.null,receiver.eq.${supabase.auth.currentUser?.id}');
    getNotifications();
  }

  @override
  void initState() {
    getNotifications();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: FilledButton.icon(
              icon: const Icon(LucideIcons.trash2),
              onPressed: () async {
                await showDialog(
                  context: context,
                  builder: (context) => DeletionConfirmDialog(allNotifs: true),
                ).then((value) {
                  if (value == true) {
                    clearNotifications();
                  }
                });
              },
              style: FilledButton.styleFrom(
                backgroundColor: ColorScheme.of(
                  context,
                ).errorContainer.withValues(alpha: 0.25),
                foregroundColor: ColorScheme.of(context).onErrorContainer,
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              label: const Text('Clear All'),
              iconAlignment: IconAlignment.end,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: getNotifications,
        child: ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notif = notifications[index];
            return Dismissible(
              key: Key(notif['id'].toString()),
              direction: DismissDirection.endToStart,
              background: Container(
                color: Colors.redAccent.withValues(alpha: 0.25),
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Icon(LucideIcons.trash, color: Colors.redAccent),
              ),
              confirmDismiss: (direction) async {
                return await showDialog(
                  context: context,
                  builder: (context) => DeletionConfirmDialog(),
                );
              },
              onDismissed: (direction) async {
                await supabase
                    .from('notifications')
                    .delete()
                    .eq('id', notif['id']);
                setState(() {
                  notifications.removeAt(index);
                });
              },
              child: ListTile(
                title: Text(
                  notificationTitleMap[notif['type']] ?? 'Notification',
                ),
                leading: Icon(
                  notificationIconMap[notif['type']] ?? LucideIcons.bell,
                ),
                onTap: () {
                  if (notif['type'] == 'contact_request') {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => ContactsPage()),
                    );
                  }
                },
                subtitle:
                    notif['message'] != null ? Text(notif['message']) : null,
                trailing: Text(
                  DateFormat(
                    'd/M/yy\nHH:mm',
                  ).format(DateTime.parse(notif['created_at']).toLocal()),
                  textAlign: TextAlign.end,
                  style: TextTheme.of(context).labelSmall,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class DeletionConfirmDialog extends StatelessWidget {
  const DeletionConfirmDialog({super.key, this.allNotifs = false});
  final bool allNotifs;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: ColorScheme.of(context).surfaceContainerLow,
      title: Text(
        allNotifs ? 'Delete All Notifications' : 'Delete Notification',
      ),
      content: Text(
        allNotifs
            ? 'Are you sure you want to delete all your notifications? This action cannot be undone.'
            : 'Are you sure you want to delete this notification? This action cannot be undone.',
      ),
      actions: [
        FilledButton.tonal(
          onPressed: () => Navigator.of(context).pop(false),
          style: FilledButton.styleFrom(
            backgroundColor: ColorScheme.of(
              context,
            ).primaryContainer.withValues(alpha: 0.25),
            foregroundColor: ColorScheme.of(context).onPrimaryContainer,
          ),
          child: const Text('Cancel'),
        ),
        FilledButton.tonal(
          onPressed: () => Navigator.of(context).pop(true),

          style: FilledButton.styleFrom(
            backgroundColor: ColorScheme.of(
              context,
            ).errorContainer.withValues(alpha: 0.25),
            foregroundColor: ColorScheme.of(context).onErrorContainer,
          ),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
