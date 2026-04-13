import 'package:get/get.dart';
import 'package:speedlab_admin/app/data/models/bookings_model.dart';
import 'package:speedlab_admin/app/data/models/service_history_model.dart';
import 'package:speedlab_admin/app/data/providers/service_history_provider.dart';
import 'package:flutter/material.dart';
import 'package:speedlab_admin/app/utils/widget/custom_modal.dart';
// import 'package:speedlab_admin/app/utils/widget/custom_snackbar.dart';

class ServiceHistoryController extends GetxController {
  final ServiceHistoryProvider provider;

  ServiceHistoryController({required this.provider});

  var serviceHistory = <ServiceHistoryModel>[].obs;
  var selectedBooking = Rxn<BookingsModel>();
  var isLoading = false.obs;
  var spareParts = <Map<String, String>>[].obs;
  final namaMekanikController = TextEditingController();
  final diagnosisController = TextEditingController();
  final catatanController = TextEditingController();
  final workDDoneController = TextEditingController();

  int get totalHargaSpareParts {
    return spareParts.fold(0, (total, part) {
      final price = int.tryParse(part['harga'] ?? '0') ?? 0;
      final quantity = int.tryParse(part['kuantiti'] ?? '0') ?? 0;
      return total + (price * quantity);
    });
  }

  int get finalPrice {
    final bookingPrice = selectedBooking.value?.totalPrice ?? 0;
    return bookingPrice + totalHargaSpareParts;
  }

  String get serviceHistoryButtonText {
    if (serviceHistory.isEmpty) {
      return "Tambah Riwayat Servis";
    }

    final status = serviceHistory.first.status?.toLowerCase() ?? '';

    switch (status) {
      case 'dimulai':
      case 'sedang dikerjakan':
        return "Update Riwayat Servis";
      default:
        return "Update Riwayat Servis";
    }
  }

  bool get isFormDisabled {
    if (serviceHistory.isEmpty) {
      return false;
    }
    final status = serviceHistory.first.status?.toLowerCase() ?? '';
    return status == 'selesai';
  }

  @override
  void onInit() {
    super.onInit();
    selectedBooking.value = Get.arguments as BookingsModel?;

    fetchServiceHistory(selectedBooking.value!.id.toString());
  }

