import 'package:flutter/material.dart';

import 'breakpoints.dart';

class AdaptiveScaffold extends StatelessWidget {
  const AdaptiveScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.maxBodyWidth,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final double? maxBodyWidth;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = maxBodyWidth ??
              (constraints.maxWidth >= Breakpoints.medium ? 840 : double.infinity);
          final horizontalPadding = constraints.maxWidth >= Breakpoints.medium ? 32.0 : 16.0;
          return SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: body,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
