import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NeonFab extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;

  const NeonFab({
    Key? key,
    required this.onPressed,
    this.icon = Icons.add,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.pureBlack,
          border: Border.all(
            color: AppTheme.neonAccent,
            width: 2.0,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.neonAccent.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 15,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: AppTheme.neonAccent,
          size: 32,
        ),
      ),
    );
  }
}
