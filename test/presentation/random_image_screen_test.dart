import 'package:aurora_canvas/presentation/image/image_feature.dart';

import 'package:aurora_canvas/presentation/image/widgets/widgets.dart';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../support/fakes.dart';

const errorBannerKey = Key('error_banner');

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
  testWidgets('shows InitialErrorState on initial load failure', (
    tester,
  ) async {
    final controller = FakeRandomImageController(
      RandomImageState.initial().copyWith(
        status: LoadStatus.error,
        errorMessage: 'Network down',
      ),
    );

    await tester.pumpWidget(_wrapWithApp(controller));
    await tester.pump();

    expect(find.byType(InitialErrorState), findsOneWidget);
    expect(find.byKey(errorBannerKey), findsNothing);
  });

  testWidgets('shows ErrorBanner on non-initial error', (tester) async {
    final controller = FakeRandomImageController(
      RandomImageState.initial().copyWith(
        status: LoadStatus.success,
        hasEverLoaded: true,
        imageProvider: testImageProvider(),
        imageRevision: 1,
        errorMessage: 'Couldn’t load that image',
      ),
    );

    await tester.pumpWidget(_wrapWithApp(controller));
    await tester.pump(); // one frame is enough

    expect(find.byKey(const Key('error_banner')), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('Another button disabled and shows its spinner while fetching', (
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

    // Only the button spinner
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

  testWidgets('dismissing banner calls controller.dismissError', (
    tester,
  ) async {
    final controller = FakeRandomImageController(
      RandomImageState.initial().copyWith(
        status: LoadStatus.success, // <-- IMPORTANT
        hasEverLoaded: true,
        imageProvider: testImageProvider(),
        imageRevision: 1,
        errorMessage: 'Temporary issue',
      ),
    );

    await tester.pumpWidget(_wrapWithApp(controller));
    await tester.pump();

    expect(find.byKey(const Key('error_banner')), findsOneWidget);

    // Tap the close/dismiss control based on how your ErrorBanner is built.
    // If it has an X icon:
    final close = find.byIcon(Icons.close);
    expect(close, findsOneWidget);

    await tester.tap(close);
    await tester.pump();

    expect(controller.dismissErrorCalls, 1);
  });
}
