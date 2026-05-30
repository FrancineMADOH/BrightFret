import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_enums.dart';
import '../../core/constants/app_text_styles.dart';

/// A single step in a transit timeline.
///
/// Visual states:
/// - [TimelineStepState.past]    — green filled circle with check mark
/// - [TimelineStepState.current] — blue pulsing circle (animated)
/// - [TimelineStepState.future]  — grey outlined circle
///
/// Set [isLast] to true on the final step to suppress the connector line.
/// TODO(F0.6): replace hardcoded date format with intl DateFormat.
class BfTimelineStep extends StatefulWidget {
  const BfTimelineStep({
    super.key,
    required this.stepState,
    required this.label,
    this.datetime,
    this.note,
    this.isLast = false,
  });

  final TimelineStepState stepState;
  final String label;
  final DateTime? datetime;
  final String? note;
  final bool isLast;

  @override
  State<BfTimelineStep> createState() => _BfTimelineStepState();
}

class _BfTimelineStepState extends State<BfTimelineStep>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _pulseAnimation = Tween<double>(begin: 0.75, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    if (widget.stepState == TimelineStepState.current) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(BfTimelineStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.stepState == TimelineStepState.current) {
      _pulseController.repeat(reverse: true);
    } else {
      _pulseController
        ..stop()
        ..reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _indicatorColumn(),
          const SizedBox(width: 12),
          _contentColumn(),
        ],
      ),
    );
  }

  Widget _indicatorColumn() => Column(
        children: [
          _indicator(),
          if (!widget.isLast)
            Expanded(child: _connectorLine()),
        ],
      );

  Widget _indicator() {
    return switch (widget.stepState) {
      TimelineStepState.past => Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: AppColors.statusDelivered,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, color: Colors.white, size: 14),
        ),
      TimelineStepState.current => RepaintBoundary(
          child: ScaleTransition(
            scale: _pulseAnimation,
            child: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: AppColors.statusActive,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      TimelineStepState.future => Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.statusArchived, width: 2),
          ),
        ),
    };
  }

  Widget _connectorLine() => Center(
        child: Container(
          width: 2,
          color: widget.stepState == TimelineStepState.past
              ? AppColors.statusDelivered
              : AppColors.divider,
        ),
      );

  Widget _contentColumn() {
    final textColor = widget.stepState == TimelineStepState.future
        ? AppColors.statusArchived
        : null;

    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(bottom: widget.isLast ? 0 : 16, top: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.label, style: AppTextStyles.label.copyWith(color: textColor)),
            if (widget.datetime != null) ...[
              const SizedBox(height: 2),
              Text(
                _formatDatetime(widget.datetime!),
                style: AppTextStyles.caption.copyWith(color: AppColors.statusArchived),
              ),
            ],
            if (widget.note != null) ...[
              const SizedBox(height: 4),
              Text(
                widget.note!,
                style: AppTextStyles.bodySmall.copyWith(color: textColor),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _formatDatetime(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$d/$m/${dt.year} · $h:$min';
  }
}
