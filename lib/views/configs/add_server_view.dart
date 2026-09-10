import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:vbox/controllers/server_controller.dart';
import 'package:vbox/core/theme/app_colors.dart';
import 'package:vbox/core/utils/parse_server_link.dart';
import 'package:vbox/data/models/server_model.dart';
import 'package:vbox/shared/widgets/pill_button.dart';
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
  final _host = TextEditingController();
  final _path = TextEditingController();
  final _sni = TextEditingController();
  final _publicKey = TextEditingController();
  final _shortId = TextEditingController();
  final _spiderX = TextEditingController();
  final _serviceName = TextEditingController();
  final _alterId = TextEditingController(text: '0');

  ServerProtocol _protocol = ServerProtocol.vmess;
  String _encryption = 'auto';
  String _network = 'tcp';
  String _streamSecurity = 'none';
  String _fingerprint = '';
  String _flow = '';
  String _alpn = '';

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

  bool get _showTransport => _protocol != ServerProtocol.shadowsocks;

  bool get _showWsFields =>
      _showTransport && (_network == 'ws' || _network == 'h2' || _network == 'tcp');

  bool get _showGrpc => _showTransport && _network == 'grpc';

  bool get _showTls =>
      _showTransport && (_streamSecurity == 'tls' || _streamSecurity == 'reality');

  bool get _showReality =>
      _protocol == ServerProtocol.vless && _streamSecurity == 'reality';

  bool get _showFlow =>
      _protocol == ServerProtocol.vless &&
      (_streamSecurity == 'tls' || _streamSecurity == 'reality');

  @override
  void initState() {
    super.initState();
    final existing = _editing;
    if (existing == null) return;
    _fill(existing);
    if (existing.address.isEmpty && existing.shareLink.isNotEmpty) {
      final parsed = parseServerLink(existing.shareLink);
      if (parsed != null) {
        _fill(parsed, keepIdentity: true);
      }
    }
  }

  void _fill(ServerModel existing, {bool keepIdentity = false}) {
    _name.text = existing.name;
    _address.text = existing.address;
    _port.text = existing.port == 0 ? '' : '${existing.port}';
    _secret.text = existing.uuid?.isNotEmpty == true
        ? existing.uuid!
        : existing.password;
    if (!keepIdentity) {
      _group.text = existing.group.isEmpty ? 'My Servers' : existing.group;
    }
    _host.text = existing.host;
    _path.text = existing.path;
    _sni.text = existing.sni;
    _publicKey.text = existing.publicKey;
    _shortId.text = existing.shortId;
    _spiderX.text = existing.spiderX;
    _serviceName.text = existing.serviceName;
    _alterId.text = existing.alterId.isEmpty ? '0' : existing.alterId;
    _protocol = existing.protocol;
    _encryption = existing.encryption;
    _network = existing.network.isEmpty ? 'tcp' : existing.network;
    _streamSecurity =
        existing.streamSecurity.isEmpty ? 'none' : existing.streamSecurity;
    _fingerprint = existing.fingerprint;
    _flow = existing.flow;
    _alpn = existing.alpn;
  }

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    _port.dispose();
    _secret.dispose();
    _group.dispose();
    _host.dispose();
    _path.dispose();
    _sni.dispose();
    _publicKey.dispose();
    _shortId.dispose();
    _spiderX.dispose();
    _serviceName.dispose();
    _alterId.dispose();
    super.dispose();
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) return 'This field is required';
    return null;
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    if (_showReality && _publicKey.text.trim().isEmpty) {
      Get.snackbar('Reality', 'Public key (pbk) is required');
      return;
    }
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
      network: _network,
      streamSecurity: _streamSecurity,
      host: _host.text.trim(),
      path: _path.text.trim(),
      sni: _sni.text.trim(),
      fingerprint: _fingerprint,
      flow: _flow,
      publicKey: _publicKey.text.trim(),
      shortId: _shortId.text.trim(),
      spiderX: _spiderX.text.trim(),
      serviceName: _serviceName.text.trim(),
      alpn: _alpn,
      alterId: _alterId.text.trim().isEmpty ? '0' : _alterId.text.trim(),
      createdAt: existing?.createdAt,
    );
    model.shareLink = model.connectLink;
    await Get.find<ServerController>().addServer(model);
    Get.back();
    Get.snackbar('Saved', _isEdit ? 'Server updated' : 'Server added');
  }

  @override
  Widget build(BuildContext context) {
    return SubPageScaffold(
      kicker: _isEdit ? 'NODE EDIT' : 'NODE FORGE',
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
                    const _SectionTitle('NODE'),
                    _Panel(
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
                        dropdownColor: const Color(0xFF241E18),
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
                          setState(() {
                            _protocol = value;
                            if (value == ServerProtocol.shadowsocks) {
                              _encryption = 'aes-256-gcm';
                            } else if (value == ServerProtocol.vmess &&
                                !_vmessEncryption.contains(_encryption)) {
                              _encryption = 'auto';
                            }
                            if (value != ServerProtocol.vless &&
                                _streamSecurity == 'reality') {
                              _streamSecurity = 'tls';
                            }
                          });
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
                            return 'Enter a valid port';
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
                        child: _stringDropdown(
                          value: _encryptionItems.contains(_encryption)
                              ? _encryption
                              : _encryptionItems.first,
                          items: _encryptionItems,
                          onChanged: (value) =>
                              setState(() => _encryption = value),
                        ),
                      ),
                    if (_protocol == ServerProtocol.vmess)
                      _LabeledField(
                        label: 'AlterID',
                        child: TextFormField(
                          controller: _alterId,
                          keyboardType: TextInputType.number,
                          decoration: _input(),
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
                    if (_showTransport) ...[
                      const _SectionTitle('TRANSPORT'),
                      _Panel(
                        children: [
                      _LabeledField(
                        label: 'Network',
                        child: _stringDropdown(
                          value: _network,
                          items: const ['tcp', 'ws', 'grpc', 'h2'],
                          onChanged: (value) => setState(() => _network = value),
                        ),
                      ),
                      if (_showWsFields) ...[
                        _LabeledField(
                          label: _network == 'tcp' ? 'Host (optional)' : 'Host',
                          child: TextFormField(
                            controller: _host,
                            decoration: _input(hint: 'example.com'),
                          ),
                        ),
                        _LabeledField(
                          label: _network == 'tcp' ? 'Path (optional)' : 'Path',
                          child: TextFormField(
                            controller: _path,
                            decoration: _input(hint: '/'),
                          ),
                        ),
                      ],
                      if (_showGrpc)
                        _LabeledField(
                          label: 'gRPC service name',
                          child: TextFormField(
                            controller: _serviceName,
                            decoration: _input(),
                          ),
                        ),
                        ],
                      ),
                      const _SectionTitle('SECURITY'),
                      _Panel(
                        children: [
                      _LabeledField(
                        label: 'TLS / Reality',
                        child: _stringDropdown(
                          value: _securityItems.contains(_streamSecurity)
                              ? _streamSecurity
                              : 'none',
                          items: _securityItems,
                          labels: const {
                            'none': 'None',
                            'tls': 'TLS',
                            'reality': 'Reality',
                          },
                          onChanged: (value) =>
                              setState(() => _streamSecurity = value),
                        ),
                      ),
                      if (_showTls) ...[
                        _LabeledField(
                          label: 'SNI',
                          child: TextFormField(
                            controller: _sni,
                            decoration: _input(hint: 'Same as host if empty'),
                          ),
                        ),
                        _LabeledField(
                          label: 'Fingerprint',
                          child: _stringDropdown(
                            value: _fingerprints.contains(_fingerprint)
                                ? _fingerprint
                                : '',
                            items: _fingerprints,
                            labels: const {'': 'Default'},
                            onChanged: (value) =>
                                setState(() => _fingerprint = value),
                          ),
                        ),
                        _LabeledField(
                          label: 'ALPN',
                          child: _stringDropdown(
                            value: _alpnItems.contains(_alpn) ? _alpn : '',
                            items: _alpnItems,
                            labels: const {'': 'Default'},
                            onChanged: (value) => setState(() => _alpn = value),
                          ),
                        ),
                      ],
                      if (_showFlow)
                        _LabeledField(
                          label: 'Flow',
                          child: _stringDropdown(
                            value: _flowItems.contains(_flow) ? _flow : '',
                            items: _flowItems,
                            labels: const {'': 'None'},
                            onChanged: (value) => setState(() => _flow = value),
                          ),
                        ),
                      if (_showReality) ...[
                        _LabeledField(
                          label: 'Public key (pbk)',
                          child: TextFormField(
                            controller: _publicKey,
                            decoration: _input(),
                          ),
                        ),
                        _LabeledField(
                          label: 'Short ID (sid)',
                          child: TextFormField(
                            controller: _shortId,
                            decoration: _input(),
                          ),
                        ),
                        _LabeledField(
                          label: 'SpiderX (spx)',
                          child: TextFormField(
                            controller: _spiderX,
                            decoration: _input(hint: '/'),
                          ),
                        ),
                      ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: PillButton(
                text: 'Save Server',
                onPressed: _save,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> get _encryptionItems => _protocol == ServerProtocol.vmess
      ? _vmessEncryption
      : _ssEncryption;

  List<String> get _securityItems => _protocol == ServerProtocol.vless
      ? const ['none', 'tls', 'reality']
      : const ['none', 'tls'];

  static const _vmessEncryption = [
    'auto',
    'aes-128-gcm',
    'aes-256-gcm',
    'chacha20-poly1305',
  ];

  static const _ssEncryption = [
    'aes-256-gcm',
    'aes-128-gcm',
    'chacha20-ietf-poly1305',
    'xchacha20-ietf-poly1305',
    'chacha20-poly1305',
  ];

  static const _fingerprints = [
    '',
    'chrome',
    'firefox',
    'safari',
    'ios',
    'android',
    'randomized',
  ];

  static const _flowItems = ['', 'xtls-rprx-vision'];

  static const _alpnItems = ['', 'h2,http/1.1', 'http/1.1', 'h3'];

  Widget _stringDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
    Map<String, String> labels = const {},
  }) {
    final selected = items.contains(value) ? value : items.first;
    return DropdownButtonFormField<String>(
      key: ValueKey('$selected-${items.join()}'),
      initialValue: selected,
      dropdownColor: const Color(0xFF241E18),
      decoration: _input(),
      items: items
          .map(
            (item) => DropdownMenuItem(
              value: item,
              child: Text(labels[item] ?? item),
            ),
          )
          .toList(),
      onChanged: (next) {
        if (next == null) return;
        onChanged(next);
      },
    );
  }

  String _protocolLabel(ServerProtocol protocol) {
    switch (protocol) {
      case ServerProtocol.shadowsocks:
        return 'Shadowsocks';
      case ServerProtocol.vmess:
        return 'VMess';
      case ServerProtocol.vless:
        return 'VLESS';
      case ServerProtocol.trojan:
        return 'Trojan';
    }
  }

  InputDecoration _input({String? hint}) {
    final radius = BorderRadius.circular(14);
    final side = BorderSide(color: AppColors.border.withValues(alpha: 0.7));
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.muted, fontSize: 13),
      filled: true,
      fillColor: const Color(0x6617100C),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(borderRadius: radius, borderSide: side),
      enabledBorder: OutlineInputBorder(borderRadius: radius, borderSide: side),
      focusedBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: AppColors.copper.withValues(alpha: 0.75), width: 1.4),
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

class _Panel extends StatelessWidget {
  const _Panel({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 4),
      decoration: BoxDecoration(
        color: const Color(0xCC1A1612),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.copper.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: AppColors.copperSoft,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.6,
        ),
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
