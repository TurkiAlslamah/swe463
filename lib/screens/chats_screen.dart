import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/chat_provider.dart';
import '../widgets/empty_state.dart';

/// Frame 09 - list of conversations (F4).
class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatProvider>();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Chats')),
      body: chat.conversations.isEmpty
          ? const EmptyState(
              icon: Icons.chat_bubble_outline, message: 'No chats yet')
          : ListView.builder(
              itemCount: chat.conversations.length,
              itemBuilder: (context, i) {
                final c = chat.conversations[i];
                final name = chat.nameOf(c.userB);
                final last = chat.lastMessage(c.id);
                return ListTile(
                  onTap: () => context.push('/chats/${c.id}'),
                  leading: CircleAvatar(
                    backgroundColor: scheme.primaryContainer,
                    child: Text(name[0]),
                  ),
                  title: Text(name,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(last?.text ?? '',
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: Text(DateFormat('MMM d').format(c.lastMessageAt),
                      style: Theme.of(context).textTheme.bodySmall),
                );
              },
            ),
    );
  }
}
