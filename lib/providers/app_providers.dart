import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/network_info.dart';
import '../core/storage/secure_storage.dart';

// Export Network Provider
export '../core/network/network_provider.dart';

// ─────────────────────────────────────────────
// Secure Storage Provider
// ─────────────────────────────────────────────

final secureStorageProvider = Provider((ref) {
  return SecureStorage;
});

// ─────────────────────────────────────────────
// Network Info Provider
// ─────────────────────────────────────────────

final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfoImpl();
});
