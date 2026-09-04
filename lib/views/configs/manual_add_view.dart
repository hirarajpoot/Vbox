import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vbox/controllers/config_controller.dart';
import 'package:vbox/core/theme/app_colors.dart';
import 'package:vbox/core/utils/share_links.dart';
import 'package:vbox/views/widgets/gradient_button.dart';
import 'package:vbox/views/widgets/sub_page_scaffold.dart';

class ManualAddView extends StatefulWidget {
  const ManualAddView({super.key});

  @override
  State<ManualAddView> createState() => _ManualAddViewState();
}

class _ManualAddViewState extends State<ManualAddView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _remark = TextEditingController();
  final _address = TextEditingController();
  final _port = TextEditingController();
  final _uuid = TextEditingController();
  final _password = TextEditingController();
  String _security = 'auto';
  String _network = 'tcp';
  String _tls = '';
  String _method = 'aes-256-gcm';
  final _path = TextEditingController();
  final _host = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _remark.dispose();
    _address.dispose();
    _port.dispose();
    _uuid.dispose();
    _password.dispose();
    _path.dispose();
    _host.dispose();
    super.dispose();
  }

  Future<void> _saveVmess() async {
    final link = buildVmessLink(
      remark: _remark.text.trim().isEmpty ? 'VMess' : _remark.text.trim(),
      address: _address.text.trim(),
      port: _port.text.trim(),
      uuid: _uuid.text.trim(),
      security: _security,
      network: _network,
      host: _host.text.trim(),
      path: _path.text.trim(),
      tls: _tls,
    );
    await Get.find<ConfigController>().addManual(
      remark: _remark.text,
      link: link,
    );
    Get.back();
    Get.snackbar('Saved', 'VMess config added');
  }

  Future<void> _saveSs() async {
    final link = buildShadowsocksLink(
      remark: _remark.text.trim().isEmpty ? 'Shadowsocks' : _remark.text.trim(),
      address: _address.text.trim(),
      port: _port.text.trim(),
      method: _method,
      password: _password.text,
    );
    await Get.find<ConfigController>().addManual(
      remark: _remark.text,
      link: link,
    );
    Get.back();
    Get.snackbar('Saved', 'Shadowsocks config added');
  }

  @override
  Widget build(BuildContext context) {
    return SubPageScaffold(
      title: 'Add server',
      bottom: TabBar(
        controller: _tabs,
        tabs: const [
          Tab(text: 'VMess'),
          Tab(text: 'Shadowsocks'),
        ],
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _form(
            onSave: _saveVmess,
            extra: [
              TextField(
                controller: _uuid,
                decoration: const InputDecoration(labelText: 'UUID'),
              ),
              const SizedBox(height: 12),
              _dropdown('Security', _security, const ['auto', 'aes-128-gcm', 'chacha20-poly1305'],
                  (v) => setState(() => _security = v)),
              const SizedBox(height: 12),
              _dropdown('Network', _network, const ['tcp', 'ws', 'grpc'],
                  (v) => setState(() => _network = v)),
              const SizedBox(height: 12),
              _dropdown('TLS', _tls, const ['', 'tls'],
                  (v) => setState(() => _tls = v), labels: const {'': 'none', 'tls': 'tls'}),
              const SizedBox(height: 12),
              TextField(
                controller: _host,
                decoration: const InputDecoration(labelText: 'Host (optional)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _path,
                decoration: const InputDecoration(labelText: 'Path (optional)'),
              ),
            ],
          ),
          _form(
            onSave: _saveSs,
            extra: [
              TextField(
                controller: _password,
                decoration: const InputDecoration(labelText: 'Password'),
              ),
              const SizedBox(height: 12),
              _dropdown(
                'Method',
                _method,
                const [
                  'aes-256-gcm',
                  'aes-128-gcm',
                  'chacha20-ietf-poly1305',
                  'xchacha20-ietf-poly1305',
                ],
                (v) => setState(() => _method = v),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _form({
    required VoidCallback onSave,
    required List<Widget> extra,
  }) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screen),
      children: [
        TextField(
          controller: _remark,
          decoration: const InputDecoration(labelText: 'Remark'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _address,
          decoration: const InputDecoration(labelText: 'Address'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _port,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Port'),
        ),
        const SizedBox(height: 12),
        ...extra,
        const SizedBox(height: AppSpacing.section),
        GradientButton(label: 'Save config', onPressed: onSave),
      ],
    );
  }

  Widget _dropdown(
    String label,
    String value,
    List<String> items,
    ValueChanged<String> onChanged, {
    Map<String, String>? labels,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      dropdownColor: AppColors.surfaceHigh,
      items: items
          .map(
            (item) => DropdownMenuItem(
              value: item,
              child: Text(labels?[item] ?? item),
            ),
          )
          .toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}
