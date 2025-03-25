import 'package:flutter/material.dart';
import '../../core/theme.dart';

class BreadcrumbNavigation extends StatelessWidget {
  final List<BreadcrumbItem> items;

  const BreadcrumbNavigation({
    Key? key,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(items.length * 2 - 1, (index) {
          if (index.isEven) {
            final itemIndex = index ~/ 2;
            return items[itemIndex];
          } else {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Icon(
                Icons.chevron_right,
                size: 20,
                color: AppTheme.secondaryTextColor,
              ),
            );
          }
        }),
      ),
    );
  }
}

class BreadcrumbItem extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;

  const BreadcrumbItem({
    Key? key,
    required this.label,
    this.icon,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isClickable = onTap != null;
    final isCurrentPage = !isClickable;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isCurrentPage ? AppTheme.primaryColor : AppTheme.secondaryTextColor,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                color: isCurrentPage ? AppTheme.primaryColor : AppTheme.secondaryTextColor,
                fontWeight: isCurrentPage ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 