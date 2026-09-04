import 'package:vbox/core/utils/share_links.dart';

class VpnConfig {
  VpnConfig({
    required this.id,
    required this.remark,
    required this.shareLink,
    required this.protocol,
    this.subscriptionId,
    this.lastPing,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id;
  String remark;
  String shareLink;
  String protocol;
  String? subscriptionId;
  int? lastPing;
  final DateTime createdAt;

  bool get isJson => protocol == 'json';

  factory VpnConfig.fromLink({
    required String id,
    required String link,
    String? remark,
    String? subscriptionId,
  }) {
    return VpnConfig(
      id: id,
      remark: remark?.trim().isNotEmpty == true ? remark!.trim() : 'Imported',
      shareLink: link.trim(),
      protocol: detectProtocol(link),
      subscriptionId: subscriptionId,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'remark': remark,
        'shareLink': shareLink,
        'protocol': protocol,
        'subscriptionId': subscriptionId,
        'lastPing': lastPing,
        'createdAt': createdAt.toIso8601String(),
      };

  factory VpnConfig.fromMap(Map map) => VpnConfig(
        id: map['id'] as String,
        remark: map['remark'] as String? ?? 'Server',
        shareLink: map['shareLink'] as String? ?? '',
        protocol: map['protocol'] as String? ?? 'unknown',
        subscriptionId: map['subscriptionId'] as String?,
        lastPing: map['lastPing'] as int?,
        createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ??
            DateTime.now(),
      );
}
