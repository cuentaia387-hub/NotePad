import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Widget para mostrar notificaciones tipo Toast con efecto glassmorphism.
/// Se usa en lugar del SnackBar por defecto para mantener el diseño de la app.
class GlassToast extends StatelessWidget {
  final String message;
  final IconData? icon;
  final Color? iconColor;

  const GlassToast({
    Key? key,
    required this.message,
    this.icon,
    this.iconColor,
  }) : super(key: key);

  static void show(
    BuildContext context, {
    required String message,
    IconData icon = Icons.check_circle_outline,
    Color iconColor = AppTheme.neonAccent,
    Duration duration = const Duration(seconds: 2),
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => _GlassToastAnimation(
        message: message,
        icon: icon,
        iconColor: iconColor,
      ),
    );

    overlay.insert(entry);
    Future.delayed(duration, () {
      if (entry.mounted) entry.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon ?? Icons.check_circle_outline,
                  color: iconColor ?? AppTheme.neonAccent, size: 18),
              const SizedBox(width: 10),
              Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassToastAnimation extends StatefulWidget {
  final String message;
  final IconData icon;
  final Color iconColor;

  const _GlassToastAnimation({
    required this.message,
    required this.icon,
    required this.iconColor,
  });

  @override
  State<_GlassToastAnimation> createState() => _GlassToastAnimationState();
}

class _GlassToastAnimationState extends State<_GlassToastAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    _opacityAnimation =
        Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
            .animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 40,
      left: 0,
      right: 0,
      child: Center(
        child: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: Material(
              color: Colors.transparent,
              child: GlassToast(
                message: widget.message,
                icon: widget.icon,
                iconColor: widget.iconColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
