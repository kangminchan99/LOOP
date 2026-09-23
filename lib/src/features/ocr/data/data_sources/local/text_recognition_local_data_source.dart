import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class TextRecognitionLocalDataSource {
  Future<String> recognizeText({required String imagePath}) async {
    // 이미지 파일 경로를 ML Kit 입력 형식으로 변환한다.
    final inputImage = InputImage.fromFilePath(imagePath);

    // 이번 작업에서 사용할 한국어 인식기를 생성한다.
    final recognizer = TextRecognizer(script: TextRecognitionScript.korean);

    try {
      // 네이티브 ML Kit에서 사진 속 글자를 인식한다.
      final result = await recognizer.processImage(inputImage);

      // 글자가 없으면 빈 문자열이 반환된다.
      return result.text;
    } finally {
      // 성공·실패 여부와 관계없이 인식 작업이 끝나면 해제한다.
      await recognizer.close();
    }
  }
}
