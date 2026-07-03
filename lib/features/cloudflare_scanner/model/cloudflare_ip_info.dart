class CloudflareIpInfo {
  final String ip;
  final int latency;
  final int packetLoss;

  CloudflareIpInfo({
    required this.ip,
    required this.latency,
    required this.packetLoss,
  });

  bool get isReachable => packetLoss < 100 && latency > 0;
}
