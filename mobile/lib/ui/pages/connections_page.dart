import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:photo_gallery/providers/s3_connection_provider.dart';
import 'package:photo_gallery/routes/root.dart';

class ConnectionsPage extends HookConsumerWidget {
  const ConnectionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionsAsync = ref.watch(s3ConnectionsProvider);
    final selectedId = ref.watch(selectedConnectionIdProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('S3 Connections')),
      body: connectionsAsync.when(
        data: (connections) {
          if (connections.isEmpty) {
            return const Center(
              child: Text('No connections configured.\nTap + to add one.', textAlign: TextAlign.center),
            );
          }
          return ListView.builder(
            itemCount: connections.length,
            itemBuilder: (context, index) {
              final conn = connections[index];
              return ListTile(
                leading: Icon(
                  conn.isSafeStorage ? Icons.lock : Icons.cloud,
                ),
                title: Text(conn.name),
                subtitle: Text('${conn.endpoint} / ${conn.bucketName}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (conn.isDefault)
                      const Chip(label: Text('Default')),
                    if (conn.id == selectedId)
                      const Icon(Icons.check_circle, color: Colors.green),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Delete connection?'),
                            content: Text('Remove "${conn.name}"?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                              TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          ref.read(s3ConnectionsProvider.notifier).removeConnection(conn.id);
                        }
                      },
                    ),
                  ],
                ),
                onTap: () => ref.read(selectedConnectionIdProvider.notifier).select(conn.id),
                onLongPress: () => EditConnectionRoute(connectionId: conn.id).push(context),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => const EditConnectionRoute(connectionId: 'new').push(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
