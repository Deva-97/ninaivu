import 'package:flutter/material.dart';
import 'package:ninaivu/core/widgets/responsive_layout.dart';

import 'app_button.dart';

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.buttonLabel,
    this.onPressed,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? buttonLabel;
  final VoidCallback? onPressed;

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
              Container(
                padding: EdgeInsets.all(responsive.scaled(18, min: 16)),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  icon,
                  size: responsive.scaled(34, min: 30),
                  color: theme.colorScheme.primary,
                ),
              ),
              SizedBox(height: responsive.itemGap),
              Text(
                title,
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: responsive.scaled(8, min: 6)),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              if (buttonLabel != null && onPressed != null) ...[
                SizedBox(height: responsive.scaled(20, min: 16)),
                AppButton(label: buttonLabel!, onPressed: onPressed),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
