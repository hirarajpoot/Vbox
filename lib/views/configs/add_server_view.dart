import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:vbox/controllers/server_controller.dart';
import 'package:vbox/core/theme/app_colors.dart';
import 'package:vbox/data/models/server_model.dart';
import 'package:vbox/views/widgets/gradient_button.dart';
import 'package:vbox/views/widgets/sub_page_scaffold.dart';

class AddServerScreen extends StatefulWidget {
  const AddServerScreen({super.key, this.server});

  final ServerModel? server;

  @override
  State<AddServerScreen> createState() => _AddServerScreenState();
}

class _AddServerScreenState extends State<AddServerScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _address = TextEditingController();
  final _port = TextEditingController();
  final _secret = TextEditingController();
  final _group = TextEditingController(text: 'My Servers');

  ServerProtocol _protocol = ServerProtocol.vmess;
  String _encryption = 'aes-256-gcm';

  ServerModel? get _editing {
    if (widget.server != null) return widget.server;
    final args = Get.arguments;
    return args is ServerModel ? args : null;
  }

  bool get _isEdit => _editing != null;

  bool get _usesUuid =>
      _protocol == ServerProtocol.vmess || _protocol == ServerProtocol.vless;

  bool get _showEncryption =>
      _protocol == ServerProtocol.shadowsocks ||
      _protocol == ServerProtocol.vmess;

  @override
  void initState() {
    super.initState();
    final existing = _editing;
    if (existing == null) return;
    _name.text = existing.name;
    _address.text = existing.address;
    _port.text = existing.port == 0 ? '' : '${existing.port}';
    _secret.text = existing.uuid?.isNotEmpty == true
        ? existing.uuid!
        : existing.password;
    _group.text = existing.group.isEmpty ? 'My Servers' : existing.group;
    _protocol = existing.protocol;
    _encryption = existing.encryption;
  }

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    _port.dispose();
    _secret.dispose();
    _group.dispose();
    super.dispose();
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) return 'This field is required';
    return null;
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final existing = _editing;
    final secret = _secret.text.trim();
    final model = ServerModel(
      id: existing?.id ?? const Uuid().v4(),
      name: _name.text.trim(),
      protocol: _protocol,
      address: _address.text.trim(),
      port: int.parse(_port.text.trim()),
      password: _usesUuid ? '' : secret,
      uuid: _usesUuid ? secret : null,
      ping: existing?.ping,
      group: _group.text.trim().isEmpty ? 'My Servers' : _group.text.trim(),
      isFavorite: existing?.isFavorite ?? false,
      encryption: _encryption,
      createdAt: existing?.createdAt,
    );
    model.shareLink = model.connectLink;
    await Get.find<ServerController>().addServer(model);
    Get.back();
    Get.snackbar(
      'Saved',
      _isEdit ? 'Server updated' : 'Server added',
    );
  }

  @override
  Widget build(BuildContext context) {
    return SubPageScaffold(
      title: _isEdit ? 'Edit Server' : 'Add Server',
      body: Column(
        children: [
          Expanded(
            child: Form(
              key: _form,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LabeledField(
                      label: 'Server Name',
                      child: TextFormField(
                        controller: _name,
                        validator: _required,
                        decoration: _input(),
                      ),
                    ),
                    _LabeledField(
                      label: 'Protocol',
                      child: DropdownButtonFormField<ServerProtocol>(
                        key: ValueKey(_protocol),
                        initialValue: _protocol,
                        dropdownColor: AppColors.surfaceHigh,
                        decoration: _input(),
                        items: ServerProtocol.values
                            .map(
                              (item) => DropdownMenuItem(
                                value: item,
                                child: Text(_protocolLabel(item)),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() => _protocol = value);
                        },
                      ),
                    ),
                    _LabeledField(
                      label: 'Address / Host',
                      child: TextFormField(
                        controller: _address,
                        validator: _required,
                        decoration: _input(),
                      ),
                    ),
                    _LabeledField(
                      label: 'Port',
                      child: TextFormField(
                        controller: _port,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          final required = _required(value);
                          if (required != null) return required;
                          if (int.tryParse(value!.trim()) == null) {
                            return 'This field is required';
                          }
                          return null;
                        },
                        decoration: _input(),
                      ),
                    ),
                    _LabeledField(
                      label: _usesUuid ? 'UUID' : 'Password',
                      child: TextFormField(
                        controller: _secret,
                        validator: _required,
                        decoration: _input(),
                      ),
                    ),
                    if (_showEncryption)
                      _LabeledField(
                        label: 'Encryption Method',
                        child: DropdownButtonFormField<String>(
                          key: ValueKey('$_protocol-$_encryption'),
                          initialValue: _encryptionItems.contains(_encryption)
                              ? _encryption
                              : _encryptionItems.first,
                          dropdownColor: AppColors.surfaceHigh,
                          decoration: _input(),
                          items: _encryptionItems
                              .map(
                                (item) => DropdownMenuItem(
                                  value: item,
                                  child: Text(item),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() => _encryption = value);
                          },
                        ),
                      ),
                    _LabeledField(
                      label: 'Group',
                      child: TextFormField(
                        controller: _group,
                        decoration: _input(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: GradientButton(
                label: 'Save Server',
                onPressed: _save,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const _encryptionItems = [
    'aes-128-gcm',
    'aes-256-gcm',
    'chacha20-poly1305',
  ];

  String _protocolLabel(ServerProtocol protocol) {
    switch (protocol) {
      case ServerProtocol.shadowsocks:
        return 'Shadowsocks';
      case ServerProtocol.vmess:
        return 'Vmess';
      case ServerProtocol.vless:
        return 'Vless';
      case ServerProtocol.trojan:
        return 'Trojan';
    }
  }

  InputDecoration _input() {
    final radius = BorderRadius.circular(12);
    return InputDecoration(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: const BorderSide(color: AppColors.copper, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: const BorderSide(color: AppColors.danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: const BorderSide(color: AppColors.danger, width: 1.4),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.muted, fontSize: 13),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
