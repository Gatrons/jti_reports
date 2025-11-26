import 'package:flutter/material.dart';

class LoadingButton extends StatelessWidget {
  final bool isLoading;
  final String text;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final double height;
  final Widget? icon;
  final bool isGoogleButton;

  const LoadingButton({
    super.key,
    required this.isLoading,
    required this.text,
    required this.onPressed,
    this.backgroundColor = Colors.deepPurple,
    this.textColor = Colors.white,
    this.height = 50,
    this.icon,
    this.isGoogleButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 5,
          shadowColor: backgroundColor.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          side: isGoogleButton ? BorderSide(color: Colors.grey[300]!) : null,
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(textColor),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[icon!, const SizedBox(width: 12)],
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
