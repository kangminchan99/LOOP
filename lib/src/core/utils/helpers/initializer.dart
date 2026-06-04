import 'package:intl/intl.dart';

class Helpers {
  // Future<void> initializeApp() async {
  //   // ProviderContainer를 사용하여 initializationProvider 실행
  //   final container = ProviderContainer();
  //   await container.read(initializationProvider.future);
  // }

  // format date
  String formatDate(DateTime date) {
    final corrected = date.toLocal().add(const Duration(hours: 9));
    final now = DateTime.now();
    final diff = now.difference(corrected);

    if (diff.inMinutes < 1) return '방금 전';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    if (diff.inDays < 7) return '${diff.inDays}일 전';

    return DateFormat('yyyy.MM.dd').format(corrected);
  }
}
