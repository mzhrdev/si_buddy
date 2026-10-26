import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import 'library_documents.dart';

/// White format badge box with the file format label, e.g. "PDF".
class _FormatBadge extends StatelessWidget {
  const _FormatBadge({
    required this.format,
    required this.width,
    required this.height,
  });

  final String format;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(format, style: AppTextStyles.badge),
    );
  }
}

/// Document card for the library list: a 92px bordered row with the
/// format badge, title, meta and subject lines, and an overflow icon.
class DocumentListCard extends StatelessWidget {
  const DocumentListCard({
    required this.document,
    required this.onTap,
    required this.onMore,
    super.key,
  });

  final LibraryDocumentItem document;
  final VoidCallback onTap;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          height: 92,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              _FormatBadge(format: document.format, width: 36, height: 42),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.title,
                      style: AppTextStyles.itemTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      document.listMeta,
                      style: AppTextStyles.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      document.subject,
                      style: AppTextStyles.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: onMore,
                child: SvgPicture.asset(
                  'assets/icons/figma/ellipsis_vertical.svg',
                  width: 14,
                  height: 14,
                  colorFilter: const ColorFilter.mode(
                    AppColors.navInactive,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Document card for the library grid: a 200px bordered tile with the
/// format badge and overflow icon on top, the two-line title, date and
/// subject lines, and the associated study-sets line.
class DocumentGridCard extends StatelessWidget {
  const DocumentGridCard({
    required this.document,
    required this.onTap,
    required this.onMore,
    super.key,
  });

  final LibraryDocumentItem document;
  final VoidCallback onTap;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          height: 200,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _FormatBadge(format: document.format, width: 42, height: 30),
                  InkWell(
                    onTap: onMore,
                    child: SvgPicture.asset(
                      'assets/icons/figma/ellipsis_vertical.svg',
                      width: 16,
                      height: 16,
                      colorFilter: const ColorFilter.mode(
                        AppColors.navInactive,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 9),
              SizedBox(
                height: 34,
                child: Text(
                  document.title,
                  style: AppTextStyles.itemTitle.copyWith(
                    fontSize: 12,
                    height: 16 / 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 9),
              Text(document.date, style: AppTextStyles.caption),
              const SizedBox(height: 9),
              Text(
                document.subject,
                style: AppTextStyles.caption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 9),
              Row(
                children: [
                  SvgPicture.asset(
                    'assets/icons/figma/layers.svg',
                    width: 13,
                    height: 13,
                    colorFilter: const ColorFilter.mode(
                      AppColors.primary,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(document.studySets, style: AppTextStyles.captionAccent),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
