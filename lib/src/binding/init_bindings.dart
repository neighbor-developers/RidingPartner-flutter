import 'package:get/get.dart';

class InitBinding extends Bindings {
  @override
  void dependencies() {
    // Get.put(BottomNavController(), permanent: true);
    // Get.put(AuthController(), permanent: true);
  }

  static additionalBinding() {
    // Get.put(MypageController(), permanent: true);
    // Get.put(HomeController(), permanent: true);
  }
}
