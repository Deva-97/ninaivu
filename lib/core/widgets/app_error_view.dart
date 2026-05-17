import 'package:flutter/material.dart';
import 'package:ninaivu/core/widgets/responsive_layout.dart';

import 'app_button.dart';

class AppErrorView extends StatelessWidget {
  const AppErrorView({
    super.key,
    required this.title,
    required this.message,
    this.onRetry,
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final responsive = context.responsive;

    return ResponsiveContent(
      alignment: Alignment.center,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(responsive.pagePadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: responsive.scaled(48, min: 40),
                color: theme.colorScheme.error,
              ),
              SizedBox(height: responsive.itemGap),
              Text(
                title,
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: responsive.scaled(8, min: 6)),
              Text(
                message,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              if (onRetry != null) ...[
                SizedBox(height: responsive.scaled(20, min: 16)),
                AppButton(
                  label: 'Retry',
                  onPressed: onRetry,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
