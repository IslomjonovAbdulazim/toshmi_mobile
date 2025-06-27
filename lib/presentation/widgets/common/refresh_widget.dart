import 'package:flutter/material.dart';
import '../../../core/themes/app_themes.dart';

/// Custom refresh widget with theming support
class CustomRefreshWidget extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Color? backgroundColor;
  final Color? color;
  final double displacement;
  final RefreshIndicatorTriggerMode triggerMode;
  final double strokeWidth;

  const CustomRefreshWidget({
    super.key,
    required this.child,
    required this.onRefresh,
    this.backgroundColor,
    this.color,
    this.displacement = 40.0,
    this.triggerMode = RefreshIndicatorTriggerMode.onEdge,
    this.strokeWidth = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return RefreshIndicator(
      onRefresh: onRefresh,
      backgroundColor: backgroundColor ?? colors.cardBackground,
      color: color ?? colors.info,
      displacement: displacement,
      triggerMode: triggerMode,
      strokeWidth: strokeWidth,
      child: child,
    );
  }
}

/// Pull to refresh with custom animation
class AnimatedRefreshWidget extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final String? refreshText;
  final String? releaseText;
  final String? loadingText;
  final Color? backgroundColor;
  final Color? color;

  const AnimatedRefreshWidget({
    super.key,
    required this.child,
    required this.onRefresh,
    this.refreshText,
    this.releaseText,
    this.loadingText,
    this.backgroundColor,
    this.color,
  });

  @override
  State<AnimatedRefreshWidget> createState() => _AnimatedRefreshWidgetState();
}

class _AnimatedRefreshWidgetState extends State<AnimatedRefreshWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    _controller.forward();

    try {
      await widget.onRefresh();
    } finally {
      _controller.reverse();
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      backgroundColor: widget.backgroundColor ?? colors.cardBackground,
      color: widget.color ?? colors.info,
      child: widget.child,
    );
  }
}

/// Manual refresh button widget
class ManualRefreshWidget extends StatefulWidget {
  final Future<void> Function() onRefresh;
  final String? text;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsets padding;
  final bool showLastRefresh;

  const ManualRefreshWidget({
    super.key,
    required this.onRefresh,
    this.text,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.padding = const EdgeInsets.all(16),
    this.showLastRefresh = false,
  });

  @override
  State<ManualRefreshWidget> createState() => _ManualRefreshWidgetState();
}

class _ManualRefreshWidgetState extends State<ManualRefreshWidget> {
  bool _isRefreshing = false;
  DateTime? _lastRefresh;

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    try {
      await widget.onRefresh();
      setState(() {
        _lastRefresh = DateTime.now();
      });
    } finally {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: widget.padding,
      child: Column(
        children: [
          ElevatedButton.icon(
            onPressed: _isRefreshing ? null : _handleRefresh,
            icon: _isRefreshing
                ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  widget.foregroundColor ?? Colors.white,
                ),
              ),
            )
                : Icon(widget.icon ?? Icons.refresh),
            label: Text(
              _isRefreshing
                  ? 'Yangilanmoqda...'
                  : (widget.text ?? 'Yangilash'),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.backgroundColor ?? colors.info,
              foregroundColor: widget.foregroundColor ?? Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),

          if (widget.showLastRefresh && _lastRefresh != null) ...[
            const SizedBox(height: 8),
            Text(
              'Oxirgi yangilanish: ${_formatTime(_lastRefresh!)}',
              style: TextStyle(
                fontSize: 12,
                color: colors.secondaryText,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Hozir';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} daqiqa oldin';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} soat oldin';
    } else {
      return '${dateTime.day}.${dateTime.month}.${dateTime.year}';
    }
  }
}

/// Floating refresh button
class FloatingRefreshButton extends StatefulWidget {
  final Future<void> Function() onRefresh;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final IconData? icon;
  final String? tooltip;

  const FloatingRefreshButton({
    super.key,
    required this.onRefresh,
    this.backgroundColor,
    this.foregroundColor,
    this.icon,
    this.tooltip,
  });

  @override
  State<FloatingRefreshButton> createState() => _FloatingRefreshButtonState();
}

class _FloatingRefreshButtonState extends State<FloatingRefreshButton>
    with SingleTickerProviderStateMixin {
  bool _isRefreshing = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    _animationController.repeat();

    try {
      await widget.onRefresh();
    } finally {
      _animationController.stop();
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return FloatingActionButton(
      onPressed: _isRefreshing ? null : _handleRefresh,
      backgroundColor: widget.backgroundColor ?? colors.info,
      foregroundColor: widget.foregroundColor ?? Colors.white,
      tooltip: widget.tooltip ?? 'Yangilash',
      child: _isRefreshing
          ? AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.rotate(
            angle: _animationController.value * 2 * 3.14159,
            child: Icon(widget.icon ?? Icons.refresh),
          );
        },
      )
          : Icon(widget.icon ?? Icons.refresh),
    );
  }
}

/// Swipe to refresh with custom indicator
class SwipeRefreshWidget extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final double triggerThreshold;
  final Color? indicatorColor;
  final String? refreshText;

  const SwipeRefreshWidget({
    super.key,
    required this.child,
    required this.onRefresh,
    this.triggerThreshold = 80.0,
    this.indicatorColor,
    this.refreshText,
  });

  @override
  State<SwipeRefreshWidget> createState() => _SwipeRefreshWidgetState();
}

class _SwipeRefreshWidgetState extends State<SwipeRefreshWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isRefreshing = false;
  double _dragDistance = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (_isRefreshing) return;

    setState(() {
      _dragDistance += details.delta.dy;
      if (_dragDistance < 0) _dragDistance = 0;
      if (_dragDistance > widget.triggerThreshold * 1.5) {
        _dragDistance = widget.triggerThreshold * 1.5;
      }
    });

    final progress = (_dragDistance / widget.triggerThreshold).clamp(0.0, 1.0);
    _controller.value = progress;
  }

  void _handlePanEnd(DragEndDetails details) {
    if (_isRefreshing) return;

    if (_dragDistance >= widget.triggerThreshold) {
      _triggerRefresh();
    } else {
      _resetIndicator();
    }
  }

  Future<void> _triggerRefresh() async {
    setState(() {
      _isRefreshing = true;
    });

    try {
      await widget.onRefresh();
    } finally {
      setState(() {
        _isRefreshing = false;
      });
      _resetIndicator();
    }
  }

  void _resetIndicator() {
    setState(() {
      _dragDistance = 0.0;
    });
    _controller.reset();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      child: Stack(
        children: [
          // Main content
          widget.child,

          // Refresh indicator
          if (_dragDistance > 0 || _isRefreshing)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: _dragDistance,
                color: colors.primaryBackground.withOpacity(0.9),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isRefreshing)
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            widget.indicatorColor ?? colors.info,
                          ),
                        )
                      else
                        AnimatedBuilder(
                          animation: _animation,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: _animation.value * 2 * 3.14159,
                              child: Icon(
                                Icons.refresh,
                                color: widget.indicatorColor ?? colors.info,
                                size: 24,
                              ),
                            );
                          },
                        ),

                      const SizedBox(height: 8),

                      Text(
                        _isRefreshing
                            ? 'Yangilanmoqda...'
                            : (_dragDistance >= widget.triggerThreshold
                            ? 'Yangilash uchun qo\'yib yuboring'
                            : (widget.refreshText ?? 'Yangilash uchun torting')),
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}