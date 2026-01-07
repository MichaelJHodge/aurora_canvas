import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/ui/ui.dart';
import 'image_feature.dart';
import 'widgets/widgets.dart';

class RandomImageScreen extends StatefulWidget {
  const RandomImageScreen({super.key});

  @override
  State<RandomImageScreen> createState() => _RandomImageScreenState();
}

class _RandomImageScreenState extends State<RandomImageScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _intro;
  late Animation<double> _fade;
  late Animation<double> _scale;
  late Animation<Offset> _lift;

  bool _playedFirstIntro = false;

  @override
  void initState() {
    super.initState();

    // IMPORTANT: Create the controller in initState (not a field initializer),
    // so it can properly read TickerMode and won't crash in widget tests / teardown.
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );

    _fade = CurvedAnimation(parent: _intro, curve: Curves.easeOutCubic);

    _scale = Tween<double>(
      begin: 0.92,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _intro, curve: Curves.easeOutBack));

    _lift = Tween<Offset>(
      begin: const Offset(0, 0.015),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _intro, curve: Curves.easeOutCubic));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<RandomImageController>().init();
    });
  }

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
  }

  void _maybePlayIntro(RandomImageState state) {
    if (_playedFirstIntro) return;

    // We only want to animate the first card entrance once we have an image provider.
    final ready = state.imageProvider != null;
    if (!ready) return;

    _playedFirstIntro = true;
    _intro.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<RandomImageController>(
      builder: (context, controller, _) {
        final state = controller.state;

        _maybePlayIntro(state);

        final bg = controller.blendedBackgroundForTheme(theme);

        // Base image card (image + overlay).
        Widget imageCard = Stack(
          children: [
            SquareImage(
              imageProvider: state.imageProvider,
              imageRevision: state.imageRevision,
              isLoading: state.isFetching && state.imageProvider != null,
              isInitialLoading: state.imageProvider == null && state.isFetching,
            ),
            LoadingOverlay(
              isVisible: state.isFetching && state.imageProvider != null,
            ),
          ],
        );

        // Apply intro animation only once (on first successful image).
        if (_playedFirstIntro) {
          imageCard = FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: _lift,
              child: ScaleTransition(scale: _scale, child: imageCard),
            ),
          );
        }

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
                                imageCard,
                                const SizedBox(height: 16),
                                AnotherButton(
                                  isLoading: state.isFetching,
                                  onPressed: () => controller.fetchAnother(),
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
                        key: Key('error_banner'),
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
