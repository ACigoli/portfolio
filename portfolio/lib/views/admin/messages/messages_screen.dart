import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../../core/constants/app_constants.dart';
import '../shared/components/admin_shell.dart';
import 'components/message_tile.dart';
import 'store/admin_messages_store.dart';

class MessagesAdminScreen extends StatefulWidget {
  const MessagesAdminScreen({super.key});

  @override
  State<MessagesAdminScreen> createState() => _MessagesAdminScreenState();
}

class _MessagesAdminScreenState extends State<MessagesAdminScreen> {
  late final AdminMessagesStore _store;

  @override
  void initState() {
    super.initState();
    _store = AdminMessagesStore();
    _store.load();
  }

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      currentRoute: '/admin/messages',
      child: Observer(
        builder: (_) {
          if (_store.loading.value) {
            return const Padding(
              padding: EdgeInsets.only(top: 120),
              child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
            );
          }
          final unreadCount =
              _store.messages.where((m) => m['read'] == 0 || m['read'] == false).length;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Mensagens', style: Theme.of(context).textTheme.displaySmall),
              const SizedBox(height: 6),
              Text('$unreadCount não lidas', style: const TextStyle(color: AppColors.textMuted, fontSize: 14)),
              const SizedBox(height: 28),
              if (_store.messages.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 60),
                    child: Text('Nenhuma mensagem', style: TextStyle(color: AppColors.textMuted, fontSize: 16)),
                  ),
                )
              else
                ..._store.messages.map((m) => MessageTile(
                      message: m,
                      onMarkRead: () => _store.markRead(m['id'] as int),
                      onDelete: () => _store.delete(m['id'] as int),
                    )),
            ],
          );
        },
      ),
    );
  }
}
