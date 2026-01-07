import 'package:flutter/material.dart';

class SquareImage extends StatelessWidget {
  const SquareImage({
    super.key,
    required this.imageProvider,
    required this.imageRevision,
    required this.isLoading,
    required this.isInitialLoading,
  });

  final ImageProvider? imageProvider;
  final int imageRevision;
  final bool isLoading;
  final bool isInitialLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final screenW = MediaQuery.sizeOf(context).width;
    final available = (screenW - 40).clamp(0.0, double.infinity);
    final size = available.clamp(0.0, 380.0); // allows tiny screens

    return Semantics(
      label: 'Random image',
      image: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: size,
          height: size,
          color: theme.colorScheme.surface.withValues(alpha: 0.55),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (imageProvider != null)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 320),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, anim) =>
                      FadeTransition(opacity: anim, child: child),
                  child: Image(
                    key: ValueKey(imageRevision),
                    image: imageProvider!,
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                    filterQuality: FilterQuality.medium,
                  ),
                )
              else
                const _InitialCanvasLoading(),

              // Skeleton overlay:
              // - initial load: full shimmer
              // - swap: shimmer overlay on top of current image
              if (isInitialLoading)
                const _ShimmerSkeleton(opacity: 0.95)
              else if (isLoading)
                const _ShimmerSkeleton(opacity: 0.35),
            ],
          ),
        ),
      ),
    );
  }
}

class _InitialCanvasLoading extends StatelessWidget {
  const _InitialCanvasLoading();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Non-grey, “Aurora” feeling without introducing a whole background system.
    final c1 = Color.lerp(
      theme.colorScheme.primaryContainer,
      theme.colorScheme.primary,
      0.25,
    )!;
    final c2 = Color.lerp(
      theme.colorScheme.tertiaryContainer,
      theme.colorScheme.tertiary,
      0.25,
    )!;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [c1.withValues(alpha: 0.85), c2.withValues(alpha: 0.85)],
        ),
      ),
      child: Center(
        child: Semantics(
          label: 'Loading Canvas',
          liveRegion: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _MiniSpinner(),
              const SizedBox(height: 12),
              Text(
                'Loading Canvas…',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer.withValues(
                    alpha: 0.90,
                  ),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniSpinner extends StatefulWidget {
  const _MiniSpinner();

  @override
  State<_MiniSpinner> createState() => _MiniSpinnerState();
}

class _MiniSpinnerState extends State<_MiniSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RotationTransition(
      turns: _c,
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.55),
            width: 2,
          ),
        ),
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            width: 4,
            height: 6,
            decoration: BoxDecoration(
              color: theme.colorScheme.onPrimaryContainer.withValues(
                alpha: 0.70,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }
}

class _ShimmerSkeleton extends StatefulWidget {
  const _ShimmerSkeleton({this.opacity = 0.7});

  final double opacity;

  @override
  State<_ShimmerSkeleton> createState() => _ShimmerSkeletonState();
}

class _ShimmerSkeletonState extends State<_ShimmerSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1150),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final base = theme.colorScheme.surface.withValues(
      alpha: 0.55 * widget.opacity,
    );
    final highlight = theme.colorScheme.onSurface.withValues(
      alpha: 0.12 * widget.opacity,
    );

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final t = _c.value;
          final begin = Alignment(-1.2 + (2.4 * t), -1);
          final end = Alignment(-0.2 + (2.4 * t), 1);

          return DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: begin,
                end: end,
                colors: [base, highlight, base],
                stops: const [0.15, 0.5, 0.85],
              ),
            ),
          );
        },
      ),
    );
  }
}
