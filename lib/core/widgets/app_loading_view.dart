import 'package:flutter/material.dart';
import 'package:insurance_reminders/core/widgets/responsive_layout.dart';

class AppLoadingView extends StatelessWidget {
  const AppLoadingView({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final responsive = context.responsive;

    return ResponsiveContent(
      alignment: Alignment.center,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: responsive.scaled(28, min: 24),
              height: responsive.scaled(28, min: 24),
              child: const CircularProgressIndicator(),
            ),
            if (message != null) ...[
              SizedBox(height: responsive.scaled(12, min: 10)),
              Text(
                message!,
                style: textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
