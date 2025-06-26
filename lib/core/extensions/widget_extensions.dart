

// ===================== WIDGET EXTENSIONS =====================

import 'package:flutter/material.dart';

extension WidgetExtensions on Widget {
  /// Add padding
  Widget paddingAll(double padding) => Padding(
    padding: EdgeInsets.all(padding),
    child: this,
  );

  /// Add symmetric padding
  Widget paddingSymmetric({double horizontal = 0, double vertical = 0}) => Padding(
    padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
    child: this,
  );

  /// Add only padding
  Widget paddingOnly({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) => Padding(
    padding: EdgeInsets.only(left: left, top: top, right: right, bottom: bottom),
    child: this,
  );

  /// Add margin
  Widget marginAll(double margin) => Container(
    margin: EdgeInsets.all(margin),
    child: this,
  );

  /// Add symmetric margin
  Widget marginSymmetric({double horizontal = 0, double vertical = 0}) => Container(
    margin: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
    child: this,
  );

  /// Add only margin
  Widget marginOnly({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) => Container(
    margin: EdgeInsets.only(left: left, top: top, right: right, bottom: bottom),
    child: this,
  );

  /// Add border radius
  Widget borderRadius(double radius) => ClipRRect(
    borderRadius: BorderRadius.circular(radius),
    child: this,
  );

  /// Add specific border radius
  Widget borderRadiusOnly({
    double topLeft = 0,
    double topRight = 0,
    double bottomLeft = 0,
    double bottomRight = 0,
  }) => ClipRRect(
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(topLeft),
      topRight: Radius.circular(topRight),
      bottomLeft: Radius.circular(bottomLeft),
      bottomRight: Radius.circular(bottomRight),
    ),
    child: this,
  );

  /// Add elevation with shadow
  Widget elevation(double elevation, {Color? shadowColor}) => Material(
    elevation: elevation,
    shadowColor: shadowColor,
    borderRadius: BorderRadius.circular(0),
    child: this,
  );

  /// Add card wrapper
  Widget card({
    double radius = 8,
    double elevation = 2,
    EdgeInsets? padding,
    Color? color,
  }) => Card(
    elevation: elevation,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
    ),
    color: color,
    child: padding != null ? Padding(padding: padding, child: this) : this,
  );

  /// Add gesture detector with tap
  Widget onTap(VoidCallback? onTap, {HitTestBehavior? behavior}) => GestureDetector(
    onTap: onTap,
    behavior: behavior ?? HitTestBehavior.opaque,
    child: this,
  );

  /// Add inkwell with splash effect
  Widget inkWell({
    VoidCallback? onTap,
    double? radius,
    Color? splashColor,
    Color? highlightColor,
  }) => Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: radius != null ? BorderRadius.circular(radius) : null,
      splashColor: splashColor,
      highlightColor: highlightColor,
      child: this,
    ),
  );

  /// Add flexible
  Widget flexible({int flex = 1, FlexFit fit = FlexFit.loose}) => Flexible(
    flex: flex,
    fit: fit,
    child: this,
  );

  /// Add expanded
  Widget expanded({int flex = 1}) => Expanded(flex: flex, child: this);

  /// Add center
  Widget center() => Center(child: this);

  /// Add alignment
  Widget align(Alignment alignment) => Align(alignment: alignment, child: this);

  /// Add positioned
  Widget positioned({
    double? left,
    double? top,
    double? right,
    double? bottom,
    double? width,
    double? height,
  }) => Positioned(
    left: left,
    top: top,
    right: right,
    bottom: bottom,
    width: width,
    height: height,
    child: this,
  );

  /// Add sized box
  Widget sized({double? width, double? height}) => SizedBox(
    width: width,
    height: height,
    child: this,
  );

  /// Add constrained box
  Widget constrained({
    double? minWidth,
    double? maxWidth,
    double? minHeight,
    double? maxHeight,
  }) => ConstrainedBox(
    constraints: BoxConstraints(
      minWidth: minWidth ?? 0.0,
      maxWidth: maxWidth ?? double.infinity,
      minHeight: minHeight ?? 0.0,
      maxHeight: maxHeight ?? double.infinity,
    ),
    child: this,
  );

  /// Add opacity
  Widget opacity(double opacity) => Opacity(opacity: opacity, child: this);

  /// Add visibility
  Widget visible(bool visible, {Widget? replacement}) => Visibility(
    visible: visible,
    replacement: replacement ?? const SizedBox.shrink(),
    child: this,
  );

  /// Add conditional widget
  Widget when(bool condition, {Widget Function(Widget)? then, Widget? otherwise}) {
    if (condition) {
      return then?.call(this) ?? this;
    } else {
      return otherwise ?? this;
    }
  }

  /// Add scrollable
  Widget scrollable({
    Axis scrollDirection = Axis.vertical,
    ScrollPhysics? physics,
    bool shrinkWrap = false,
  }) => SingleChildScrollView(
    scrollDirection: scrollDirection,
    physics: physics,
    child: this,
  );

  /// Add loading overlay
  Widget loading(bool isLoading, {Widget? loadingWidget}) => Stack(
    children: [
      this,
      if (isLoading)
        Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.3),
            child: loadingWidget ?? const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
    ],
  );

  /// Add shimmer effect placeholder
  Widget shimmer({
    Color? baseColor,
    Color? highlightColor,
    Duration duration = const Duration(milliseconds: 1500),
  }) => Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          baseColor ?? Colors.grey[300]!,
          highlightColor ?? Colors.grey[100]!,
          baseColor ?? Colors.grey[300]!,
        ],
        stops: const [0.0, 0.5, 1.0],
      ),
    ),
    child: this,
  );

  /// Add hero animation
  Widget hero(String tag) => Hero(tag: tag, child: this);

  /// Add fade transition
  Widget fadeTransition(Animation<double> animation) => FadeTransition(
    opacity: animation,
    child: this,
  );

  /// Add scale transition
  Widget scaleTransition(Animation<double> animation) => ScaleTransition(
    scale: animation,
    child: this,
  );

  /// Add slide transition
  Widget slideTransition(Animation<Offset> animation) => SlideTransition(
    position: animation,
    child: this,
  );
}

// ===================== LIST EXTENSIONS =====================

extension ListExtensions<T> on List<T> {
  /// Get element at index safely
  T? elementAtOrNull(int index) {
    if (index >= 0 && index < length) {
      return elementAt(index);
    }
    return null;
  }

  /// Add item if not exists
  void addIfNotExists(T item) {
    if (!contains(item)) {
      add(item);
    }
  }

  /// Remove item if exists
  bool removeIfExists(T item) {
    if (contains(item)) {
      remove(item);
      return true;
    }
    return false;
  }

  /// Get unique items
  List<T> get unique => toSet().toList();

  /// Chunk list into smaller lists
  List<List<T>> chunk(int size) {
    final chunks = <List<T>>[];
    for (int i = 0; i < length; i += size) {
      chunks.add(sublist(i, i + size > length ? length : i + size));
    }
    return chunks;
  }
}

// ===================== NUMBER EXTENSIONS =====================

extension NumExtensions on num {
  /// Format as Uzbek number (1 000 000)
  String get uzbekFormat {
    return toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match match) => '${match[1]} ',
    );
  }

  /// Format as percentage
  String get percentage => '${(this * 100).toStringAsFixed(1)}%';

  /// Clamp between min and max
  num clampTo(num min, num max) => clamp(min, max);

  /// Check if number is between two values
  bool isBetween(num min, num max) => this >= min && this <= max;
}