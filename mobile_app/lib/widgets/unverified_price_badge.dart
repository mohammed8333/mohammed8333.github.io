import 'package:flutter/material.dart';
import 'package:pizza_awlad_alsheikh/core/constants/app_colors.dart';

class UnverifiedPriceBadge extends StatelessWidget {
  final bool isCompact;
  final String language;

  const UnverifiedPriceBadge({
    super.key,
    this.isCompact = false,
    this.language = 'ar',
  });

  @override
  Widget build(BuildContext context) {
    final text = language == 'ar'
        ? (isCompact ? 'عينة (تتطلب تأكيد الإدارة)' : '⚠️ عينة تجريبية تتطلب تأكيد الإدارة - الأسعار والأحجام قابلة للتعديل')
        : (isCompact ? 'Sample (Unverified)' : '⚠️ Sample Record - Requires Admin Confirmation');

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 12,
        vertical: isCompact ? 3 : 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.unverifiedTagBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.warning.withAlpha(150), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.info_outline,
            size: isCompact ? 13 : 16,
            color: AppColors.unverifiedTagText,
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: isCompact ? 11 : 12,
                fontWeight: FontWeight.w600,
                color: AppColors.unverifiedTagText,
              ),
              maxLines: isCompact ? 1 : 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
