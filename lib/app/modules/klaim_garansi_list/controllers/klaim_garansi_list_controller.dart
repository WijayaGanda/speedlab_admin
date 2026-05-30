import 'package:action_slider/action_slider.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speedlab_admin/app/data/models/warranty_model.dart';
import 'package:speedlab_admin/app/data/providers/warranty_claim.dart';
import 'package:flutter/material.dart';
import 'package:speedlab_admin/app/utils/theme/color_theme.dart';
import 'package:speedlab_admin/app/utils/widget/custom_modal.dart';
import 'package:speedlab_admin/app/utils/widget/custom_snackbar.dart';
import 'package:speedlab_admin/app/utils/widget/custom_textfield.dart';

class KlaimGaransiListController extends GetxController {
  final WarrantyClaimProvider provider;

  KlaimGaransiListController({required this.provider});

  final warranties = <WarrantyModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchWarranties();
  }

  Future<void> fetchWarranties() async {
    try {
      isLoading.value = true;
      final response = await provider.fetchallWarrantyClaims();
      if (response.isOk) {
        final warrantiesResponse = WarrantyResponse.fromJson(response.body);
        warranties.value = warrantiesResponse.data ?? [];
      } else {
        Get.snackbar('Error', 'Gagal memuat klaim garansi');
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat klaim garansi');
    } finally {
      isLoading.value = false;
    }
  }

  List<WarrantyModel> getWarrantiesByStatus(String status) {
    return warranties.where((warranty) {
      String apiStatus = warranty.status ?? '';
      switch (status) {
        case 'Menunggu Verifikasi':
          return apiStatus.toLowerCase() == 'menunggu verifikasi';
        case 'Terverifikasi':
          return apiStatus.toLowerCase() == 'terverifikasi';
        case 'Ditolak':
          return apiStatus.toLowerCase() == 'ditolak';
        default:
          return false;
      }
    }).toList();
  }

  Future<void> verifyWarranty(String warrantyId) async {
    try {
      isLoading.value = true;
      final response = await provider.verifyWarranties(warrantyId, 'Diterima');
      if (response.isOk) {
        CustomSnackbar.success(
          'Success',
          'Klaim garansi berhasil diverifikasi',
        );
        fetchWarranties();
      } else {
        debugPrint(
          '❌ Response Error: ${response.statusCode} - ${response.bodyString}',
        );
        CustomSnackbar.error('Error', 'Gagal memverifikasi klaim garansi');
      }
    } catch (e) {
      CustomSnackbar.error('Error', 'Gagal memverifikasi klaim garansi');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> rejectWarranty(String warrantyId, String reason) async {
    try {
      isLoading.value = true;
      final response = await provider.rejectWarranty(
        warrantyId,
        'Ditolak',
        rejectionReason: reason,
      );
      if (response.isOk) {
        CustomSnackbar.success('Success', 'Klaim garansi berhasil ditolak');
        fetchWarranties();
      } else {
        CustomSnackbar.error('Error', 'Gagal menolak klaim garansi');
      }
    } catch (e) {
      CustomSnackbar.error('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> showRejectReasonDialog(String warrantyId) async {
    TextEditingController reasonController = TextEditingController();

    CustomModal.showBottomSheet(
      height: Get.height * 0.7,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Tolak Garansi',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Apakah Anda yakin ingin menolak garansi ini?',
            style: GoogleFonts.poppins(fontSize: 13),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          CustomTextField(
            isObscure: false,
            controller: reasonController,
            label: 'Alasan Penolakan',
            labelText: 'Masukkan alasan penolakan garansi',
          ),
          ActionSlider.standard(
            toggleColor: ColorTheme.neonYellow,
            backgroundColor: Colors.black,
            child: Text(
              "Tolak Garansi",
              style: GoogleFonts.poppins(color: ColorTheme.neonYellow),
            ),
            action: (controller) async {
              Get.back();
              controller.loading();
              if (reasonController.text.trim().isEmpty) {
                CustomModal.showErrorDialog(
                  title: 'Alasan Penolakan Kosong',
                  message: 'Silakan masukkan alasan penolakan garansi.',
                );
                controller.reset();
                return;
              }
              await rejectWarranty(warrantyId, reasonController.text);
              await Future.delayed(const Duration(seconds: 1));
              controller.success();
            },
          ),
          SizedBox(height: 10),
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Batal', style: TextStyle(color: Colors.grey[600])),
          ),
        ],
      ),
    );
  }
}
