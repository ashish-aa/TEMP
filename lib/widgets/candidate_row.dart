import 'package:flutter/material.dart';
import 'status_badge.dart';

class CandidateRow extends StatelessWidget {
  final String name;
  final String email;
  final String position;
  final String location;
  final double rating;
  final CandidateStatus status;
  final int interviewsCount;
  final bool isSelected;
  final ValueChanged<bool?>? onSelect;
  final VoidCallback? onTap;
  final List<Widget>? actions;

  const CandidateRow({
    super.key,
    required this.name,
    required this.email,
    required this.position,
    required this.location,
    required this.rating,
    required this.status,
    required this.interviewsCount,
    this.isSelected = false,
    this.onSelect,
    this.onTap,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: theme.dividerColor)),
        ),
        child: Row(
          children: [
            /// CHECKBOX
            Checkbox(
              value: isSelected,
              onChanged: onSelect,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              activeColor: theme.colorScheme.primary,
            ),

            const SizedBox(width: 12),

            /// NAME + EMAIL
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    email,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            /// POSITION + LOCATION
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    position,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium,
                  ),
                  Text(
                    location,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            /// RATING
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    rating.toStringAsFixed(1),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            /// STATUS
            Expanded(flex: 2, child: StatusBadge(status: status)),

            /// INTERVIEWS COUNT
            Expanded(
              flex: 2,
              child: Text(
                '$interviewsCount interviews',
                style: theme.textTheme.bodyMedium,
              ),
            ),

            /// ACTIONS
            Row(
              mainAxisSize: MainAxisSize.min,
              children:
                  actions ??
                  [
                    IconButton(
                      icon: Icon(
                        Icons.visibility_outlined,
                        size: 20,
                        color: theme.iconTheme.color,
                      ),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.chat_bubble_outline,
                        size: 20,
                        color: theme.iconTheme.color,
                      ),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.more_vert,
                        size: 20,
                        color: theme.iconTheme.color,
                      ),
                      onPressed: () {},
                    ),
                  ],
            ),
          ],
        ),
      ),
    );
  }
}
