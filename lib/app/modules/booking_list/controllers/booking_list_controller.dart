import 'package:action_slider/action_slider.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speedlab_admin/app/data/models/bookings_model.dart';
import 'package:speedlab_admin/app/data/models/payments_model.dart';
import 'package:speedlab_admin/app/data/models/service_history_model.dart';
import 'package:speedlab_admin/app/data/providers/bookings_provider.dart';
import 'package:speedlab_admin/app/data/providers/service_history_provider.dart';
import 'package:speedlab_admin/app/data/services/auth_service.dart';
import 'package:speedlab_admin/app/utils/helper/pdf_helper.dart';
import 'package:speedlab_admin/app/utils/theme/color_theme.dart';
import 'package:speedlab_admin/app/utils/widget/custom_modal.dart';
import 'package:speedlab_admin/app/utils/widget/custom_snackbar.dart';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';

class BookingListController extends GetxController {
  final BookingsProvider provider;
  final ServiceHistoryProvider serviceHistoryProvider;
  final AuthService authService;

  BookingListController({
    required this.provider,
    required this.serviceHistoryProvider,
    required this.authService,
  });

  var bookings = <BookingsModel>[].obs;
  var serviceHistory = <ServiceHistoryModel>[].obs;
  var paymentsResponse = <PaymentResponse>[].obs;
  var paymentsStatus = <String, PaymentStatusResponse>{}.obs;
  var isLoading = false.obs;
  var isProcessingPayment = false.obs;

