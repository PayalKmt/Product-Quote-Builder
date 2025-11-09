import 'package:get/get.dart';
import '../modules/quote_form_screen/bindings/quote_form_screen_binding.dart';
import '../modules/quote_form_screen/views/quote_form_screen_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.QUOTE_FORM_SCREEN;

  static final routes = [
    GetPage(
      name: _Paths.QUOTE_FORM_SCREEN,
      page: () => const QuoteFormScreenView(),
      binding: QuoteFormScreenBinding(),
    ),
  ];
}
