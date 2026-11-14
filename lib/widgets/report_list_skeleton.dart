import 'package:flutter/material.dart';

/// Grey placeholder cards shown while reports are loading
/// (Figma Frame 03 "Loading"). They gently pulse until the data arrives.
class ReportListSkeleton extends StatefulWidget {
  const ReportListSkeleton({super.key, this.count = 5});

  final int count;

  @override
  State<ReportListSkeleton> createState() => _ReportListSkeletonState();
}

class _ReportListSkeletonState extends State<ReportListSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  late final Animation<double> _opacity =
      Tween<double>(begin: 0.45, end: 1).animate(_pulse);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Loading reports',
      child: FadeTransition(
        opacity: _opacity,
        child: ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: widget.count,
          itemBuilder: (context, i) => const _SkeletonCard(),
        ),
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fill = scheme.surfaceContainerHighest;

    Widget bar(double width, double height) => Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(4),
          ),
        );

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: fill,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                bar(150, 12),
                const SizedBox(height: 8),
                bar(90, 10),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
