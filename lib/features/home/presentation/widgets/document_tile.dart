import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../domain/home_models.dart';

/// Row for one document in "Recent documents": a flat 54px row with a
/// bottom divider — format badge, title and metadata, and a chevron.
class DocumentTile extends StatelessWidget {
  const DocumentTile({required this.document, required this.onTap, super.key});

  final DocumentSummary document;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: context.appBorder)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: context.appChip,
                  border: Border.all(color: context.appBorder),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  document.format,
                  style: AppTextStyles.badge(context),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.title,
                      style: AppTextStyles.itemTitle(context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      document.details,
                      style: AppTextStyles.caption(context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SvgPicture.asset(
                'assets/svgs/figma/chevron_right.svg',
                width: 16,
                height: 16,
                colorFilter: ColorFilter.mode(
                  context.appMuted,
                  BlendMode.srcIn,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
