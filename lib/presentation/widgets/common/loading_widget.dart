import 'package:flutter/material.dart';
import '../../../core/themes/app_themes.dart';

class LoadingWidget extends StatelessWidget {
  final double size;
  final Color? color;
  final String? message;

  const LoadingWidget({
    super.key,
    this.size = 40,
    this.color,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: size > 30 ? 3 : 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? colors.info,
            ),
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            style: TextStyle(
              fontSize: 14,
              color: colors.secondaryText,
            ),
          ),
        ],
      ],
    );
  }
}

// Static factory methods for common loading scenarios
class LoadingWidgets {
  static Widget button({double size = 20, Color? color}) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? Colors.white,
        ),
      ),
    );
  }

  static Widget page({String? message}) {
    return Builder(
      builder: (context) {
        final colors = context.colors;
        return Center(
          child: LoadingWidget(
            size: 50,
            color: colors.info,
            message: message ?? 'Yuklanmoqda...',
          ),
        );
      },
    );
  }

  static Widget overlay({String? message}) {
    return Builder(
      builder: (context) {
        final colors = context.colors;
        return Container(
          color: Colors.black54,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colors.cardBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: LoadingWidget(
                size: 40,
                color: colors.info,
                message: message ?? 'Yuklanmoqda...',
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget list() {
    return Builder(
      builder: (context) {
        final colors = context.colors;
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: LoadingWidget(
              size: 30,
              color: colors.info,
              message: 'Ma\'lumotlar yuklanmoqda...',
            ),
          ),
        );
      },
    );
  }
}

// Shimmer loading effect for skeleton screens
class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerLoading({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final baseColor = widget.baseColor ?? colors.secondaryBackground;
    final highlightColor = widget.highlightColor ?? colors.cardBackground;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ].map((stop) => stop.clamp(0.0, 1.0)).toList(),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

// Simple skeleton containers for shimmer loading
class SkeletonContainer extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const SkeletonContainer({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: colors.secondaryBackground,
        borderRadius: borderRadius ?? BorderRadius.circular(4),
      ),
    );
  }
}