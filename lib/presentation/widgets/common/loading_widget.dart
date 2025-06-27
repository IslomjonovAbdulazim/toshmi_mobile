import 'package:flutter/material.dart';
import 'package:toshmi_mobile/core/themes/app_themes.dart';

/// Custom loading widget with theming support
class CustomLoadingWidget extends StatelessWidget {
  final String? message;
  final double size;
  final Color? color;
  final double strokeWidth;
  final bool showMessage;
  final EdgeInsets padding;
  final LoadingType type;

  const CustomLoadingWidget({
    Key? key,
    this.message,
    this.size = 24,
    this.color,
    this.strokeWidth = 3,
    this.showMessage = false,
    this.padding = const EdgeInsets.all(16),
    this.type = LoadingType.circular,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final loadingColor = color ?? colors.info;

    Widget loadingIndicator;

    switch (type) {
      case LoadingType.circular:
        loadingIndicator = SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: strokeWidth,
            valueColor: AlwaysStoppedAnimation<Color>(loadingColor),
          ),
        );
        break;
      case LoadingType.linear:
        loadingIndicator = SizedBox(
          width: size * 3,
          child: LinearProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(loadingColor),
            backgroundColor: loadingColor.withOpacity(0.2),
          ),
        );
        break;
      case LoadingType.dots:
        loadingIndicator = DotsLoadingIndicator(
          size: size / 3,
          color: loadingColor,
        );
        break;
      case LoadingType.pulse:
        loadingIndicator = PulseLoadingIndicator(
          size: size,
          color: loadingColor,
        );
        break;
      case LoadingType.wave:
        loadingIndicator = WaveLoadingIndicator(
          size: size,
          color: loadingColor,
        );
        break;
    }

    if (showMessage && message != null) {
      return Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            loadingIndicator,
            const SizedBox(height: 16),
            Text(
              message!,
              style: TextStyle(
                fontSize: 14,
                color: colors.secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: padding,
      child: loadingIndicator,
    );
  }
}

/// Loading types enumeration
enum LoadingType {
  circular,
  linear,
  dots,
  pulse,
  wave,
}

/// Full screen loading overlay
class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? message;
  final Color? backgroundColor;
  final LoadingType type;

  const LoadingOverlay({
    Key? key,
    required this.child,
    required this.isLoading,
    this.message,
    this.backgroundColor,
    this.type = LoadingType.circular,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: backgroundColor ?? Colors.black.withOpacity(0.5),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: context.colors.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CustomLoadingWidget(
                  message: message,
                  showMessage: message != null,
                  type: type,
                  size: 48,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Shimmer loading effect
class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration duration;

  const ShimmerLoading({
    Key? key,
    required this.child,
    this.baseColor,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 1500),
  }) : super(key: key);

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
      duration: widget.duration,
      vsync: this,
    )..repeat();

    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
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
              ],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

/// Dots loading indicator
class DotsLoadingIndicator extends StatefulWidget {
  final double size;
  final Color color;
  final Duration duration;

  const DotsLoadingIndicator({
    Key? key,
    this.size = 8,
    required this.color,
    this.duration = const Duration(milliseconds: 800),
  }) : super(key: key);

  @override
  State<DotsLoadingIndicator> createState() => _DotsLoadingIndicatorState();
}

class _DotsLoadingIndicatorState extends State<DotsLoadingIndicator>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (index) {
      return AnimationController(
        duration: widget.duration,
        vsync: this,
      );
    });

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0.4, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();

    _startAnimations();
  }

  void _startAnimations() async {
    for (int i = 0; i < _controllers.length; i++) {
      await Future.delayed(Duration(milliseconds: i * 200));
      _controllers[i].repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: widget.size * 0.2),
              child: Transform.scale(
                scale: _animations[index].value,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

/// Pulse loading indicator
class PulseLoadingIndicator extends StatefulWidget {
  final double size;
  final Color color;
  final Duration duration;

  const PulseLoadingIndicator({
    Key? key,
    this.size = 24,
    required this.color,
    this.duration = const Duration(milliseconds: 1000),
  }) : super(key: key);

  @override
  State<PulseLoadingIndicator> createState() => _PulseLoadingIndicatorState();
}

class _PulseLoadingIndicatorState extends State<PulseLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: widget.color,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Wave loading indicator
class WaveLoadingIndicator extends StatefulWidget {
  final double size;
  final Color color;
  final Duration duration;

  const WaveLoadingIndicator({
    Key? key,
    this.size = 24,
    required this.color,
    this.duration = const Duration(milliseconds: 1200),
  }) : super(key: key);

  @override
  State<WaveLoadingIndicator> createState() => _WaveLoadingIndicatorState();
}

class _WaveLoadingIndicatorState extends State<WaveLoadingIndicator>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(4, (index) {
      return AnimationController(
        duration: widget.duration,
        vsync: this,
      );
    });

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();

    _startAnimations();
  }

  void _startAnimations() async {
    for (int i = 0; i < _controllers.length; i++) {
      await Future.delayed(Duration(milliseconds: i * 100));
      _controllers[i].repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(4, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 1),
              width: widget.size / 6,
              height: widget.size * _animations[index].value * 0.5 + widget.size * 0.3,
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(widget.size / 12),
              ),
            );
          },
        );
      }),
    );
  }
}

/// Predefined loading widgets for common scenarios
class LoadingWidgets {
  /// Page loading
  static Widget page({String? message}) {
    return Center(
      child: CustomLoadingWidget(
        message: message ?? 'Yuklanmoqda...',
        showMessage: true,
        size: 48,
        type: LoadingType.circular,
      ),
    );
  }

  /// Button loading
  static Widget button({double size = 20}) {
    return CustomLoadingWidget(
      size: size,
      strokeWidth: 2,
      color: Colors.white,
    );
  }

  /// Card loading (shimmer)
  static Widget card({
    double height = 120,
    double width = double.infinity,
  }) {
    return ShimmerLoading(
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  /// List item loading (shimmer)
  static Widget listItem() {
    return ShimmerLoading(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16,
                    width: double.infinity,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 12,
                    width: 200,
                    color: Colors.grey[300],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Text loading (shimmer)
  static Widget text({
    double width = 100,
    double height = 16,
  }) {
    return ShimmerLoading(
      child: Container(
        width: width,
        height: height,
        color: Colors.grey[300],
      ),
    );
  }

  /// Image loading
  static Widget image({
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
  }) {
    return ShimmerLoading(
      child: Container(
        width: width,
        height: height,
        color: Colors.grey[300],
      ),
    );
  }

  /// Inline loading for small spaces
  static Widget inline({String? text}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CustomLoadingWidget(size: 16, strokeWidth: 2),
        if (text != null) ...[
          const SizedBox(width: 8),
          Text(text),
        ],
      ],
    );
  }

  /// Grid loading
  static Widget grid({
    int itemCount = 6,
    double aspectRatio = 1.0,
  }) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: aspectRatio,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) => LoadingWidgets.card(),
    );
  }

  /// List loading
  static Widget list({int itemCount = 5}) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, index) => LoadingWidgets.listItem(),
    );
  }
}