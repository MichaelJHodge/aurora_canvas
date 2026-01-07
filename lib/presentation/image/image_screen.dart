import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'image_feature.dart';
import 'widgets/widgets.dart';
import 'random_image_controller.dart';

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
      if (!mounted) return;
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
          extendBodyBehindAppBar: true,
          body: AnimatedContainer(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
            color: bg,
            child: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SquareImage(
                        imageProvider: state.imageProvider,
                        imageRevision: state.imageRevision,
                        isLoading: state.isFetching,
                        errorMessage: state.errorMessage,
                      ),
                      const SizedBox(height: 32),
                      AnotherButton(
                        isLoading: state.isFetching,
                        onPressed: () {
                          controller.fetchAnother(context: context);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
