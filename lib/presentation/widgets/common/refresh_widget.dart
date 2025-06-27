import 'package:flutter/material.dart';

import '../../../core/themes/app_themes.dart';

/// Custom refresh widget with theming support
class CustomRefreshWidget extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final String? loadingText;
  final String? pullToRefreshText;
  final String? releaseToRefreshText;
  final Color? backgroundColor;
  final Color? color;
  final double displacement;
  final RefreshIndicatorTriggerMode triggerMode;

  const CustomRefreshWidget({
    Key? key,
    required this.child,
    required this.onRefresh,
    this.loadingText,
    this.pullToRefreshText,
    this.releaseToRefreshText,
    this.backgroundColor,
    this.color,
    this.displacement = 40.0,
    this.triggerMode = RefreshIndicatorTriggerMode.onEdge,
  }) : super(key: key);

  @override
  State<CustomRefreshWidget> createState() => _CustomRefreshWidgetState();
}

class _CustomRefreshWidgetState extends State<CustomRefreshWidget> {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      backgroundColor: widget.backgroundColor ?? colors.cardBackground,
      color: widget.color ?? colors.info,
      displacement: widget.displacement,
      triggerMode: widget.triggerMode,
      child: widget.child,
    );
  }
}

/// Custom refresh indicator with Uzbek text
class UzbekRefreshIndicator extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Color? backgroundColor;
  final Color? color;

  const UzbekRefreshIndicator({
    Key? key,
    required this.child,
    required this.onRefresh,
    this.backgroundColor,
    this.color,
  }) : super(key: key);

  @override
  State<UzbekRefreshIndicator> createState() => _UzbekRefreshIndicatorState();
}

class _UzbekRefreshIndicatorState extends State<UzbekRefreshIndicator>
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

/// Pull to refresh with custom animation
class AnimatedRefreshWidget extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Widget? refreshIndicator;
  final double threshold;
  final Duration animationDuration;

  const AnimatedRefreshWidget({
    Key? key,
    required this.child,
    required this.onRefresh,
    this.refreshIndicator,
    this.threshold = 100.0,
    this.animationDuration = const Duration(milliseconds: 300),
  }) : super(key: key);

  @override
  State<AnimatedRefreshWidget> createState() => _AnimatedRefreshWidgetState();
}

class _AnimatedRefreshWidgetState extends State<AnimatedRefreshWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  bool _isRefreshing = false;
  double _pullDistance = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
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

    _controller.repeat();

    try {
      await widget.onRefresh();
    } finally {
      _controller.stop();
      _controller.reset();
      setState(() {
        _isRefreshing = false;
        _pullDistance = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      backgroundColor: colors.cardBackground,
      color: colors.info,
      child: widget.child,
    );
  }
}

/// Manual refresh button widget
class RefreshButton extends StatefulWidget {
  final Future<void> Function() onRefresh;
  final String? text;
  final IconData? icon;
  final ButtonStyle? style;
  final bool isLoading;

  const RefreshButton({
    Key? key,
    required this.onRefresh,
    this.text,
    this.icon,
    this.style,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<RefreshButton> createState() => _RefreshButtonState();
}

class _RefreshButtonState extends State<RefreshButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    if (_isRefreshing || widget.isLoading) return;

    setState(() {
      _isRefreshing = true;
    });

    _controller.repeat();

    try {
      await widget.onRefresh();
    } finally {
      _controller.stop();
      _controller.reset();
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isLoading = _isRefreshing || widget.isLoading;

    return ElevatedButton.icon(
      onPressed: isLoading ? null : _handleRefresh,
      style:
          widget.style ??
          ElevatedButton.styleFrom(
            backgroundColor: colors.info,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
      icon: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.rotate(
            angle: _controller.value * 2 * 3.14159,
            child: Icon(widget.icon ?? Icons.refresh, size: 20),
          );
        },
      ),
      label: Text(widget.text ?? 'Yangilash'),
    );
  }
}

/// Floating refresh button
class FloatingRefreshButton extends StatefulWidget {
  final Future<void> Function() onRefresh;
  final bool isVisible;
  final Alignment alignment;
  final EdgeInsets margin;

  const FloatingRefreshButton({
    Key? key,
    required this.onRefresh,
    this.isVisible = true,
    this.alignment = Alignment.bottomRight,
    this.margin = const EdgeInsets.all(16),
  }) : super(key: key);

  @override
  State<FloatingRefreshButton> createState() => _FloatingRefreshButtonState();
}

