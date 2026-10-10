import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../core/constants/app_assets.dart';
import '../core/theme/app_colors.dart';
import '../models/expense.dart';
import 'transaction_row.dart';

/// Transaction row that reveals the grey "edit" and red "delete" buttons
/// from the Figma Transaction History screen.
/// Swipe left (or tap the row) to open, swipe right (or tap again) to close.
class SwipeableTransactionRow extends StatefulWidget {
  const SwipeableTransactionRow({
    super.key,
    required this.expense,
    required this.onEdit,
    required this.onDelete,
  });

  final Expense expense;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  State<SwipeableTransactionRow> createState() =>
      _SwipeableTransactionRowState();
}

class _SwipeableTransactionRowState extends State<SwipeableTransactionRow>
    with SingleTickerProviderStateMixin {
  static const double _actionWidth = 43;
  static const double _actionsWidth = _actionWidth * 2;

  // 0 = closed, 1 = fully open.
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    if (_controller.value > 0.5) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }

  void _onDragUpdate(DragUpdateDetails details) {
    _controller.value -= details.primaryDelta! / _actionsWidth;
  }

  void _onDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity < -300 || (velocity <= 300 && _controller.value > 0.5)) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  void _runAction(VoidCallback action) {
    _controller.reverse();
    action();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _toggle,
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;
          return SizedBox(
            height: TransactionRow.height + 1,
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 1),
                    // In Figma the amount moves to 8 px from the buttons.
                    child: TransactionRow(
                      expense: widget.expense,
                      rightPadding: 22 - 14 * t,
                    ),
                  ),
                ),
                ClipRect(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    widthFactor: t,
                    child: Row(
                      children: [
                        _ActionButton(
                          color: AppColors.swipeEdit,
                          icon: AppAssets.editFilled,
                          tooltip: 'Edit',
                          onTap: () => _runAction(widget.onEdit),
                        ),
                        _ActionButton(
                          color: AppColors.swipeDelete,
                          icon: AppAssets.deleteFilled,
                          tooltip: 'Delete',
                          onTap: () => _runAction(widget.onDelete),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.color,
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final Color color;
  final String icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: color,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: _SwipeableTransactionRowState._actionWidth,
            height: 42,
            child: Center(child: SvgPicture.asset(icon, width: 16, height: 16)),
          ),
        ),
      ),
    );
  }
}
