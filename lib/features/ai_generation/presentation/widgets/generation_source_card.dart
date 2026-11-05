import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../documents/domain/document_models.dart';

/// The source card's metadata line for a real document: subject
/// (when the import flow captured one), formatted size, and page or
/// slide count — e.g. 'Biology · 2.4 MB · 12 pages'.
String generationSourceSubtitle({
  required Document document,
  String? subject,
}) {
  final parts = <String>[
    if (subject != null && subject.isNotEmpty) subject,
    formatFileSize(document.sizeBytes),
    '${document.pageCount} ${document.format.unitLabel}',
  ];
  return parts.join(' · ');
}

/// White bordered card showing the source document for generation:
/// a "PDF" format box, the file name and a metadata line. Shown at
/// the top of every AI generation frame (setup, processing, errors).
///
/// All three fields are nullable: a null title renders the honest
/// "No source document" card instead of the design's sample
/// document; a null subtitle hides the metadata line.
class GenerationSourceCard extends StatelessWidget {
  const GenerationSourceCard({
    super.key,
    this.title,
    this.subtitle,
    this.formatLabel,
  });

  /// File name shown as the card's title.
  final String? title;

  /// Metadata line under the title.
  final String? subtitle;

  /// Short format label inside the file glyph.
  final String? formatLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(formatLabel ?? '–', style: AppTextStyles.badge),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title ?? 'No source document',
                  style: AppTextStyles.itemTitle.copyWith(fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    subtitle!,
                    style: AppTextStyles.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
