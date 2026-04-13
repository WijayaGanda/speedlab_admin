import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:speedlab_admin/app/data/models/user_model.dart';
import 'package:speedlab_admin/app/data/providers/auth_provider.dart';
import 'package:speedlab_admin/app/data/services/auth_service.dart';
import 'package:speedlab_admin/app/utils/widget/custom_modal.dart';
import 'package:speedlab_admin/app/utils/widget/custom_snackbar.dart';

class LoginController extends GetxController {
  final AuthProvider provider;

  LoginController({required this.provider});

  var isLoading = false.obs;
  var isVisible = true.obs;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      CustomModal.showErrorDialog(
        title: "Informasi",
        message: "Email dan password tidak boleh kosong",
      );
      return;
    }

    try {
      isLoading.value = true;
      final response = await provider.login(
        emailController.text,
        passwordController.text,
      );
      if (response.isOk && response.body != null) {
        final loginres = LoginResponseModel.fromJson(response.body['data']);
        Get.find<AuthService>().login(loginres.token!, loginres.user!);
        CustomSnackbar.success(
          "Halo",
          "Selamat datang ${loginres.user?.name ?? 'User'}!",
        );
        Get.offAllNamed('/dashboard');
      }
    } finally {
      isLoading.value = false;
    }
  }

  void togglePasswordVisibility() {
    isVisible.value = !isVisible.value;
  }
}