class _FloatingRefreshButtonState extends State<FloatingRefreshButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
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

    _controller.repeat();

    try {
      await widget.onRefresh();
    } finally {
      _controller.stop();
      _controller.reset();
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AnimatedOpacity(
      opacity: widget.isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Align(
        alignment: widget.alignment,
        child: Container(
          margin: widget.margin,
          child: FloatingActionButton(
            onPressed: _isRefreshing ? null : _handleRefresh,
            backgroundColor: colors.info,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _controller.value * 2 * 3.14159,
                  child: const Icon(Icons.refresh, color: Colors.white),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Refresh header for custom scroll views
class CustomRefreshHeader extends StatefulWidget {
  final double height;
  final Widget? child;
  final RefreshHeaderState state;

  const CustomRefreshHeader({
    Key? key,
    this.height = 60.0,
    this.child,
    required this.state,
  }) : super(key: key);

  @override
  State<CustomRefreshHeader> createState() => _CustomRefreshHeaderState();
}

class _CustomRefreshHeaderState extends State<CustomRefreshHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(CustomRefreshHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state == RefreshHeaderState.refreshing) {
      _controller.repeat();
    } else {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      height: widget.height,
      alignment: Alignment.center,
      child: widget.child ?? _buildDefaultHeader(colors),
    );
  }

  Widget _buildDefaultHeader(AppThemeColors colors) {
    String text;
    Widget icon;

    switch (widget.state) {
      case RefreshHeaderState.pullToRefresh:
        text = 'Yangilash uchun torting';
        icon = Icon(Icons.arrow_downward, color: colors.secondaryText);
        break;
      case RefreshHeaderState.releaseToRefresh:
        text = 'Yangilash uchun qo\'yib yuboring';
        icon = Transform.rotate(
          angle: 3.14159,
          child: Icon(Icons.arrow_downward, color: colors.info),
        );
        break;
      case RefreshHeaderState.refreshing:
        text = 'Yangilanmoqda...';
        icon = AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.rotate(
              angle: _controller.value * 2 * 3.14159,
              child: Icon(Icons.refresh, color: colors.info),
            );
          },
        );
        break;
      case RefreshHeaderState.completed:
        text = 'Yangilandi';
        icon = Icon(Icons.check, color: colors.success);
        break;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        icon,
        const SizedBox(width: 8),
        Text(text, style: TextStyle(color: colors.secondaryText, fontSize: 14)),
      ],
    );
  }
}

/// Refresh header states
enum RefreshHeaderState {
  pullToRefresh,
  releaseToRefresh,
  refreshing,
  completed,
}

/// Smart refresh widget with auto-refresh capability
class SmartRefreshWidget extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Duration autoRefreshInterval;
  final bool enableAutoRefresh;
  final bool enablePullToRefresh;

  const SmartRefreshWidget({
    Key? key,
    required this.child,
    required this.onRefresh,
    this.autoRefreshInterval = const Duration(minutes: 5),
    this.enableAutoRefresh = false,
    this.enablePullToRefresh = true,
  }) : super(key: key);

  @override
  State<SmartRefreshWidget> createState() => _SmartRefreshWidgetState();
}

class _SmartRefreshWidgetState extends State<SmartRefreshWidget> {
  DateTime? _lastRefresh;

  @override
  void initState() {
    super.initState();
    if (widget.enableAutoRefresh) {
      _startAutoRefresh();
    }
  }

  void _startAutoRefresh() {
    Future.doWhile(() async {
      await Future.delayed(widget.autoRefreshInterval);

      if (mounted && widget.enableAutoRefresh) {
        final now = DateTime.now();
        if (_lastRefresh == null ||
            now.difference(_lastRefresh!) >= widget.autoRefreshInterval) {
          await _handleRefresh();
        }
        return true;
      }
      return false;
    });
  }

  Future<void> _handleRefresh() async {
    _lastRefresh = DateTime.now();
    await widget.onRefresh();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.enablePullToRefresh) {
      return CustomRefreshWidget(
        onRefresh: _handleRefresh,
        child: widget.child,
      );
    }

    return widget.child;
  }
}

/// Utility class for refresh-related operations
class RefreshUtils {
  /// Show refresh success snackbar
  static void showRefreshSuccess(BuildContext context, {String? message}) {
    final colors = context.colors;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: colors.success, size: 20),
            const SizedBox(width: 8),
            Text(message ?? 'Ma\'lumotlar yangilandi'),
          ],
        ),
        backgroundColor: colors.cardBackground,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  /// Show refresh error snackbar
  static void showRefreshError(BuildContext context, {String? message}) {
    final colors = context.colors;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: colors.error, size: 20),
            const SizedBox(width: 8),
            Text(message ?? 'Yangilashda xatolik yuz berdi'),
          ],
        ),
        backgroundColor: colors.cardBackground,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        action: SnackBarAction(
          label: 'Qayta urinish',
          textColor: colors.info,
          onPressed: () {
            // Handle retry action
          },
        ),
      ),
    );
  }
}
