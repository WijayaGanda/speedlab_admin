import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speedlab_admin/app/utils/widget/custom_button.dart';
import 'package:speedlab_admin/app/utils/widget/custom_header.dart';
import 'package:speedlab_admin/app/utils/widget/custom_textfield.dart';

import '../controllers/edit_service_controller.dart';

class EditServiceView extends GetView<EditServiceController> {
  const EditServiceView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
        title: Text(
          "Ubah Layanan Servis",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        // centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            CustomHeader(
              title: "Silahkan Ubah Layanan",
              subtitle: "Masukkan Data dengan benar",
              icon: Icon(Icons.build, size: 48, color: Colors.white),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  CustomTextField(
                    controller: controller.nameCtrl,
                    labelText: "Nama Layanan",
                    hintText: "Masukkan nama layanan",
                    prefixIcon: Icons.person,
                    keyboardType: TextInputType.name,
                    isObscure: false,
                  ),
                  CustomTextField(
                    controller: controller.deskripsiCtrl,
                    labelText: "Deskripsi",
                    hintText: "Masukkan deskripsi layanan",
                    prefixIcon: Icons.description,
                    keyboardType: TextInputType.text,
                    maxLines: 3,
                    iconLabel: Icons.abc,
                    isObscure: false,
                  ),
                  CustomTextField(
                    controller: controller.hargaCtrl,
                    labelText: "Harga",
                    hintText: "Masukkan harga layanan",
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.price_change,
                    iconLabel: Icons.monetization_on,
                    isObscure: false,
                  ),
                  CustomTextField(
                    controller: controller.estimatedDurationCtrl,
                    labelText: "Estimasi Waktu",
                    hintText: "Masukkan estimasi waktu",
                    prefixIcon: Icons.access_time,
                    iconLabel: Icons.timer,
                    isObscure: false,
                  ),
                  Obx(
                    () =>
                        controller.isLoading.value
                            ? CircularProgressIndicator(
                              color: Color(0xFFFFD700),
                            )
                            : CustomButton(
                              icon: Icons.edit,
                              text: "Ubah Layanan",
                              onPressed: () {
                                controller.updateService();
                              },
                              backgroundColor: Color(0xFFFFD700),
                              foregroundColor: Colors.black,
                            ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
