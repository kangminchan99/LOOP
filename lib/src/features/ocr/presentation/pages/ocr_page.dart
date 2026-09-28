import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loop/l10n/app_localizations.dart';
import 'package:loop/src/core/layout/max_width_container.dart';
import 'package:loop/src/core/network/error/ocr_failure.dart';
import 'package:loop/src/features/ocr/domain/models/ocr_image_source.dart';
import 'package:loop/src/features/ocr/presentation/providers/ocr_providers.dart';
import 'package:loop/src/features/ocr/presentation/providers/ocr_state.dart';

class OcrPage extends ConsumerWidget {
  const OcrPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ocrNotifierProvider);
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final imagePath = state.imagePath;
    final result = state.result;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.ocrTitle)),
      body: SafeArea(
        child: MaxWidthContainer(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 24),
            children: [
              Text(l10n.ocrSelectImageHint),
              const SizedBox(height: 16),

              // 처리 중에는 버튼을 비활성화한다.
              FilledButton.icon(
                onPressed: state.isBusy
                    ? null
                    : () async {
                        await ref
                            .read(ocrNotifierProvider.notifier)
                            .selectImage(source: OcrImageSource.gallery);
                      },
                icon: const Icon(Icons.photo_library_outlined),
                label: Text(l10n.ocrSelectImage),
              ),

              // 선택한 사진 미리보기
              if (imagePath != null) ...[
                const SizedBox(height: 24),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                    File(imagePath),
                    key: ValueKey(imagePath),
                    height: 260,
                    width: double.infinity,
                    fit: BoxFit.contain,

                    // 미리보기 디코딩 크기만 제한한다.
                    // OCR에는 원본 파일이 전달된다.
                    cacheWidth: 1200,
                    errorBuilder: (context, error, stackTrace) {
                      return SizedBox(
                        height: 120,
                        child: Center(child: Text(l10n.ocrPreviewFailed)),
                      );
                    },
                  ),
                ),
              ],

              // 사진 선택 또는 인식 진행 상태
              if (state.isBusy) ...[
                const SizedBox(height: 24),
                const Center(child: CircularProgressIndicator()),
                const SizedBox(height: 12),
                Text(
                  state.status == OcrStatus.selecting
                      ? l10n.ocrSelecting
                      : l10n.ocrRecognizing,
                  textAlign: TextAlign.center,
                ),
              ],

              // 글자를 찾지 못한 경우
              if (state.status == OcrStatus.empty) ...[
                const SizedBox(height: 24),
                Text(l10n.ocrEmptyResult),
              ],

              // 오류는 코드에 따라 다국어 문구로 표시한다.
              if (state.status == OcrStatus.failure) ...[
                const SizedBox(height: 24),
                Semantics(
                  liveRegion: true,
                  child: Text(
                    _errorMessage(l10n, state.failureCode),
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),
              ],

              // 인식 결과를 사진 아래에 표시한다.
              if (result != null && result.text.trim().isNotEmpty) ...[
                const SizedBox(height: 24),
                Text(l10n.ocrResultTitle, style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(result.text, style: theme.textTheme.bodyLarge),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _errorMessage(AppLocalizations l10n, OcrFailureCode? code) {
    return switch (code) {
      OcrFailureCode.unsupportedPlatform => l10n.ocrUnsupportedPlatform,
      OcrFailureCode.permissionDenied => l10n.ocrPermissionDenied,
      OcrFailureCode.imageSelectionFailed => l10n.ocrImageSelectionFailed,
      OcrFailureCode.invalidImage => l10n.ocrInvalidImage,
      OcrFailureCode.recognitionFailed || null => l10n.ocrRecognitionFailed,
    };
  }
}
