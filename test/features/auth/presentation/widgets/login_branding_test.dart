import 'package:control_horario/features/auth/presentation/widgets/login_footer.dart';
import 'package:control_horario/features/auth/presentation/widgets/login_header.dart';
import 'package:control_horario/features/auth/presentation/widgets/login_info_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('login chrome presents the canonical brand without legacy text',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                LoginHeader(),
                SizedBox(height: 1000, child: LoginInfoPanel()),
                LoginFooter(),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('controlhorario-rega'), findsNWidgets(2));
    expect(find.text('Sistema seguro • © 2026 controlhorario-rega'),
        findsOneWidget);
    expect(find.text('Time Rega'), findsNothing);
  });
}
