import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String name;
  final double radius;
  final Color? backgroundColor;
  final TextStyle? textStyle;

  const UserAvatar({
    super.key,
    required this.name,
    this.radius = 20,
    this.backgroundColor,
    this.textStyle,
  });

  String _getInitials(String name) {
    String trimmedName = name.trim();
    if (trimmedName.isEmpty) return 'U';

    List<String> nameParts = trimmedName.split(RegExp(r'\s+'));
    // Filter out any empty parts that might result from double spaces
    nameParts.removeWhere((part) => part.isEmpty);

    if (nameParts.isEmpty) return 'U';

    try {
      if (nameParts.length > 1) {
        String first = nameParts[0].isNotEmpty ? nameParts[0][0] : '';
        String last = nameParts.last.isNotEmpty ? nameParts.last[0] : '';
        String initials = (first + last).toUpperCase();
        return initials.isNotEmpty ? initials : 'U';
      }
      return nameParts[0].isNotEmpty ? nameParts[0][0].toUpperCase() : 'U';
    } catch (e) {
      return 'U';
    }
  }

  @override
  Widget build(BuildContext context) {
    final initials = _getInitials(name);

    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
      child: Text(
        initials,
        style:
            textStyle ??
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}
