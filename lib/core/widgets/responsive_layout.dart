import 'dart:math' as math;

import 'package:flutter/material.dart';

class ResponsiveLayout {
  const ResponsiveLayout._(this.width);

  final double width;

  static ResponsiveLayout of(BuildContext context) {
    return ResponsiveLayout._(MediaQuery.sizeOf(context).width);
  }

  bool get isSmallMobile => width < 360;
  bool get isMobile => width < 600;
  bool get isTablet => width >= 600 && width < 1024;

  double get scale {
    if (isSmallMobile) {
      return 0.9;
    }
    if (isTablet) {
      return 1.08;
    }
    return 1;
  }

  double size(double base, {double? mobile, double? tablet}) {
    if (isSmallMobile && mobile != null) {
      return mobile;
    }
    if (isTablet && tablet != null) {
      return tablet;
    }
    return base;
  }

  double scaled(double base, {double min = 0}) {
    final value = base * scale;
    if (min > 0) {
      return math.max(min, value);
    }
    return value;
  }

  double get pagePadding => size(20, mobile: 14, tablet: 24);
  double get sectionGap => size(24, mobile: 18, tablet: 28);
  double get itemGap => size(16, mobile: 12, tablet: 20);
  double get chipBarHeight => size(60, mobile: 54, tablet: 64);
  double get buttonHeight => size(52, mobile: 48, tablet: 56);
  double get compactButtonHeight => size(50, mobile: 46, tablet: 54);
  double get heroIconSize => size(72, mobile: 60, tablet: 80);
  double get headlineSize => size(28, mobile: 24, tablet: 30);
  double get titleSize => size(26, mobile: 22, tablet: 28);
  double get helperTextSize => size(12, mobile: 11, tablet: 13);
  double get contentMaxWidth => isTablet ? 760 : 640;
  double get dashboardContentMaxWidth => width >= 1440
      ? 1320
      : width >= 1200
      ? 1180
      : width >= 960
      ? 980
      : width >= 600
      ? 760
      : 520;
  double get detailLabelWidth => size(120, mobile: 96, tablet: 140);
  double get metricGridSpacing => size(14, mobile: 10, tablet: 16);
  int get dashboardGridCount => width >= 420 ? 2 : 1;
  double get dashboardMetricHeight => width >= 1440
      ? 188
      : width >= 960
      ? 182
      : width >= 600
      ? 176
      : 170;
}

extension ResponsiveLayoutContext on BuildContext {
  ResponsiveLayout get responsive => ResponsiveLayout.of(this);
}

class ResponsiveContent extends StatelessWidget {
  const ResponsiveContent({
    super.key,
    required this.child,
    this.alignment = Alignment.topCenter,
  });

  final Widget child;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: responsive.contentMaxWidth),
        child: child,
      ),
    );
  }
}
