import 'package:get/get.dart';
import 'package:speedlab_admin/app/data/models/operating_hours_model.dart';
import 'package:speedlab_admin/app/data/providers/bookings_provider.dart';
import 'package:speedlab_admin/app/modules/dete_override/controllers/dete_override_controller.dart';
import 'package:speedlab_admin/app/utils/widget/custom_snackbar.dart';
import 'package:flutter/material.dart';

class OperatingHourController extends GetxController {
  final BookingsProvider provider;

  OperatingHourController({required this.provider});

  var operatingHours = <OperatingHourModel>[].obs;
  var isLoading = false.obs;
  var isSaving = false.obs;
  final dateOverrideCtrl = Get.put<DeteOverrideController>(
    DeteOverrideController(provider: Get.find<BookingsProvider>()),
  );

  @override
  void onInit() {
    super.onInit();
    fetchOperatingHours();
  }

  Future<void> fetchOperatingHours() async {
    try {
      isLoading.value = true;
      final response = await provider.fetchOperatingHours();
      if (response.isOk && response.body != null) {
        operatingHours.value = List<OperatingHourModel>.from(
          response.body['data'].map((x) => OperatingHourModel.fromJson(x)),
        );
      }
    } catch (e) {
      CustomSnackbar.error("Error", "Gagal memuat jadwal operasional");
    } finally {
      isLoading.value = false;
    }
  }

  // Mengubah status Buka/Tutup hari
  void toggleDayStatus(int index, bool value) {
    // Buat salinan objek yang baru untuk memicu reaktivitas Obx
    var day = operatingHours[index];
    operatingHours[index] = OperatingHourModel(
      id: day.id, // Pastikan model Anda punya field id (_id dari MongoDB)
      dayIndex: day.dayIndex,
      dayName: day.dayName,
      isOpen: value,
      timeSlots: day.timeSlots,
    );
  }

  // Menambah slot waktu baru (default 09:00 - 12:00)
  void addTimeSlot(int dayIndex) {
    var day = operatingHours[dayIndex];
    var newSlots = List<TimeSlot>.from(day.timeSlots)
      ..add(TimeSlot(openTime: "09:00", closeTime: "12:00"));

    operatingHours[dayIndex] = OperatingHourModel(
      id: day.id,
      dayIndex: day.dayIndex,
      dayName: day.dayName,
      isOpen: day.isOpen,
      timeSlots: newSlots,
    );
  }

  // Menghapus slot waktu
  void removeTimeSlot(int dayIndex, int slotIndex) {
    var day = operatingHours[dayIndex];
    var newSlots = List<TimeSlot>.from(day.timeSlots)..removeAt(slotIndex);

    operatingHours[dayIndex] = OperatingHourModel(
      id: day.id,
      dayIndex: day.dayIndex,
      dayName: day.dayName,
      isOpen: day.isOpen,
      timeSlots: newSlots,
    );
  }

  // Menampilkan TimePicker dan memperbarui jam
  Future<void> pickTime(
    BuildContext context,
    int dayIndex,
    int slotIndex,
    bool isOpenTime,
  ) async {
    var currentSlots = operatingHours[dayIndex].timeSlots;
    String currentTimeStr =
        isOpenTime
            ? currentSlots[slotIndex].openTime
            : currentSlots[slotIndex].closeTime;

    int currentHour = int.parse(currentTimeStr.split(':')[0]);
    int currentMinute = int.parse(currentTimeStr.split(':')[1]);

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: currentHour, minute: currentMinute),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // Format ke HH:mm
      String formattedTime =
          "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";

      var newSlots = List<TimeSlot>.from(currentSlots);
      if (isOpenTime) {
        newSlots[slotIndex] = TimeSlot(
          openTime: formattedTime,
          closeTime: newSlots[slotIndex].closeTime,
        );
      } else {
        newSlots[slotIndex] = TimeSlot(
          openTime: newSlots[slotIndex].openTime,
          closeTime: formattedTime,
        );
      }

      var day = operatingHours[dayIndex];
      operatingHours[dayIndex] = OperatingHourModel(
        id: day.id,
        dayIndex: day.dayIndex,
        dayName: day.dayName,
        isOpen: day.isOpen,
        timeSlots: newSlots,
      );
    }
  }

  // Simpan perubahan ke Node.js
  Future<void> saveSchedule() async {
    try {
      isSaving.value = true;
      // Kirim update satu per satu untuk setiap hari
      for (var day in operatingHours) {
        final response = await provider.updateOperatingHours(day.id!, {
          "isOpen": day.isOpen,
          "timeSlots": day.timeSlots.map((e) => e.toJson()).toList(),
        });
        print("STATUS NODEJS: ${response.statusCode} - ${response.bodyString}");
      }
      // print("STATUS NODEJS: ${response.statusCode} - ${response.bodyString}");
      CustomSnackbar.success(
        "Sukses",
        "Jadwal operasional berhasil diperbarui!",
      );
    } catch (e) {
      CustomSnackbar.error("Error", "Gagal menyimpan jadwal");
    } finally {
      isSaving.value = false;
    }
  }
}
