import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:speedlab_admin/app/data/models/bookings_model.dart';
import 'package:speedlab_admin/app/data/providers/bookings_provider.dart';
import 'package:speedlab_admin/app/data/services/auth_service.dart';
import 'package:speedlab_admin/app/data/services/fcm_service.dart';
import 'package:flutter/material.dart';
import 'package:speedlab_admin/app/utils/widget/custom_snackbar.dart';

class HomeController extends GetxController {
  final authService = Get.find<AuthService>();
  final BookingsProvider provider;

  HomeController({required this.provider});

  var isLoading = false.obs;
  var bookings = <BookingsModel>[].obs;

  int get totalBookings => bookings.length;

  int get menungguVerifikasi =>
      bookings
          .where((b) => b.status?.toLowerCase() == "menunggu verifikasi")
          .length;

  int get bookingsVerifikasi =>
      bookings.where((b) => b.status?.toLowerCase() == "terverifikasi").length;

  int get bookingsDikerjakan =>
      bookings
          .where((b) => b.status?.toLowerCase() == "sedang dikerjakan")
          .length;

  int get bookingsSelesai =>
      bookings.where((b) => b.status?.toLowerCase() == 'selesai').length;

  int get bookingsDibatalkan =>
      bookings.where((b) => b.status?.toLowerCase() == 'dibatalkan').length;

  @override
  void onInit() {
    super.onInit();
    fetchAllBookings();
  }

  Future<void> fetchAllBookings() async {
    try {
      isLoading.value = true;
      final response = await provider.fetchAllBookings();
      if (response.statusCode == 200) {
        final bookingsResponse = BookingsResponse.fromJson(response.body);
        // bookings.value = bookingsResponse.data ?? [];
        bookings.assignAll(bookingsResponse.data ?? []);
      } else {
        CustomSnackbar.error('Error', 'Failed to fetch bookings');
      }
    } catch (e) {
      CustomSnackbar.error('Error', 'An error occurred: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void walkin() {
    Get.toNamed('/walkin-customer');
  }

  void moveToNotifications() async {
    Get.toNamed('/notification');
  }

  void logout() async {
    // 1. Amankan proses FCM dengan try-catch
    try {
      final String? fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        await Get.find<FCMService>().unregisterFcmToken(fcmToken);
        debugPrint("🔔 Token FCM berhasil dihapus dari backend.");
      }
      await FirebaseMessaging.instance.deleteToken();
      debugPrint("🗑️ Cache token FCM lokal berhasil dihancurkan.");
    } catch (e) {
      // Jika error SERVICE_NOT_AVAILABLE muncul, sistem akan masuk ke sini
      debugPrint("⚠️ Gagal memproses FCM saat logout: $e");
    }

    // 2. Proses logout lokal dan navigasi AKAN TETAP JALAN meskipun FCM error
    authService.logout();
    Get.offAllNamed('/login');
  }
}
