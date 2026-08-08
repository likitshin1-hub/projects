import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_client.dart';
import 'dio_provider.dart';

final dioProvider = Provider((ref) {
  return DioProvider.create();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final dio = ref.watch(dioProvider);

  return ApiClient(dio);
});
