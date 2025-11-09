import 'package:get/get.dart';

import '../controllers/quote_form_screen_controller.dart';

class QuoteFormScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<QuoteFormScreenController>(
      () => QuoteFormScreenController(),
    );
  }
}
