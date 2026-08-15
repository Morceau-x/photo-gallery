import 'package:photo_gallery/io/repository/connection_config_store.dart';
import 'package:photo_gallery/models/s3_connection_config.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 's3_connection_provider.g.dart';

@Riverpod(keepAlive: true)
class S3Connections extends _$S3Connections {
  final _configStore = ConnectionConfigStore();
  final _credentialStore = SecureCredentialStore();

  @override
  Future<List<S3ConnectionConfig>> build() async {
    final configs = await _configStore.loadAll();
    final hydrated = <S3ConnectionConfig>[];
    for (final config in configs) {
      final creds = await _credentialStore.readCredentials(config.id);
      hydrated.add(
        config.copyWith(accessKey: creds.accessKey, secretKey: creds.secretKey),
      );
    }
    return hydrated;
  }

  Future<void> addConnection(S3ConnectionConfig config) async {
    final id = config.id.isEmpty ? const Uuid().v4() : config.id;
    final withId = config.copyWith(id: id);

    var current = state.value ?? [];
    if (withId.isDefault) {
      current = current.map((c) => c.copyWith(isDefault: false)).toList();
    }

    await _credentialStore.saveCredentials(
      connectionId: id,
      accessKey: withId.accessKey,
      secretKey: withId.secretKey,
    );
    final updated = [...current, withId];
    await _configStore.saveAll(updated);
    state = AsyncData(updated);
  }

  Future<void> updateConnection(S3ConnectionConfig config) async {
    var current = state.value ?? [];
    if (config.isDefault) {
      current = current.map((c) => c.copyWith(isDefault: false)).toList();
    }
    final updated = current.map((c) => c.id == config.id ? config : c).toList();
    await _credentialStore.saveCredentials(
      connectionId: config.id,
      accessKey: config.accessKey,
      secretKey: config.secretKey,
    );
    await _configStore.saveAll(updated);
    state = AsyncData(updated);
  }

  Future<void> removeConnection(String id) async {
    final current = state.value ?? [];
    final updated = current.where((c) => c.id != id).toList();
    await _credentialStore.deleteCredentials(id);
    await _configStore.saveAll(updated);
    state = AsyncData(updated);
  }
}

@Riverpod(keepAlive: true)
class SelectedConnectionId extends _$SelectedConnectionId {
  @override
  String? build() {
    final connections = ref.watch(s3ConnectionsProvider).value ?? [];
    if (connections.isEmpty) return null;
    final defaultConn = connections.where((c) => c.isDefault).firstOrNull;
    return defaultConn?.id ?? connections.first.id;
  }

  void select(String id) {
    state = id;
  }
}

@riverpod
S3ConnectionConfig? selectedConnection(Ref ref) {
  final id = ref.watch(selectedConnectionIdProvider);
  final connections = ref.watch(s3ConnectionsProvider).value ?? [];
  if (id == null || connections.isEmpty) return null;
  return connections.where((c) => c.id == id).firstOrNull;
}
