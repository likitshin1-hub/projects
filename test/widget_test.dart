import 'package:flutter_test/flutter_test.dart';
import 'package:tbmovehub_admin/main.dart';

void main() {
  testWidgets('Admin app loads smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const TBMoveHubAdminApp());
    expect(find.text('เข้าสู่ระบบแอดมิน'), findsOneWidget);
  });
}
