import 'package:get/get.dart';
import 'package:speedlab_admin/app/data/models/operating_hours_model.dart';
import 'package:speedlab_admin/app/data/providers/bookings_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:speedlab_admin/app/utils/widget/custom_snackbar.dart';

class DeteOverrideController extends GetxController {
  final BookingsProvider provider;
  DeteOverrideController({required this.provider});

  var selectedDate = Rxn<DateTime>();
  var isOpen = true.obs;
  final noteCtrl = TextEditingController();
  var timeSlots = <TimeSlot>[].obs;

  var isLoading = false.obs;
  var isSaving = false.obs;

  String get formattedDateText =>
      selectedDate.value != null
          ? DateFormat('dd/MM/yyyy').format(selectedDate.value!)
          : 'Pilih Tanggal Terlebih Dahulu';

  void onDateSelected(DateTime date) async {
    selectedDate.value = date;
    String dateStr = DateFormat('yyyy-MM-dd').format(date);

    try {
      isLoading.value = true;
      timeSlots.clear();
      noteCtrl.clear();

      final response = await provider.getExceptionByDate(dateStr);
      if (response.isOk && response.body['data'] != null) {
        var data = response.body['data'];
        isOpen.value = data['isOpen'] ?? false;
        noteCtrl.text = data['note'] ?? '';
        if (data['timeSlots'] != null) {
          timeSlots.value = List<TimeSlot>.from(
            data['timeSlots'].map((x) => TimeSlot.fromJson(x)),
          );
        }
      } else {
        // Default jika tanggal belum pernah diubah
        isOpen.value = true;
        timeSlots.add(TimeSlot(openTime: "09:00", closeTime: "17:00"));
      }
    } catch (e) {
      CustomSnackbar.error("Error", "Gagal memuat status tanggal");
    } finally {
      isLoading.value = false;
    }
  }

  void addTimeSlot() {
    timeSlots.add(TimeSlot(openTime: "09:00", closeTime: "12:00"));
  }

  void removeTimeSlot(int index) {
    timeSlots.removeAt(index);
  }

  Future<void> pickTime(
    BuildContext context,
    int index,
    bool isOpenTime,
  ) async {
    String currentTimeStr =
        isOpenTime ? timeSlots[index].openTime : timeSlots[index].closeTime;
    int currentHour = int.parse(currentTimeStr.split(':')[0]);
    int currentMinute = int.parse(currentTimeStr.split(':')[1]);

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: currentHour, minute: currentMinute),
      builder:
          (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          ),
    );

    if (picked != null) {
      String formattedTime =
          "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
      var currentSlots = List<TimeSlot>.from(timeSlots);

      if (isOpenTime) {
        currentSlots[index] = TimeSlot(
          openTime: formattedTime,
          closeTime: currentSlots[index].closeTime,
        );
      } else {
        currentSlots[index] = TimeSlot(
          openTime: currentSlots[index].openTime,
          closeTime: formattedTime,
        );
      }
      timeSlots.value = currentSlots;
    }
  }

  Future<void> saveSettings() async {
    if (selectedDate.value == null) return;
    try {
      isSaving.value = true;
      String dateStr = DateFormat('yyyy-MM-dd').format(selectedDate.value!);

      final payload = {
        "date": dateStr,
        "isOpen": isOpen.value,
        "note": noteCtrl.text,
        "timeSlots":
            isOpen.value ? timeSlots.map((e) => e.toJson()).toList() : [],
      };

      final response = await provider.saveExceptionDate(payload);
      if (response.isOk) {
        CustomSnackbar.success(
          "Sukses",
          "Pengaturan tanggal berhasil disimpan",
        );
      }
      print("Response: ${response.body}");
    } catch (e) {
      CustomSnackbar.error("Error", "Gagal menyimpan data");
    } finally {
      isSaving.value = false;
    }
  }
}
