import 'package:get/get.dart';
import '../controllers/file_controller.dart';
import '../controllers/news_controller.dart';
import '../controllers/notification_controller.dart';

class SharedBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FileController>(() => FileController());
    Get.lazyPut<NewsController>(() => NewsController());
    Get.lazyPut<NotificationController>(() => NotificationController());
  }
}