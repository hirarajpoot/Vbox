class TrafficSnapshot {
  const TrafficSnapshot({
    required this.rx,
    required this.tx,
    required this.at,
  });

  final int rx;
  final int tx;
  final DateTime at;
}

class SpeedSample {
  const SpeedSample({
    required this.uploadBps,
    required this.downloadBps,
  });

  final double uploadBps;
  final double downloadBps;
}

SpeedSample? speedFromSnapshots(TrafficSnapshot prev, TrafficSnapshot next) {
  final dt = next.at.difference(prev.at).inMilliseconds / 1000.0;
  if (dt <= 0) return null;
  final down = (next.rx - prev.rx) / dt;
  final up = (next.tx - prev.tx) / dt;
  return SpeedSample(
    uploadBps: up < 0 ? 0 : up,
    downloadBps: down < 0 ? 0 : down,
  );
}
