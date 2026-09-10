import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:vbox/controllers/server_controller.dart';
import 'package:vbox/core/theme/app_colors.dart';
import 'package:vbox/core/utils/share_links.dart';
import 'package:vbox/data/services/public_server_list.dart';
import 'package:vbox/shared/widgets/pill_button.dart';
import 'package:vbox/views/widgets/sub_page_scaffold.dart';

class PublicServersScreen extends StatefulWidget {
  const PublicServersScreen({super.key});

  @override
  State<PublicServersScreen> createState() => _PublicServersScreenState();
}

class _PublicServersScreenState extends State<PublicServersScreen> {
  final _list = PublicServerList();
  var _source = PublicServerList.sources.first;
  var _loading = true;
  var _adding = '';
  var _error = '';
  var _links = <String>[];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final links = await _list.fetchLatest(_source);
      if (!mounted) return;
      setState(() {
        _links = links;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  Future<void> _addOne(String link) async {
    if (_adding.isNotEmpty) return;
    setState(() => _adding = link);
    try {
      await Get.find<ServerController>().importLink(link);
      if (!mounted) return;
      Get.rawSnackbar(message: 'Added ${remarkFromShareLink(link)}');
      setState(() {});
    } catch (error) {
      Get.snackbar('Could not add', error.toString());
    } finally {
      if (mounted) setState(() => _adding = '');
    }
  }

  bool _alreadyAdded(String link) {
    final servers = Get.find<ServerController>().servers;
    return servers.any((s) => s.shareLink.trim() == link.trim());
  }

  @override
  Widget build(BuildContext context) {
    return SubPageScaffold(
      kicker: 'OPEN RACK',
      title: 'Public nodes',
      actions: [
        IconButton(
          onPressed: _loading ? null : _load,
          icon: const Icon(LucideIcons.refreshCw),
        ),
      ],
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: Text(
              'Latest ${_source.label} nodes only — not the full subscription. '
              'Not every server works; add one, then try it.',
              style: const TextStyle(color: AppColors.muted, fontSize: 12, height: 1.4),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: PublicServerList.sources.map((source) {
                final selected = source.label == _source.label;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(source.label),
                    selected: selected,
                    onSelected: (_) {
                      if (selected || _loading) return;
                      setState(() => _source = source);
                      _load();
                    },
                    selectedColor: AppColors.copper.withValues(alpha: 0.22),
                    backgroundColor: AppColors.surface,
                    labelStyle: TextStyle(
                      color: selected ? AppColors.copperSoft : AppColors.muted,
                      fontWeight: FontWeight.w600,
                    ),
                    side: BorderSide(
                      color: selected ? AppColors.copper : AppColors.divider,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(child: _body()),
        ],
      ),
    );
  }

  Widget _body() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.copper),
      );
    }
    if (_error.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.muted)),
              const SizedBox(height: 16),
              SizedBox(
                width: 160,
                child: PillButton(text: 'Retry', onPressed: _load),
              ),
            ],
          ),
        ),
      );
    }
    if (_links.isEmpty) {
      return const Center(
        child: Text('No servers in this list right now.', style: TextStyle(color: AppColors.muted)),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
      itemCount: _links.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final link = _links[index];
        final name = remarkFromShareLink(link);
        final added = _alreadyAdded(link);
        final busy = _adding == link;
        return Container(
          padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
          decoration: BoxDecoration(
            color: const Color(0xCC1A1612),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.85)),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.protocol(_source.protocol),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.cream,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _source.label,
                      style: const TextStyle(color: AppColors.muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: added || busy ? null : () => _addOne(link),
                child: busy
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.copper,
                        ),
                      )
                    : Text(
                        added ? 'Added' : 'Add',
                        style: TextStyle(
                          color: added ? AppColors.muted : AppColors.copper,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
