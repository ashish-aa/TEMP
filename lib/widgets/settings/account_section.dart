import 'package:flutter/material.dart';

class AccountSection extends StatelessWidget {
  final String email;
  final VoidCallback onDeleteAccount;

  const AccountSection({
    super.key,
    required this.email,
    required this.onDeleteAccount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Email Address",
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),

          /// EMAIL
          Text(
            email,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),
          Divider(color: theme.dividerColor),

          const SizedBox(height: 8),

          /// DELETE BUTTON
          GestureDetector(
            onTap: onDeleteAccount,
            child: Row(
              children: [
                const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                const SizedBox(width: 6),
                Text(
                  "Delete Account",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
