import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

/// AI Model — Delete Model Confirmation, implemented from the Figma
/// frame "SI Buddy · AI Model — Delete Model Confirmation" (5:15515):
/// a confirmation dialog over the dimmed Ready Offline screen.
class DeleteModelConfirmationScreen extends StatelessWidget {
  const DeleteModelConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0x99172033), // Figma: overlay
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.dangerSurface,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: SvgPicture.asset(
                        'assets/icons/figma/trash_2.svg',
                        width: 22,
                        height: 22,
                        colorFilter: const ColorFilter.mode(
                          AppColors.danger,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Delete Model?',
                    style: AppTextStyles.display.copyWith(letterSpacing: -0.48),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Gemma 3 1B IT',
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 20 / 14,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Removing this model frees its storage. Your existing documents and study sets stay intact.',
                    style: AppTextStyles.muted.copyWith(height: 20 / 13),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'To generate new study material later, you’ll need to download the model again using the internet.',
                    style: AppTextStyles.muted.copyWith(height: 20 / 13),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => context.push(AppRoutes.notInstalled),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.danger,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Delete Model'),
                        const SizedBox(width: 12),
                        SvgPicture.asset(
                          'assets/icons/figma/arrow_right.svg',
                          width: 18,
                          height: 18,
                          colorFilter: const ColorFilter.mode(
                            AppColors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () => context.pop(),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(44),
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 20 / 14,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
