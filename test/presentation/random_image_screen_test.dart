import 'package:aurora_canvas/presentation/image/image_feature.dart';
import 'package:aurora_canvas/presentation/image/widgets/another_button.dart';
import 'package:aurora_canvas/presentation/image/widgets/square_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../support/fakes.dart';

Widget _wrapWithApp(FakeRandomImageController controller) {
  return ChangeNotifierProvider<RandomImageController>.value(
    value: controller,
    child: MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const RandomImageScreen(),
    ),
  );
}

void main() {
  testWidgets('shows error overlay text on initial load failure', (
    tester,
  ) async {
    final controller = FakeRandomImageController(
      RandomImageState.initial().copyWith(
        status: LoadStatus.error,
        errorMessage: 'Network down',
        hasEverLoaded: false,
      ),
    );

    await tester.pumpWidget(_wrapWithApp(controller));
    await tester.pump();

    // The screen always renders SquareImage; error is displayed inside it.
    expect(find.byType(SquareImage), findsOneWidget);
    expect(find.text('Network down'), findsOneWidget);
  });

  testWidgets('Another button disabled and shows spinner while fetching', (
    tester,
  ) async {
    final controller = FakeRandomImageController(
      RandomImageState.initial().copyWith(
        status: LoadStatus.loading,
        imageProvider: testImageProvider(),
        imageRevision: 1,
      ),
    );

    await tester.pumpWidget(_wrapWithApp(controller));
    await tester.pump();

    final btn = tester.widget<FilledButton>(
      find.byKey(AnotherButton.buttonKey),
    );
    expect(btn.onPressed, isNull);

    expect(find.byKey(AnotherButton.spinnerKey), findsOneWidget);
  });

  testWidgets('tapping Another calls fetchAnother', (tester) async {
    final controller = FakeRandomImageController(
      RandomImageState.initial().copyWith(
        status: LoadStatus.success,
        imageProvider: testImageProvider(),
        imageRevision: 1,
      ),
    );

    await tester.pumpWidget(_wrapWithApp(controller));
    await tester.pump();

    expect(controller.fetchAnotherCalls, 0);

    await tester.tap(find.text('Another'));
    await tester.pump();

    expect(controller.fetchAnotherCalls, 1);
  });
}
