import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
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
  var warrantyExpired = Rxn<String>();
  var selectedImagePath = "".obs;
  var isUploading = false.obs;
  final namaMekanikController = TextEditingController();
  final diagnosisController = TextEditingController();
  final catatanController = TextEditingController();
  final workDDoneController = TextEditingController();
  var descriptionText = ''.obs;

  final List<String> warrantyOptions = [
    '1 Minggu',
    '2 Minggu',
    '3 Minggu',
    '1 Bulan',
  ];

  /// Convert warranty option string to Days
  int getWarrantyDays(String option) {
    switch (option) {
      case '1 Minggu':
        return 7;
      case '2 Minggu':
        return 14;
      case '3 Minggu':
        return 21;
      case '1 Bulan':
        return 30;
      default:
        return 0;
    }
  }

  /// Calculate warranty expiry date from DateTime.now() + warranty option
  DateTime? getCalculatedWarrantyExpiry() {
    if (warrantyExpired.value == null) return null;

    final endDate = DateTime.now();
    final days = getWarrantyDays(warrantyExpired.value!);
    return endDate.add(Duration(days: days));
  }

  /// Convert DateTime warranty expiry to warranty option based on service end date
  String? getWarrantyOptionFromDate(DateTime? expiryDate) {
    if (expiryDate == null) return null;

    final endDate =
        serviceHistory.isNotEmpty && serviceHistory.first.endDate != null
            ? serviceHistory.first.endDate!
            : DateTime.now();

    final difference = expiryDate.difference(endDate).inDays;

    // Match to exact warranty option based on days
    if (difference == 7) {
      return '1 Minggu';
    } else if (difference == 14) {
      return '2 Minggu';
    } else if (difference == 21) {
      return '3 Minggu';
    } else if (difference == 30) {
      return '1 Bulan';
    }
    return null;
  }

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
        warrantyExpired.value = getWarrantyOptionFromDate(
          serviceHistoryResponse.data?.warrantyExpiry,
        );
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
        warrantyExpired.value = null;
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
      warrantyExpired.value = null;
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
          'warrantyExpiry': getCalculatedWarrantyExpiry()?.toIso8601String(),
          // 'totalPrice': finalPrice,
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
              'warrantyExpiry':
                  getCalculatedWarrantyExpiry()?.toIso8601String(),
              // 'totalPrice': finalPrice,
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

    if (warrantyExpired.value == null) {
      Get.snackbar('Error', 'Silakan pilih durasi garansi terlebih dahulu');
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
          'warrantyExpiry': getCalculatedWarrantyExpiry()?.toIso8601String(),
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

  void showWarrantySelectionBeforeConfirmation() {
    Get.dialog(
      AlertDialog(
        title: Text(
          'Pilih Durasi Garansi',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: warrantyOptions.length,
            itemBuilder: (context, index) {
              final option = warrantyOptions[index];
              return ListTile(
                title: Text(option),
                onTap: () {
                  warrantyExpired.value = option;
                  Get.back(); // Close warranty selection dialog

                  // Show confirmation dialog
                  CustomModal.showWarningDialog(
                    title: 'Konfirmasi',
                    message:
                        'Durasi garansi: $option\n\nData Tidak bisa Diubah setelah terkonfirmasi',
                    onConfirm: () {
                      confirmationServiceHistory();
                    },
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Batal')),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void addSparePart(String nama, String harga, String kuantiti) {
    spareParts.add({'nama': nama, 'harga': harga, 'kuantiti': kuantiti});
  }

  void removeSparePart(int index) {
    spareParts.removeAt(index);
  }

  //Fungsi untuk membuka kamera atau galeri
  Future<void> pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);

    if (image != null) {
      File? compressedImage = await compressImage(File(image.path));
      if (compressedImage != null) {
        selectedImagePath.value = compressedImage.path;
      } else {
        selectedImagePath.value = image.path; // Fallback ke gambar asli
      }
    }
  }

  //fungsi untuk kompress gambar
  Future<File?> compressImage(File file) async {
    final filePath = file.absolute.path;

    final lastIndex = filePath.lastIndexOf(RegExp(r'.jp|.png|.jpeg'));
    if (lastIndex == -1) return file;

    final splitted = filePath.substring(0, lastIndex);
    final extension = filePath.substring(lastIndex);
    final outPath = "${splitted}_compressed$extension";

    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      outPath,
      quality: 60,
      minWidth: 1024,
      minHeight: 1024,
    );
    return result != null
        ? File(result.path)
        : null; // Placeholder, ganti dengan file yang sudah dikompres
  }

  Future<void> uploadImage() async {
    if (selectedImagePath.value.isEmpty) {
      Get.snackbar('Peringatan', 'Silakan pilih foto terlebih dahulu!');
      return;
    }

    if (serviceHistory.isEmpty) {
      Get.snackbar('Error', 'Data riwayat servis tidak ditemukan!');
      return;
    }

    try {
      isUploading.value = true;

      final response = await provider.uploadServiceHistoryImage(
        serviceHistory.first.id.toString(),
        selectedImagePath.value,
        descriptionText.value,
      );
      if (response.isOk) {
        // 1. Ambil HANYA array workPhotos dari balasan server
        var updatedPhotos = response.body['data']['workPhotos'];

        // 2. Karena workPhotos Anda adalah 'final List', kita bersihkan isi lamanya
        // lalu kita isi dengan data yang baru dari server
        serviceHistory[0].workPhotos!.clear();

        // 3. Masukkan data baru (pastikan tipe datanya di-casting dengan benar)
        serviceHistory[0].workPhotos!.addAll(
          List<Map<String, dynamic>>.from(updatedPhotos),
        );

        // 4. BERITAHU GETX AGAR MEMPERBARUI TAMPILAN (Sangat Penting!)
        serviceHistory.refresh();

        // 5. Reset input form (Sekarang baris ini pasti tereksekusi)
        selectedImagePath.value = '';
        descriptionText.value = '';
        fetchServiceHistory(
          selectedBooking.value!.id.toString(),
        ); // Refresh data dari server untuk memastikan sinkronisasi

        Get.snackbar('Sukses', 'Foto dan deskripsi berhasil ditambahkan!');
      } else {
        Get.snackbar(
          'Gagal',
          'Gagal mengunggah foto. Kode: ${response.statusText}',
        );
      }
    } catch (e) {
      debugPrint('Gagal menghubungi server: $e');
    } finally {
      isUploading.value = false;
    }
  }

  void resetForm() {
    namaMekanikController.clear();
    diagnosisController.clear();
    catatanController.clear();
    workDDoneController.clear();
    warrantyExpired.value = null;
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