  Future<void> fetchServiceHistory(String bookingId) async {
    if (selectedBooking.value == null) return;

    isLoading.value = true;
    try {
      final response = await provider.getServiceHistory(bookingId);
      if (response.isOk && response.body['data'] != null) {
        final serviceHistoryResponse = ServiceHistoryResponse.fromJson(
          response.body,
        );
        if (serviceHistoryResponse.data != null) {
          serviceHistory.value = [serviceHistoryResponse.data!];
        } else {
          serviceHistory.value = [];
        }
        namaMekanikController.text =
            serviceHistoryResponse.data?.mechanicName ?? "";
        diagnosisController.text = serviceHistoryResponse.data?.diagnosis ?? "";
        catatanController.text = serviceHistoryResponse.data?.notes ?? "";
        workDDoneController.text = serviceHistoryResponse.data?.workDone ?? "";
        spareParts.value =
            (serviceHistoryResponse.data?.spareParts ?? [])
                .map(
                  (part) => {
                    'nama': part.name ?? '',
                    'harga': (part.price ?? 0).toString(),
                    'kuantiti': (part.quantity ?? 0).toString(),
                  },
                )
                .toList();
        CustomModal.showSuccessDialog(
          title: 'Riwayat Servis Ditemukan',
          message: 'Riwayat servis berhasil ditemukan untuk booking ini.',
        );
      } else {
        // Reset serviceHistory menjadi kosong jika fetch gagal
        serviceHistory.value = [];
        namaMekanikController.clear();
        diagnosisController.clear();
        spareParts.clear();
        CustomModal.showErrorDialog(
          title: 'Riwayat Servis Kosong',
          message: 'Silahkan tambahkan riwayat servis untuk booking ini.',
        );
      }
    } catch (e) {
      // Reset serviceHistory jika terjadi error
      serviceHistory.value = [];
      namaMekanikController.clear();
      diagnosisController.clear();
      catatanController.clear();
      workDDoneController.clear();
      spareParts.clear();
      debugPrint('Error fetching service history: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> handleServiceHistory() async {
    if (selectedBooking.value == null) {
      Get.snackbar('Error', 'No booking selected');
      return;
    }

    isLoading.value = true;
    try {
      if (serviceHistory.isEmpty) {
        // Create new service history
        final response = await provider.createServiceHistory({
          'bookingId': selectedBooking.value!.id,
          'mechanicName': namaMekanikController.text,
          'diagnosis': diagnosisController.text,
          'notes': catatanController.text,
          'workDone': workDDoneController.text,
          'spareParts':
              spareParts
                  .map(
                    (part) => {
                      'name': part['nama'],
                      'price': part['harga'],
                      'quantity': part['kuantiti'],
                    },
                  )
                  .toList(),
          'totalPrice': finalPrice,
          // 'startDate': DateTime.now().toIso8601String(),
          // 'endDate': DateTime.now().toIso8601String(),
        });
        if (response.isOk) {
          Get.back();
          CustomModal.showSuccessDialog(
            title: 'Success',
            message: 'Riwayat Servis berhasil ditambahkan',
          );
        } else {
          CustomModal.showErrorDialog(
            title: 'Error',
            message: 'Gagal menambahkan riwayat servis',
          );
        }
      } else {
        // Update existing service history
        final currentHistory = serviceHistory.first;
        final status = currentHistory.status?.toLowerCase() ?? '';

        if (status == 'dimulai' || status == 'sedang dikerjakan') {
          final response = await provider.updateServiceHistory(
            currentHistory.id.toString(),
            {
              'mechanicName': namaMekanikController.text,
              'diagnosis': diagnosisController.text,
              'notes': catatanController.text,
              'workDone': workDDoneController.text,
              'spareParts':
                  spareParts
                      .map(
                        (part) => {
                          'name': part['nama'],
                          'price': part['harga'],
                          'quantity': part['kuantiti'],
                        },
                      )
                      .toList(),
              'totalPrice': finalPrice,
              // 'endDate': DateTime.now().toIso8601String(),
              // 'status': 'Sedang Dikerjakan',
            },
          );
          if (response.isOk) {
            Get.back();
            CustomModal.showSuccessDialog(
              title: 'Success',
              message: 'Riwayat Servis berhasil diperbarui',
            );
          } else {
            CustomModal.showErrorDialog(
              title: 'Error',
              message: 'Gagal memperbarui riwayat servis',
            );
          }
        }
      }
    } catch (e) {
      CustomModal.showErrorDialog(
        title: 'Error',
        message: 'An error occurred: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> confirmationServiceHistory() async {
    if (selectedBooking.value == null) {
      Get.snackbar('Error', 'No booking selected');
      return;
    }

    if (serviceHistory.isEmpty) {
      Get.snackbar('Error', 'Tidak ada service history untuk dikonfirmasi');
      return;
    }

    final currentHistory = serviceHistory.first;

    isLoading.value = true;
    try {
      final response = await provider.updateServiceHistory(
        currentHistory.id.toString(),
        {
          'mechanicName': namaMekanikController.text,
          'diagnosis': diagnosisController.text,
          'notes': catatanController.text,
          'workDone': workDDoneController.text,
          'spareParts':
              spareParts
                  .map(
                    (part) => {
                      'name': part['nama'],
                      'price': part['harga'],
                      'quantity': part['kuantiti'],
                    },
                  )
                  .toList(),
          'totalPrice': finalPrice,
          'status': 'Selesai',
          'endDate': DateTime.now().toIso8601String(),
        },
      );
      if (response.isOk) {
        Get.back();
        CustomModal.showSuccessDialog(
          title: 'Success',
          message: 'Riwayat Servis berhasil dikonfirmasi',
        );
      } else {
        CustomModal.showErrorDialog(
          title: 'Error',
          message: 'Gagal mengkonfirmasi riwayat servis',
        );
      }
    } catch (e) {
      CustomModal.showErrorDialog(
        title: 'Error',
        message: 'An error occurred: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }

  void addSparePart(String nama, String harga, String kuantiti) {
    spareParts.add({'nama': nama, 'harga': harga, 'kuantiti': kuantiti});
  }

  void removeSparePart(int index) {
    spareParts.removeAt(index);
  }

  void resetForm() {
    namaMekanikController.clear();
    diagnosisController.clear();
    catatanController.clear();
    workDDoneController.clear();
    spareParts.clear();
  }

  void disableForm() {
    namaMekanikController.text = serviceHistory.first.mechanicName ?? '';
    diagnosisController.text = serviceHistory.first.diagnosis ?? '';
    catatanController.text = serviceHistory.first.notes ?? '';
    workDDoneController.text = serviceHistory.first.workDone ?? '';
    spareParts.value =
        (serviceHistory.first.spareParts ?? [])
            .map(
              (part) => {
                'nama': part.name ?? '',
                'harga': (part.price ?? 0).toString(),
                'kuantiti': (part.quantity ?? 0).toString(),
              },
            )
            .toList();
  }
}
