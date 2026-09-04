import 'package:get/get.dart';

class NavController extends GetxController {
  final index = 0.obs;

  void go(int value) => index.value = value;
}
