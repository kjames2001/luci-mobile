/// Represents a WiFi network found during a wireless scan.
class WifiScanResult {
  final String ssid;
  final String bssid;
  final String mode;
  final int channel;
  final int signal;
  final int quality;
  final int qualityMax;
  final WifiEncryption encryption;

  WifiScanResult({
    required this.ssid,
    required this.bssid,
    required this.mode,
    required this.channel,
    required this.signal,
    required this.quality,
    required this.qualityMax,
    required this.encryption,
  });

  factory WifiScanResult.fromJson(Map<String, dynamic> json) {
    return WifiScanResult(
      ssid: json['ssid'] as String? ?? '',
      bssid: json['bssid'] as String? ?? '',
      mode: json['mode'] as String? ?? 'Unknown',
      channel: json['channel'] as int? ?? 0,
      signal: json['signal'] as int? ?? -100,
      quality: json['quality'] as int? ?? 0,
      qualityMax: json['quality_max'] as int? ?? 100,
      encryption: WifiEncryption.fromJson(
        json['encryption'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  /// Signal quality as a percentage (0-100).
  int get qualityPercent {
    if (qualityMax <= 0) return 0;
    return ((quality / qualityMax) * 100).round().clamp(0, 100);
  }

  /// Human-readable signal strength descriptor.
  String get signalStrength {
    if (signal >= -50) return 'Excellent';
    if (signal >= -60) return 'Good';
    if (signal >= -70) return 'Fair';
    if (signal >= -80) return 'Weak';
    return 'Very Weak';
  }

  /// Returns the appropriate WiFi signal icon level (0-4 bars).
  int get signalBars {
    if (signal >= -50) return 4;
    if (signal >= -60) return 3;
    if (signal >= -70) return 2;
    if (signal >= -80) return 1;
    return 0;
  }

  /// Frequency band string based on channel number.
  String get band {
    if (channel >= 1 && channel <= 14) return '2.4 GHz';
    if (channel >= 32 && channel <= 177) return '5 GHz';
    if (channel >= 1 && channel <= 233) return '6 GHz';
    return 'Unknown';
  }
}

/// Represents WiFi encryption details from a scan result.
class WifiEncryption {
  final bool enabled;
  final String description;
  final bool wep;
  final int wpa;
  final List<String> authSuites;
  final List<String> pairCiphers;
  final List<String> groupCiphers;

  WifiEncryption({
    required this.enabled,
    required this.description,
    required this.wep,
    required this.wpa,
    required this.authSuites,
    required this.pairCiphers,
    required this.groupCiphers,
  });

  factory WifiEncryption.fromJson(Map<String, dynamic> json) {
    return WifiEncryption(
      enabled: json['enabled'] as bool? ?? false,
      description: json['description'] as String? ?? 'None',
      wep: json['wep'] as bool? ?? false,
      wpa: json['wpa'] as int? ?? 0,
      authSuites: _toStringList(json['auth_suites']),
      pairCiphers: _toStringList(json['pair_ciphers']),
      groupCiphers: _toStringList(json['group_ciphers']),
    );
  }

  static List<String> _toStringList(dynamic value) {
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return [];
  }

  /// Whether this network is open (no encryption).
  bool get isOpen => !enabled;

  /// Short encryption label for display.
  String get shortLabel {
    if (!enabled) return 'Open';
    if (wep) return 'WEP';
    if (description.contains('WPA3')) return 'WPA3';
    if (description.contains('WPA2')) return 'WPA2';
    if (description.contains('WPA')) return 'WPA';
    return description;
  }

  /// Returns the OpenWrt encryption config string for connecting.
  String get openwrtEncryption {
    if (!enabled) return 'none';
    if (wep) return 'wep-open';
    final hasSAE = authSuites.contains('SAE');
    final hasPSK = authSuites.contains('PSK');
    if (hasSAE && hasPSK) {
      return wpa >= 2 ? 'sae-mixed' : 'sae';
    }
    if (hasSAE) return 'sae';
    if (wpa >= 2) return 'psk2';
    if (wpa >= 1) return 'psk';
    return 'psk2'; // Default fallback
  }

  /// Whether this encryption type requires a password.
  bool get requiresPassword => enabled;
}
