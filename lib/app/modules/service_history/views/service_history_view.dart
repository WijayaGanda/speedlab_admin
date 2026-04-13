import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speedlab_admin/app/utils/theme/color_theme.dart';
import 'package:speedlab_admin/app/utils/widget/custom_button.dart';
import 'package:speedlab_admin/app/utils/widget/custom_modal.dart';
import 'package:speedlab_admin/app/utils/widget/custom_textfield.dart';

import '../controllers/service_history_controller.dart';

class ServiceHistoryView extends GetView<ServiceHistoryController> {
  const ServiceHistoryView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
        title: Text(
          'Riwayat Servis',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              controller.fetchServiceHistory(
                controller.selectedBooking.value?.id ?? 0.toString(),
              );
            },
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
      body: Obx(() {
        final booking = controller.selectedBooking.value;
        // final service = controller.serviceHistory.value;
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(color: ColorTheme.neonYellow),
          );
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                Container(
                  // margin: const EdgeInsets.all(15),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: ColorTheme.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: ColorTheme.primary),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 40,
                        color: ColorTheme.darkBgPrimary,
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Nama Pemilik:",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              booking?.userId?['name'] ?? "Tidak Diketahui",
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                CustomTextField(
                  controller: controller.namaMekanikController,
                  labelText: "Nama Mekanik",
                  isObscure: false,
                  prefixIcon: Icons.person,
                  hintText: "Masukkan nama mekanik",
                  enabled: !controller.isFormDisabled,
                ),
                CustomTextField(
                  controller: controller.diagnosisController,
                  labelText: "Diagnosis Masalah",
                  isObscure: false,
                  prefixIcon: Icons.build_circle_outlined,
                  maxLines: 3,
                  hintText: "Masukkan diagnosis masalah",
                  enabled: !controller.isFormDisabled,
                ),
                CustomTextField(
                  controller: controller.catatanController,
                  labelText: "Catatan",
                  isObscure: false,
                  prefixIcon: Icons.book,
                  maxLines: 3,
                  hintText: "Masukkan Catatan",
                  enabled: !controller.isFormDisabled,
                ),
                CustomTextField(
                  controller: controller.workDDoneController,
                  labelText: "Pekerjaan Yang Telah Selesai",
                  isObscure: false,
                  prefixIcon: Icons.book,
                  maxLines: 3,
                  hintText: "Masukkan Pekerjaan Yang Telah Selesai",
                  enabled: !controller.isFormDisabled,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Sparepart yang diganti:",
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    IconButton(
                      onPressed:
                          controller.isFormDisabled
                              ? null
                              : () {
                                CustomModal.showSparePartFormModal(
                                  onSubmit: (nama, harga, kuantiti) {
                                    controller.addSparePart(
                                      nama,
                                      harga,
                                      kuantiti,
                                    );
                                  },
                                  title: 'Tambah Spare Part',
                                  submitButtonText: 'Tambah',
                                );
                              },
                      icon: Icon(
                        Icons.add_circle_outline,
                        color:
                            controller.isFormDisabled
                                ? Colors.grey
                                : ColorTheme.primary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                // Display Spare Parts
                Obx(
                  () =>
                      controller.spareParts.isEmpty
                          ? Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              "Tidak ada spare part yang ditambahkan",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          )
                          : Column(
                            children: List.generate(controller.spareParts.length, (
                              index,
                            ) {
                              final sparePart = controller.spareParts[index];
                              return Card(
                                color: ColorTheme.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(color: Colors.black),
                                ),
                                elevation: 9,
                                shadowColor: Colors.black,
                                margin: EdgeInsets.only(bottom: 10),
                                child: Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              sparePart['nama'] ?? '',
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: ColorTheme.darkBgPrimary,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Text(
                                                  'Harga: Rp. ${sparePart['harga']}'
                                                      .replaceAll(
                                                        RegExp(
                                                          r'\B(?=(\d{3})+(?!\d))',
                                                        ),
                                                        '.',
                                                      ),
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 12,
                                                    color:
                                                        ColorTheme
                                                            .darkBgPrimary,
                                                  ),
                                                ),
                                                SizedBox(width: 16),
                                                Text(
                                                  'Qty: ${sparePart['kuantiti']}',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 12,
                                                    color:
                                                        ColorTheme
                                                            .darkBgPrimary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        onPressed:
                                            controller.isFormDisabled
                                                ? null
                                                : () {
                                                  controller.removeSparePart(
                                                    index,
                                                  );
                                                },
                                        icon: Icon(
                                          Icons.delete_outline,
                                          color:
                                              controller.isFormDisabled
                                                  ? Colors.grey
                                                  : Colors.red,
                                          size: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total Harga Spare Part:",
                      style: GoogleFonts.poppins(),
                    ),
                    Text(
                      "Rp. ${controller.totalHargaSpareParts}".replaceAll(
                        RegExp(r'\B(?=(\d{3})+(?!\d))'),
                        '.',
                      ),
                      style: GoogleFonts.poppins(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Obx(
                  () =>
                      controller.isFormDisabled
                          ? Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.green),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 24,
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Riwayat Servis Selesai",
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Colors.green[700],
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        "Riwayat servis sudah tersimpan dan selesai. Data tidak dapat diubah lagi.",
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: Colors.green[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                          : SizedBox.shrink(),
                ),
                const SizedBox(height: 20),
                Obx(
                  () =>
                      !controller.isFormDisabled
                          ? Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        controller.resetForm();
                                      },
                                      icon: Icon(
                                        Icons.info_outline,
                                        size: 12,
                                        color: Colors.blue[700],
                                      ),
                                      label: Text(
                                        "Reset",
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: ColorTheme.primary,
                                        side: BorderSide(
                                          color: ColorTheme.primary,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 10,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        controller.handleServiceHistory();
                                      },
                                      icon: const Icon(
                                        Icons.calendar_month,
                                        size: 18,
                                      ),
                                      label: Obx(
                                        () => Text(
                                          controller.serviceHistoryButtonText,
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: ColorTheme.neonYellow,
                                        foregroundColor: Colors.black,
                                        elevation: 8,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 10,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Obx(
                                () =>
                                    controller.serviceHistory.isEmpty
                                        ? SizedBox.shrink()
                                        : CustomButton(
                                          onPressed: () {
                                            CustomModal.showWarningDialog(
                                              title: 'Konfirmasi',
                                              message:
                                                  'Data Tidak bisa Diubah setelah terkonfirmasi',
                                              onConfirm: () {
                                                controller
                                                    .confirmationServiceHistory();
                                              },
                                            );
                                          },
                                          text: "Konfirmasi Riwayat Servis",
                                          icon: Icons.check,
                                          backgroundColor: ColorTheme.primary,
                                          foregroundColor: Colors.white,
                                        ),
                              ),
                            ],
                          )
                          : SizedBox.shrink(),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
