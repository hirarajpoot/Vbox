Map<String, dynamic> patchXrayConfigForTrafficStats(Map<String, dynamic> map) {
  map['stats'] = <String, dynamic>{};
  map['policy'] = {
    'levels': {
      '8': {
        'connIdle': 300,
        'downlinkOnly': 1,
        'handshake': 4,
        'uplinkOnly': 1,
      },
    },
    'system': {
      'statsOutboundUplink': true,
      'statsOutboundDownlink': true,
    },
  };

  final outbounds = map['outbounds'];
  if (outbounds is! List || outbounds.isEmpty) return map;

  Map<dynamic, dynamic>? proxy;
  Map<dynamic, dynamic>? blackhole;

  for (final item in outbounds) {
    if (item is! Map) continue;
    final protocol = '${item['protocol'] ?? ''}'.toLowerCase();
    final tag = '${item['tag'] ?? ''}'.toLowerCase();
    if (_isBlackhole(protocol, tag)) {
      blackhole ??= item;
      continue;
    }
    if (_isNonProxy(protocol, tag)) continue;
    if (tag == 'proxy') {
      proxy = item;
      continue;
    }
    proxy ??= item;
  }

  if (proxy != null) {
    final oldTag = proxy['tag']?.toString();
    proxy['tag'] = 'proxy';
    if (oldTag != null && oldTag.isNotEmpty && oldTag != 'proxy') {
      rewriteRoutingTag(map, oldTag, 'proxy');
    }
    outbounds.remove(proxy);
    outbounds.insert(0, proxy);
  }

  if (blackhole != null) {
    final oldTag = blackhole['tag']?.toString();
    blackhole['tag'] = 'block';
    if (oldTag != null && oldTag.isNotEmpty && oldTag != 'block') {
      rewriteRoutingTag(map, oldTag, 'block');
    }
  }

  return map;
}

void rewriteRoutingTag(Map<String, dynamic> map, String from, String to) {
  _walkRouting(map['routing'], from, to);
}

bool _isBlackhole(String protocol, String tag) {
  return protocol == 'blackhole' ||
      tag == 'blackhole' ||
      tag == 'block' ||
      tag == 'blocked' ||
      tag == 'reject';
}

bool _isNonProxy(String protocol, String tag) {
  return protocol == 'freedom' ||
      protocol == 'dns' ||
      protocol == 'loopback' ||
      tag == 'direct' ||
      tag == 'dns-out' ||
      tag == 'dns' ||
      tag == 'api';
}

void _walkRouting(dynamic node, String from, String to) {
  if (node is Map) {
    if (node['outboundTag'] == from) node['outboundTag'] = to;
    if (node['inboundTag'] == from) node['inboundTag'] = to;
    final tags = node['outboundTags'];
    if (tags is List) {
      for (var i = 0; i < tags.length; i++) {
        if (tags[i] == from) tags[i] = to;
      }
    }
    for (final value in node.values) {
      _walkRouting(value, from, to);
    }
  } else if (node is List) {
    for (final value in node) {
      _walkRouting(value, from, to);
    }
  }
}
