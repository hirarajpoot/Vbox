class Subscription {
  Subscription({
    required this.id,
    required this.name,
    required this.url,
    this.lastUpdated,
    this.autoUpdate = true,
  });

  final String id;
  String name;
  String url;
  DateTime? lastUpdated;
  bool autoUpdate;

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'url': url,
        'lastUpdated': lastUpdated?.toIso8601String(),
        'autoUpdate': autoUpdate,
      };

  factory Subscription.fromMap(Map map) => Subscription(
        id: map['id'] as String,
        name: map['name'] as String? ?? 'Subscription',
        url: map['url'] as String? ?? '',
        lastUpdated: DateTime.tryParse(map['lastUpdated'] as String? ?? ''),
        autoUpdate: map['autoUpdate'] as bool? ?? true,
      );
}
