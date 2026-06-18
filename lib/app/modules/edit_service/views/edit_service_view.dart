import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speedlab_admin/app/utils/theme/color_theme.dart';
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
              icon: Icon(Icons.build, size: 30, color: ColorTheme.neonYellow),
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
                    labelText: "Estimasi Waktu (Menit)",
                    hintText: "Masukkan estimasi waktu",
                    prefixIcon: Icons.access_time,
                    iconLabel: Icons.timer,
                    isObscure: false,
                  ),
                  Obx(
                    () => SwitchListTile(
                      title: Text("Layanan Bisa Ditunggu"),
                      subtitle: Text(
                        controller.isWaitable.value
                            ? "Bisa Ditunggu (Pengerjaan cepat)"
                            : "Harus Ditinggal (Membutuhkan waktu lama)",
                        style: TextStyle(
                          color:
                              controller.isWaitable.value
                                  ? Colors.green
                                  : Colors.orange,
                        ),
                      ),
                      value: controller.isWaitable.value,
                      activeThumbColor: Colors.green,
                      inactiveThumbColor: Colors.orange,
                      onChanged: (value) {
                        controller.isWaitable.value = value;
                      },
                    ),
                  ),
                  SizedBox(height: 20),

                  // ========== VARIANTS SECTION ==========
                  Divider(thickness: 2),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Variants",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  CustomTextField(
                    controller: controller.variantNameCtrl,
                    labelText: "Nama Varian",
                    hintText: "Contoh: CBR SP",
                    prefixIcon: Icons.add,
                    keyboardType: TextInputType.text,
                    isObscure: false,
                  ),
                  CustomTextField(
                    controller: controller.variantPriceModifierCtrl,
                    labelText: "Harga Varian",
                    hintText: "Tambahan harga (opsional)",
                    prefixIcon: Icons.attach_money,
                    keyboardType: TextInputType.number,
                    isObscure: false,
                  ),
                  CustomTextField(
                    controller: controller.variantDescCtrl,
                    labelText: "Deskripsi Varian",
                    hintText: "Deskripsi tambahan",
                    prefixIcon: Icons.info,
                    keyboardType: TextInputType.text,
                    maxLines: 2,
                    isObscure: false,
                  ),
                  CustomButton(
                    icon: Icons.add,
                    text: "Tambah Variant",
                    onPressed: controller.addVariant,
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  SizedBox(height: 12),

                  // List Variants with information
                  Obx(
                    () => Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              controller.variants.isEmpty
                                  ? "Varian Tersedia: Tidak ada varian"
                                  : "Varian Tersedia: ${controller.variants.length} varian",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color:
                                    controller.variants.isEmpty
                                        ? Colors.grey
                                        : Colors.blue,
                              ),
                            ),
                          ),
                        ),
                        controller.variants.isEmpty
                            ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("Belum ada variant"),
                            )
                            : Column(
                              children: List.generate(
                                controller.variants.length,
                                (index) {
                                  final variant = controller.variants[index];
                                  return Card(
                                    margin: EdgeInsets.only(bottom: 8),
                                    child: ListTile(
                                      title: Text(variant['variantName']),
                                      subtitle: Text(
                                        'Modifier: ${variant['priceModifier']}${variant['variantDescription'].isNotEmpty ? '\n${variant['variantDescription']}' : ''}',
                                      ),
                                      trailing: IconButton(
                                        icon: Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed:
                                            () =>
                                                controller.removeVariant(index),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),

                  // ========== ADDONS SECTION ==========
                  Divider(thickness: 2),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Available Addons",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  CustomTextField(
                    controller: controller.addonNameCtrl,
                    labelText: "Nama Addon",
                    hintText: "Contoh: Remap by Owner",
                    prefixIcon: Icons.extension,
                    keyboardType: TextInputType.text,
                    isObscure: false,
                  ),
                  CustomTextField(
                    controller: controller.addonPriceCtrl,
                    labelText: "Harga Addon",
                    hintText: "Masukkan harga addon",
                    prefixIcon: Icons.attach_money,
                    keyboardType: TextInputType.number,
                    isObscure: false,
                  ),
                  CustomTextField(
                    controller: controller.addonDescCtrl,
                    labelText: "Deskripsi Addon",
                    hintText: "Deskripsi addon",
                    prefixIcon: Icons.info,
                    keyboardType: TextInputType.text,
                    maxLines: 2,
                    isObscure: false,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Obx(
                      () => DropdownButton<String>(
                        value: controller.selectedAddonType.value,
                        items:
                            ['OPTIONAL', 'REQUIRED']
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            controller.selectedAddonType.value = value;
                          }
                        },
                      ),
                    ),
                  ),
                  CustomButton(
                    icon: Icons.add,
                    text: "Tambah Addon",
                    onPressed: controller.addAddon,
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  SizedBox(height: 12),

                  // List Addons with information
                  Obx(
                    () => Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              controller.addons.isEmpty
                                  ? "Addon Tersedia: Tidak ada addon"
                                  : "Addon Tersedia: ${controller.addons.length} addon",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color:
                                    controller.addons.isEmpty
                                        ? Colors.grey
                                        : Colors.green,
                              ),
                            ),
                          ),
                        ),
                        controller.addons.isEmpty
                            ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("Belum ada addon"),
                            )
                            : Column(
                              children: List.generate(controller.addons.length, (
                                index,
                              ) {
                                final addon = controller.addons[index];
                                return Card(
                                  margin: EdgeInsets.only(bottom: 8),
                                  child: ListTile(
                                    title: Text(addon['addonName']),
                                    subtitle: Text(
                                      'Harga: ${addon['price']} | Tipe: ${addon['type']}\n${addon['addonDescription']}',
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed:
                                          () => controller.removeAddon(index),
                                    ),
                                  ),
                                );
                              }),
                            ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),

                  // Button Submit
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
