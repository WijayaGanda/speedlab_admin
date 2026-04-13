import 'package:action_slider/action_slider.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speedlab_admin/app/data/models/bookings_model.dart';
import 'package:speedlab_admin/app/data/models/service_history_model.dart';
import 'package:speedlab_admin/app/data/providers/bookings_provider.dart';
import 'package:speedlab_admin/app/data/providers/service_history_provider.dart';
import 'package:speedlab_admin/app/utils/theme/color_theme.dart';
import 'package:speedlab_admin/app/utils/widget/custom_modal.dart';
import 'package:speedlab_admin/app/utils/widget/custom_snackbar.dart';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';

class BookingListController extends GetxController {
  final BookingsProvider provider;
  final ServiceHistoryProvider serviceHistoryProvider;

  BookingListController({
    required this.provider,
    required this.serviceHistoryProvider,
  });

  var bookings = <BookingsModel>[].obs;
  var serviceHistory = <ServiceHistoryModel>[].obs;
  var isLoading = false.obs;
  var isProcessingPayment = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBookings();
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
        Get.snackbar("Error API (${response.statusCode})", errorMsg);
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memperbarui status booking');
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
        Get.snackbar("Error API (${response.statusCode})", errorMsg);
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal membatalkan booking');
    } finally {
      isLoading.value = false;
    }
  }

  // Future<void> makeDownPaymentAPI(String? id) async {
  //   debugPrint("=== ID BOOKING YANG MAU DIBAYAR: $id ===");

  //   if (id == null || id.isEmpty) {
  //     Get.snackbar("Error", "ID Booking tidak ditemukan!");
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
    if (booking.serviceIds == null || booking.serviceIds!.isEmpty) return '';

    List<String> serviceNames = [];
    for (var service in booking.serviceIds!) {
      if (service is Map && service['name'] != null) {
        serviceNames.add(service['name']);
      }
    }
    return serviceNames.join(', ');
  }

  // ========== FORMATTING METHODS ==========
  String formatDateTime(BookingsModel booking) {
    if (booking.bookingDate == null || booking.bookingTime == null) return '';

    final dateFormat = DateFormat('dd MMM yyyy');
    final timeFormat = DateFormat('HH:mm');
    return '${dateFormat.format(booking.bookingDate!)}, ${timeFormat.format(booking.bookingTime!)} WIB';
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
    if (booking.bookingTime == null) return '-';
    final estimated = booking.bookingTime!.add(const Duration(hours: 2));
    return DateFormat('HH:mm').format(estimated);
  }

  String formatDate(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('dd MMM yyyy').format(date);
  }

  String formatTime(DateTime? time) {
    if (time == null) return '-';
    return DateFormat('HH:mm').format(time);
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

  //   void downloadInvoice(BookingsModel booking) {
  //     Get.back();
  //     // Get.snackbar(
  //     //   'Info',
  //     //   'Mengunduh invoice untuk booking ${formatBookingId(booking.id)}...',
  //     //   snackPosition: SnackPosition.BOTTOM,
  //     //   backgroundColor: Colors.blue[100],
  //     //   colorText: Colors.blue[800],
  //     // );
  //     PdfHelper.generateAndDownloadInvoice(
  //       bookingId: booking.id ?? '-',
  //       customerName: authService.user.value?.name ?? 'Pelanggan Speedlab',
  //       status: booking.status ?? '-',
  //       totalAmount: booking.totalPrice ?? 0,
  //       date: booking.bookingDate?.toLocal().toString().split(' ')[0] ?? '-',
  //       servicesName:
  //           booking.serviceIds != null
  //               ? booking.serviceIds!
  //                   .map(
  //                     (s) =>
  //                         s is Map && s['name'] != null ? s['name'] : 'Layanan',
  //                   )
  //                   .toList()
  //               : ['Layanan'],
  //       servicesPrice:
  //           booking.serviceIds != null
  //               ? booking.serviceIds!
  //                   .map((s) => s is Map && s['price'] != null ? s['price'] : 0)
  //                   .toList()
  //               : [0],
  //     );
  //   }
  // }
}
