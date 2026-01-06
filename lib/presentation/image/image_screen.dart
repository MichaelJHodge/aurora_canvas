import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'random_image_controller.dart';
import 'random_image_state.dart';
import 'widgets/another_button.dart';
import 'widgets/initial_error_state.dart';
import '../../core/ui/error_banner.dart';
import '../../core/ui/loading_overlay.dart';
import 'widgets/square_image.dart';

class RandomImageScreen extends StatefulWidget {
  const RandomImageScreen({super.key});

  @override
  State<RandomImageScreen> createState() => _RandomImageScreenState();
}

class _RandomImageScreenState extends State<RandomImageScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RandomImageController>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<RandomImageController>(
      builder: (context, controller, _) {
        final state = controller.state;
        final bg = controller.blendedBackgroundForTheme(theme);

        return Scaffold(
          body: AnimatedContainer(
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeInOut,
            color: bg,
            child: SafeArea(
              child: Stack(
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: state.isInitialLoadFailure
                          ? InitialErrorState(
                              message:
                                  state.errorMessage ??
                                  'Please check your connection and try again.',
                              onRetry: () => controller.fetchAnother(),
                            )
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Stack(
                                  children: [
                                    SquareImage(
                                      imageUrl: state.imageUrl?.toString(),
                                      placeholderUrl: state.previousImageUrl
                                          ?.toString(),
                                      isInitialLoading:
                                          state.status == LoadStatus.initial ||
                                          (state.imageUrl == null &&
                                              state.isFetching),
                                    ),
                                    LoadingOverlay(isVisible: state.isFetching),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                AnotherButton(
                                  isLoading: state.isFetching,
                                  onPressed: () async {
                                    try {
                                      await controller.fetchAnother();
                                    } catch (_) {
                                      if (!context.mounted) return;

                                      // If it's not the initial load, a quick snackbar is a nice touch.
                                      if (!controller
                                          .state
                                          .isInitialLoadFailure) {
                                        final msg =
                                            controller.state.errorMessage ??
                                            'Something went wrong.';
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(content: Text(msg)),
                                        );
                                      }
                                    }
                                  },
                                ),
                              ],
                            ),
                    ),
                  ),

                  if (state.showErrorBanner && !state.isInitialLoadFailure)
                    Positioned(
                      top: 12,
                      left: 12,
                      right: 12,
                      child: ErrorBanner(
                        message: state.errorMessage!,
                        actions: [
                          TextButton(
                            onPressed: () => controller.fetchAnother(),
                            child: const Text('Retry'),
                          ),
                        ],
                        onDismiss: controller.dismissError,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