  var selectedFilterData = Rx<DateTime?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchBookings();
  }

  List<BookingsModel> get filteredBookings {
    if (selectedFilterData.value == null) {
      return bookings;
    } else {
      return bookings.where((booking) {
        final bookingDate = booking.bookingDate;
        if (bookingDate == null) return false;
        return bookingDate.year == selectedFilterData.value!.year &&
            bookingDate.month == selectedFilterData.value!.month &&
            bookingDate.day == selectedFilterData.value!.day;
      }).toList();
    }
  }

  Future<void> pickFilterDate() async {
    DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: selectedFilterData.value ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      selectedFilterData.value = picked;
    }
  }

  Future<void> fetchBookings() async {
    try {
      isLoading.value = true;
      final response = await provider.fetchAllBookings();
      // final responseServiceHistory = await serviceHistoryProvider
      //     .getServiceHistory(bookings.first.id!);
      if (response.isOk) {
        final bookingsResponse = BookingsResponse.fromJson(response.body);
        bookings.value = bookingsResponse.data ?? [];
        // serviceHistory.value = [serviceHistoryResponse.data!];
      } else {
        CustomSnackbar.error("Error", 'Gagal memuat riwayat booking');
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat riwayat booking');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateStatusBooking(String id, String status) async {
    try {
      isLoading.value = true;
      final response = await provider.updateStatusBooking(id, status);
      if (response.isOk) {
        CustomSnackbar.success(
          "Berhasil",
          "Status booking berhasil diperbarui",
        );
        fetchBookings(); // Refresh data setelah update status
      } else {
        String errorMsg =
            response.body?['message'] ?? "Gagal memperbarui status booking";
        CustomSnackbar.error("Error API (${response.statusCode})", errorMsg);
      }
    } catch (e) {
      CustomSnackbar.error('Error', 'Gagal memperbarui status booking');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> cancelBookingAPI(String id) async {
    try {
      isLoading.value = true;
      final response = await provider.cancelBooking(id);
      if (response.isOk) {
        CustomSnackbar.success("Berhasil", "Booking berhasil dibatalkan");
        fetchBookings(); // Refresh data setelah pembatalan
      } else {
        String errorMsg =
            response.body?['message'] ?? "Gagal membatalkan booking";
        CustomSnackbar.error("Error API (${response.statusCode})", errorMsg);
      }
    } catch (e) {
      CustomSnackbar.error('Error', 'Gagal membatalkan booking');
    } finally {
      isLoading.value = false;
    }
  }

  // Future<void> makeDownPaymentAPI(String? id) async {
  //   debugPrint("=== ID BOOKING YANG MAU DIBAYAR: $id ===");

  //   if (id == null || id.isEmpty) {
  //     CustomSnackbar.error("Error", "ID Booking tidak ditemukan!");
  //     return; // Hentikan fungsi jika ID kosong
  //   }
  //   isProcessingPayment.value = true;
  //   try {
  //     // 1. Minta Token dan URL ke Express.js
  //     final response = await paymentProvider.createPayment(id);

  //     if (response.statusCode == 200 && response.body['success'] == true) {
  //       String redirectUrl = response.body['redirect_url'];

  //       // 2. Buka WebView Midtrans
  //       final result = await Get.toNamed(
  //         '/payment-webview',
  //         arguments: redirectUrl,
  //       );

  //       // 3. Setelah WebView ditutup (user selesai di Midtrans)
  //       if (result == true) {
  //         Get.snackbar("Info", "Memeriksa status pembayaran...");
  //         fetchBookings(); // Refresh data setelah pembayaran
  //       }
  //     } else {
  //       Get.snackbar("Gagal", response.body['message'] ?? "Terjadi kesalahan");
  //     }
  //   } catch (e) {
  //     Get.snackbar("Error", "Gagal terhubung ke server pembayaran");
  //     print(e);
  //   } finally {
  //     isProcessingPayment.value = false;
  //   }
  // }

  void moveToRiwayatServis(BookingsModel booking) {
    Get.toNamed("/riwayat-servis", arguments: booking);
  }

  // ========== FILTERING METHODS ==========
  List<BookingsModel> getBookingsByStatus(String status) {
    return bookings.where((booking) {
      String apiStatus = booking.status ?? '';
      switch (status) {
        case 'Menunggu Verifikasi':
          return apiStatus.toLowerCase() == 'menunggu verifikasi';
        case 'Terverifikasi':
          return apiStatus.toLowerCase() == 'terverifikasi';
        case 'Sedang Dikerjakan':
          return apiStatus.toLowerCase() == 'sedang dikerjakan';
        case 'Selesai':
          return apiStatus.toLowerCase() == 'selesai';
        case 'Dibatalkan':
          return apiStatus.toLowerCase() == 'dibatalkan';
        default:
          return false;
      }
    }).toList();
  }

  // ========== DATA PARSING METHODS ==========
  String getMotorcycleInfo(BookingsModel booking) {
    if (booking.motorcycleId == null) return '';

    final motorcycle = booking.motorcycleId!;
    String brand = motorcycle['brand'] ?? '';
    String model = motorcycle['model'] ?? '';
    String year = motorcycle['year']?.toString() ?? '';
    String licensePlate = motorcycle['licensePlate'] ?? '';

    return '$brand $model $year - $licensePlate';
  }

  String getServicesInfo(BookingsModel booking) {
    if (booking.bookingDetails == null || booking.bookingDetails!.isEmpty) {
      return '';
    }

    List<String> serviceDetails = [];
    for (var detail in booking.bookingDetails!) {
      String serviceName = detail.serviceName ?? '';

      // 1. Ambil Variant
      String variant = detail.selectedVariant ?? '';
      String variantStr = variant.isNotEmpty ? ' ($variant)' : '';

      // 2. Ambil Addons (Trik Baru!)
      String addonsStr = '';
      if (detail.selectedAddons != null && detail.selectedAddons!.isNotEmpty) {
        // Ambil semua nama addon, gabungkan dengan koma
        List<String> addonNames =
            detail.selectedAddons!
                .map((addon) => addon.name ?? '')
                .where((name) => name.isNotEmpty)
                .toList();

        if (addonNames.isNotEmpty) {
          // Format tampilannya, misal: " [+ Dyno Rental, Cuci Motor]"
          addonsStr = ' [+ ${addonNames.join(', ')}]';
        }
      }

      // 3. Gabungkan Semuanya: Nama Service + Variant + Addons
      serviceDetails.add('$serviceName$variantStr$addonsStr');
    }

    // Kembalikan hasilnya. (Pakai '\n' agar kalau layanannya banyak, dia turun ke baris baru biar rapi)
    return serviceDetails.join('\n');
  }

  // ========== FORMATTING METHODS ==========
  String formatDateTime(BookingsModel booking) {
    if (booking.bookingDate == null || booking.bookingTime == null) return '';

    final dateFormat = DateFormat('dd MMM yyyy');
    return '${dateFormat.format(booking.bookingDate!)}, ${booking.bookingTime!} WIB';
  }

  String getPaymentStatus(String? bookingId) {
    if (bookingId == null) return '-';
    final paymentStatus = paymentsStatus[bookingId];
    if (paymentStatus == null) return '-';
    return formatPaymentStatus(paymentStatus.transactionStatus);
  }

  PaymentStatusResponse? getPaymentStatusObject(String? bookingId) {
    if (bookingId == null) return null;
    return paymentsStatus[bookingId];
  }

  String formatPaymentStatus(String? status) {
    if (status == null || status.isEmpty) return '-';

    switch (status.toLowerCase()) {
      case 'settlement':
        return 'Sudah Dibayar';
      case 'pending':
        return 'Menunggu Pembayaran';
      case 'expire':
        return 'Pembayaran Kadaluarsa';
      case 'cancel':
        return 'Pembayaran Dibatalkan';
      case 'deny':
        return 'Pembayaran Ditolak';
      case 'failure':
        return 'Pembayaran Gagal';
      default:
        return status;
    }
  }

  String formatPrice(int? price) {
    if (price == null) return 'Belum ditentukan';
    return 'Rp ${NumberFormat('#,###').format(price)}';
  }

  String formatBookingId(String? id) {
    if (id == null) return 'Unknown';
    return '#${id.substring(0, 8)}';
  }

  String formatEstimatedTime(BookingsModel booking) {
    if (booking.bookingTime == null || booking.bookingDate == null) return '-';

    try {
      final timeParts = booking.bookingTime!.split(':');
      if (timeParts.length != 2) return '-';

      final hour = int.tryParse(timeParts[0]) ?? 0;
      final minute = int.tryParse(timeParts[1]) ?? 0;

      DateTime bookingDateTime = DateTime(
        booking.bookingDate!.year,
        booking.bookingDate!.month,
        booking.bookingDate!.day,
        hour,
        minute,
      );

      final estimated = bookingDateTime.add(const Duration(hours: 2));
      return DateFormat('HH:mm').format(estimated);
    } catch (e) {
      return '-';
    }
  }

  String formatDate(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('dd MMM yyyy').format(date);
  }

  String formatTime(dynamic time) {
    if (time == null) return '-';
    if (time is DateTime) return DateFormat('HH:mm').format(time);
    if (time is String) return time;
    return '-';
  }

  // ========== ACTION METHODS ==========
  void cancelBooking(BookingsModel booking) {
    Get.dialog(
      AlertDialog(
        title: Text(
          'Batalkan Booking',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Apakah Anda yakin ingin membatalkan booking ${formatBookingId(booking.id)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Batal', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              cancelBookingAPI(booking.id!);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Ya, Batalkan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<bool> checkIncompleteServiceHistory(String bookingId) async {
    try {
      final response = await serviceHistoryProvider.getServiceHistory(
        bookingId,
      );
      if (response.isOk) {
        final serviceHistoryResponse = ServiceHistoryResponse.fromJson(
          response.body,
        );
        if (serviceHistoryResponse.data != null) {
          // Jika status layanan bukan "Selesai", maka masih ada yang harus diselesaikan
          return serviceHistoryResponse.data!.status?.toLowerCase() !=
              'selesai';
        }
      }
      // Jika tidak ada data layanan, return true karena harus ada riwayat servis
      return true;
    } catch (e) {
      debugPrint('Error checking service history: $e');
      return true;
    }
  }

  void _showIncompleteServiceHistoryDialog(BookingsModel booking) {
    CustomModal.showErrorDialog(
      title: "Informasi",
      message:
          "Tidak dapat menyelesaikan booking ${formatBookingId(booking.id)} karena riwayat servis belum Terkonfirmasi/kosong. Silahkan Konfirmasi Riwayat Servis.",
      onConfirm: () {
        Get.back();
        addProgress(booking);
      },
    );
  }

  Future<void> updateStatusBookingAction(
    BookingsModel booking,
    String status,
  ) async {
    // Jika status yang diinginkan adalah "Selesai", cek riwayat servis terlebih dahulu
    if (status.toLowerCase() == 'selesai') {
      bool hasIncompleteHistory = await checkIncompleteServiceHistory(
        booking.id!,
      );
      if (hasIncompleteHistory) {
        _showIncompleteServiceHistoryDialog(booking);
        return;
      }
    }

    CustomModal.showBottomSheet(
      height: Get.height * 0.4,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Update Status Booking',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Apakah Anda yakin ingin mengupdate status booking ${formatBookingId(booking.id)} ke "$status"?',
            style: GoogleFonts.poppins(fontSize: 13),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          ActionSlider.standard(
            toggleColor: ColorTheme.neonYellow,
            backgroundColor: Colors.black,
            child: Text(
              "Geser ke '$status'",
              style: GoogleFonts.poppins(color: ColorTheme.neonYellow),
            ),
            action: (controller) async {
              Get.back();
              controller.loading();
              await updateStatusBooking(booking.id!, status);
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
    // Get.dialog(
    //   AlertDialog(
    //     title: Text(
    //       'Update Status Booking',
    //       style: TextStyle(fontWeight: FontWeight.w600),
    //     ),
    //     content: SizedBox(
    //       width: Get.width,
    //       child: Column(
    //         mainAxisSize: MainAxisSize.min,
    //         children: [
    //           Text(
    //             'Apakah Anda yakin ingin mengupdate status booking ${formatBookingId(booking.id)}?',
    //           ),
    //           SizedBox(height: 10),
    //           ActionSlider.standard(
    //             toggleColor: ColorTheme.neonYellow,
    //             child: Text("Geser untuk update ke '$status"),
    //             action: (controller) async {
    //               Get.back();
    //               controller.loading();
    //               await updateStatusBooking(booking.id!, status);
    //               await Future.delayed(const Duration(seconds: 3));
    //               controller.success();
    //             },
    //           ),
    //         ],
    //       ),
    //     ),
    //     actions: [
    //       Column(
    //         children: [
    //           TextButton(
    //             onPressed: () => Get.back(),
    //             child: Text('Batal', style: TextStyle(color: Colors.grey[600])),
    //           ),
    //         ],
    //       ),
    //       // ElevatedButton(
    //       //   onPressed: () {
    //       //     Get.back();
    //       //     updateStatusBooking(booking.id!, status);
    //       //   },
    //       //   style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
    //       //   child: Text('Ya, Update', style: TextStyle(color: Colors.white)),
    //       // ),
    //     ],
    //   ),
    // );
  }

  // void makeDownPayment(BookingsModel booking) {
  //   Get.dialog(
  //     AlertDialog(
  //       title: Text('Bayar DP', style: TextStyle(fontWeight: FontWeight.w600)),
  //       content: Text(
  //         'Anda akan diarahkan ke halaman pembayaran untuk booking ${formatBookingId(booking.id)}. Lanjutkan?',
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Get.back(),
  //           child: Text('Batal', style: TextStyle(color: Colors.grey[600])),
  //         ),
  //         ElevatedButton(
  //           onPressed: () {
  //             Get.back();
  //             makeDownPaymentAPI(booking.id!);
  //           },
  //           style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
  //           child: Text('Ya, Bayar', style: TextStyle(color: Colors.white)),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  void confirmPickup(BookingsModel booking) {
    Get.dialog(
      AlertDialog(
        title: Text(
          'Konfirmasi Pengambilan',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Konfirmasi bahwa Anda sudah mengambil motor untuk booking ${formatBookingId(booking.id)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Belum', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              // TODO: Implement pickup confirmation API call
              Get.snackbar(
                'Berhasil',
                'Pengambilan motor telah dikonfirmasi',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green[100],
                colorText: Colors.green[800],
              );
            },
            child: Text(
              'Ya, Sudah Diambil',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void contactTechnician(BookingsModel booking) {
    Get.back();
    Get.snackbar(
      'Info',
      'Menghubungi teknisi untuk booking ${formatBookingId(booking.id)}...',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void addProgress(BookingsModel booking) {
    Get.toNamed("/service-history", arguments: booking);
  }

  void rateService(BookingsModel booking) {
    Get.back();
    Get.snackbar(
      'Info',
      'Fitur rating akan segera tersedia',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> fetchServiceHistory(String bookingId) async {
    isLoading.value = true;
    try {
      final response = await serviceHistoryProvider.getServiceHistory(
        bookingId,
      );
      if (response.isOk) {
        final serviceHistoryResponse = ServiceHistoryResponse.fromJson(
          response.body,
        );
        if (serviceHistoryResponse.data != null) {
          serviceHistory.value = [serviceHistoryResponse.data!];
          debugPrint("berhasil fetch service history");

          if (serviceHistory.isNotEmpty &&
              serviceHistory.first.status?.toLowerCase() == 'selesai') {
            debugPrint("Service history selesai");
            // disableForm();
          }
        } else {
          serviceHistory.value = [];
          debugPrint("Service history data kosong");
        }
      } else {
        debugPrint("Gagal fetch service history: ${response.statusCode}");
        CustomSnackbar.error("Error", "Gagal memuat riwayat servis");
      }
    } catch (e) {
      debugPrint('Error fetching service history: $e');
      CustomSnackbar.error("Error", "Terjadi kesalahan: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> downloadInvoice(BookingsModel booking) async {
    try {
      isLoading.value = true;

      if (booking.id != null) {
        await fetchServiceHistory(booking.id!);
      }

      // 1. Ambil data Spareparts
      List<Map<String, dynamic>> sparePartsList = [];
      if (serviceHistory.isNotEmpty &&
          serviceHistory.first.spareParts != null &&
          serviceHistory.first.spareParts!.isNotEmpty) {
        sparePartsList =
            serviceHistory.first.spareParts!
                .map(
                  (part) => {
                    'name': part.name ?? 'Spare Part',
                    'price': part.price ?? 0,
                    'quantity': part.quantity ?? 1,
                  },
                )
                .toList();
      }

      /// 2. EXTRACT LAYANAN DARI bookingDetails (Bukan serviceIds lagi)
      List<String> finalServiceNames = [];
      List<int> finalServicePrices = [];

      if (booking.bookingDetails != null &&
          booking.bookingDetails!.isNotEmpty) {
        for (var detail in booking.bookingDetails!) {
          // Baris 1: Nama Layanan (Pakai bullet point)
          String sName = "- ${detail.serviceName ?? 'Layanan'}";
          // Baris 2: Varian (Turun ke bawah agak menjorok)
          if (detail.selectedVariant != null &&
              detail.selectedVariant!.isNotEmpty) {
            sName += '\n    Varian: ${detail.selectedVariant}';
          }

          // Baris 3: Addons (Turun ke bawah agak menjorok)
          if (detail.selectedAddons != null &&
              detail.selectedAddons!.isNotEmpty) {
            List<String> addonNames =
                detail.selectedAddons!
                    .map((a) => a.name ?? '')
                    .where((n) => n.isNotEmpty)
                    .toList();
            if (addonNames.isNotEmpty) {
              sName += '\n    Addons: ${addonNames.join(', ')}';
            }
          }

          finalServiceNames.add(sName);
          finalServicePrices.add(detail.subtotal?.toInt() ?? 0);
        }
      } else {
        // Fallback jika kosong
        finalServiceNames.add('- Layanan Servis Umum');
        finalServicePrices.add(booking.servicePrice?.toInt() ?? 0);
      }

      // 3. Generate PDF
      await PdfHelper.generateAndDownloadInvoice(
        bookingId: booking.id ?? '-',
        customerName:
            serviceHistory.first.userId!['name'] ?? 'Pelanggan Speedlab',
        status: booking.status ?? '-',
        totalAmount: booking.totalPrice?.toInt() ?? 0,
        date: booking.bookingDate?.toLocal().toString().split(' ')[0] ?? '-',
        servicesName: finalServiceNames, // ✅ Pakai data yang baru diekstrak
        servicesPrice: finalServicePrices, // ✅ Pakai data yang baru diekstrak
        spareParts: sparePartsList.isNotEmpty ? sparePartsList : null,
        serviceHistoryTotalPrice:
            serviceHistory.isNotEmpty && serviceHistory.first.totalPrice != null
                ? serviceHistory.first.totalPrice!
                : null,
      );

      Get.back();
      CustomSnackbar.success("Sukses", "Invoice berhasil diunduh");
    } catch (e) {
      CustomSnackbar.error("Error", "Gagal mengunduh invoice: $e");
      debugPrint('Error download invoice: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
