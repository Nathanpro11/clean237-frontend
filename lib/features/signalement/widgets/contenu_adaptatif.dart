import 'package:flutter/material.dart';

/// Remplace Padding : contenu centré, largeur max, défilable (clavier, petit écran).
class ContenuAdaptatif extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double largeurMax;

  const ContenuAdaptatif({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.largeurMax = 640,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: largeurMax),
        child: SingleChildScrollView(
          padding: padding,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: child,
        ),
      ),
    );
  }
}
