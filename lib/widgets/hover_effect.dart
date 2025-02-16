import 'package:flutter/material.dart';

class HoverEffect extends StatefulWidget {
  final Widget child;
  final double scale;
  
  const HoverEffect({
    required this.child,
    this.scale = 1.02,
    Key? key,
  }) : super(key: key);

  @override
  State<HoverEffect> createState() => _HoverEffectState();
}

class _HoverEffectState extends State<HoverEffect> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedScale(
        scale: isHovered ? widget.scale : 1.0,
        duration: Duration(milliseconds: 200),
        child: widget.child,
      ),
    );
  }
} 