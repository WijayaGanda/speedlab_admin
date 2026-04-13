import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speedlab_admin/app/utils/widget/custom_button.dart';
import 'package:speedlab_admin/app/utils/widget/custom_header.dart';
import 'package:speedlab_admin/app/utils/widget/custom_textfield.dart';

import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          "Login ",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            CustomHeader(
              title: "Selamat Datang",
              subtitle: "Silakan masuk untuk melanjutkan",
              // icon: Image.asset(
              //   "assets/images/logo_spl.jpeg",
              //   width: 70,
              //   height: 70,
              // ),
            ),
            SizedBox(height: 30),
            Card(
              elevation: 10,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
                side: BorderSide(color: Colors.transparent),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomTextField(
                      // iconLabel: Icons.abc,
                      controller: controller.emailController,
                      labelText: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email,
                      hintText: "Masukkan email anda",
                      isObscure: false,
                    ),
                    Obx(
                      () => CustomTextField(
                        controller: controller.passwordController,
                        labelText: 'Password',
                        // keyboardType: TextInputType.pass,
                        prefixIcon: Icons.key,
                        maxLines: 1,
                        hintText: "Masukkan password anda",
                        isObscure: controller.isVisible.value,
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.isVisible.value
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            controller.togglePasswordVisibility();
                          },
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Get.toNamed('/forgot-password');
                        },
                        child: Text(
                          "Lupa Password?",
                          style: GoogleFonts.poppins(
                            color: Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Obx(
                      () =>
                          controller.isLoading.value
                              ? CircularProgressIndicator(
                                color: Color(0xFFFFD700),
                              )
                              : CustomButton(
                                icon: Icons.door_front_door_outlined,
                                text: "Masuk",
                                onPressed: () {
                                  controller.login();
                                },
                                backgroundColor: Color(0xFFFFD700),
                                foregroundColor: Colors.black,
                              ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
