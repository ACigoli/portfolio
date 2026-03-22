import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../stores/admin_messages_store.dart';
import 'admin_layout.dart';

class MessagesView extends StatefulWidget {
  const MessagesView({super.key});
  @override
  State<MessagesView> createState() => _MessagesViewState();
}

class _MessagesViewState extends State<MessagesView> {
  late final AdminMessagesStore _store;

  @override
  void initState() {
    super.initState();
    _store = AdminMessagesStore();
    _store.load();
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentRoute: '/admin/messages',
      child: Observer(
        builder: (_) {
          if (_store.loading.value) {
            return const Center(
                child:
                    CircularProgressIndicator(color: Color(0xFF915EFF)));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Mensagens',
                    style: TextStyle(
                        color: Color(0xFFF3F4F6),
                        fontSize: 28,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(
                    '${_store.messages.where((m) => m['read'] == 0 || m['read'] == false).length} não lidas',
                    style: const TextStyle(
                        color: Color(0xFF8892A4), fontSize: 14)),
                const SizedBox(height: 28),
                if (_store.messages.isEmpty)
                  const Center(
                      child: Padding(
                    padding: EdgeInsets.only(top: 60),
                    child: Text('Nenhuma mensagem',
                        style: TextStyle(
                            color: Color(0xFF8892A4), fontSize: 16)),
                  ))
                else
                  ..._store.messages.map((m) {
                    final unread =
                        m['read'] == 0 || m['read'] == false;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: unread
                            ? const Color(0xFF915EFF)
                                .withValues(alpha: 0.05)
                            : const Color(0xFF0D1224),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: unread
                              ? const Color(0xFF915EFF)
                                  .withValues(alpha: 0.3)
                              : const Color(0xFF1E2D4A),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if (unread)
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                      color: Color(0xFF915EFF),
                                      shape: BoxShape.circle),
                                  margin:
                                      const EdgeInsets.only(right: 8),
                                ),
                              Text(m['name'] ?? '',
                                  style: const TextStyle(
                                      color: Color(0xFFF3F4F6),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600)),
                              const Spacer(),
                              Text(
                                  m['created_at']?.substring(0, 10) ??
                                      '',
                                  style: const TextStyle(
                                      color: Color(0xFF8892A4),
                                      fontSize: 12)),
                              const SizedBox(width: 12),
                              if (unread)
                                _IconBtn(
                                    icon: Icons.mark_email_read_rounded,
                                    color: const Color(0xFF00D4AA),
                                    onTap: () =>
                                        _store.markRead(m['id'] as int)),
                              const SizedBox(width: 4),
                              _IconBtn(
                                  icon: Icons.delete_rounded,
                                  color: const Color(0xFFFF6B6B),
                                  onTap: () =>
                                      _store.delete(m['id'] as int)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(m['email'] ?? '',
                              style: const TextStyle(
                                  color: Color(0xFF8892A4), fontSize: 12)),
                          const SizedBox(height: 12),
                          Text(m['message'] ?? '',
                              style: const TextStyle(
                                  color: Color(0xFF8892A4),
                                  fontSize: 14,
                                  height: 1.6)),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _IconBtn(
      {required this.icon, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 16),
      ),
    );
  }
}
