import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:photo_gallery/io/repository/s3_repository.dart';
import 'package:photo_gallery/models/s3_connection_config.dart';
import 'package:photo_gallery/providers/s3_connection_provider.dart';

class EditConnectionPage extends HookConsumerWidget {
  const EditConnectionPage({super.key, required this.connectionId});

  final String connectionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isNew = connectionId == 'new';
    final existing = isNew
        ? null
        : ref
              .watch(s3ConnectionsProvider)
              .value
              ?.where((c) => c.id == connectionId)
              .firstOrNull;

    final nameCtrl = useTextEditingController(text: existing?.name ?? '');
    final endpointCtrl = useTextEditingController(
      text: existing?.endpoint ?? '',
    );
    final regionCtrl = useTextEditingController(text: existing?.region ?? '');
    final bucketCtrl = useTextEditingController(
      text: existing?.bucketName ?? '',
    );
    final accessKeyCtrl = useTextEditingController(
      text: existing?.accessKey ?? '',
    );
    final secretKeyCtrl = useTextEditingController(
      text: existing?.secretKey ?? '',
    );
    final urlStyle = useState(
      existing?.urlStyle ?? S3UrlStyle.virtualHostedStyle,
    );
    final isDefault = useState(existing?.isDefault ?? false);
    final isSafeStorage = useState(existing?.isSafeStorage ?? false);
    final testResult = useState<bool?>(null);
    final isTesting = useState(false);
    final formKey = useMemoized(() => GlobalKey<FormState>());

    S3ConnectionConfig buildConfig() => S3ConnectionConfig(
      id: isNew ? '' : connectionId,
      name: nameCtrl.text,
      endpoint: endpointCtrl.text,
      region: regionCtrl.text,
      bucketName: bucketCtrl.text,
      accessKey: accessKeyCtrl.text,
      secretKey: secretKeyCtrl.text,
      urlStyle: urlStyle.value,
      isDefault: isDefault.value,
      isSafeStorage: isSafeStorage.value,
    );

    Future<void> testConnection() async {
      isTesting.value = true;
      testResult.value = null;
      final repo = S3Repository.fromConfig(buildConfig());
      testResult.value = await repo.testConnection();
      isTesting.value = false;
    }

    Future<void> save() async {
      if (!formKey.currentState!.validate()) return;
      final config = buildConfig();
      final notifier = ref.read(s3ConnectionsProvider.notifier);
      if (isNew) {
        await notifier.addConnection(config);
      } else {
        await notifier.updateConnection(config);
      }
      if (context.mounted) Navigator.of(context).pop();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isNew ? 'Add Connection' : 'Edit Connection'),
        actions: [TextButton(onPressed: save, child: const Text('Save'))],
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Display Name'),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: endpointCtrl,
              decoration: const InputDecoration(
                labelText: 'S3 Endpoint',
                hintText: 's3.amazonaws.com',
              ),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: regionCtrl,
              decoration: const InputDecoration(
                labelText: 'Region',
                hintText: 'us-east-1',
              ),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: bucketCtrl,
              decoration: const InputDecoration(labelText: 'Bucket Name'),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: accessKeyCtrl,
              decoration: const InputDecoration(labelText: 'Access Key'),
              obscureText: true,
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: secretKeyCtrl,
              decoration: const InputDecoration(labelText: 'Secret Key'),
              obscureText: true,
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<S3UrlStyle>(
              initialValue: urlStyle.value,
              items: const [
                DropdownMenuItem(
                  value: S3UrlStyle.virtualHostedStyle,
                  child: Text('Virtual Hosted Style'),
                ),
                DropdownMenuItem(
                  value: S3UrlStyle.pathStyle,
                  child: Text('Path Style'),
                ),
              ],
              onChanged: (v) => urlStyle.value = v!,
              decoration: const InputDecoration(labelText: 'URL Style'),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Default backend'),
              value: isDefault.value,
              onChanged: (v) => isDefault.value = v,
            ),
            SwitchListTile(
              title: const Text('Safe storage (biometric)'),
              value: isSafeStorage.value,
              onChanged: (v) => isSafeStorage.value = v,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: isTesting.value ? null : testConnection,
              icon: isTesting.value
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.wifi_tethering),
              label: Text(
                testResult.value == null
                    ? 'Test Connection'
                    : testResult.value!
                    ? 'Connection OK'
                    : 'Connection Failed',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: testResult.value == true
                    ? Colors.green
                    : testResult.value == false
                    ? Colors.red
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
