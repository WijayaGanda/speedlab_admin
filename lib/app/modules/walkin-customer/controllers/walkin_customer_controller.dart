import 'dart:convert';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speedlab_admin/app/data/models/motor_model.dart';
import 'package:speedlab_admin/app/data/models/service_model.dart';
import 'package:intl/intl.dart';
import 'package:speedlab_admin/app/data/providers/auth_provider.dart';
import 'package:speedlab_admin/app/data/providers/bookings_provider.dart';
import 'package:speedlab_admin/app/data/providers/motorcycles_provider.dart';
import 'package:speedlab_admin/app/data/providers/service_provider.dart';
import 'package:speedlab_admin/app/utils/theme/color_theme.dart';
import 'package:speedlab_admin/app/utils/widget/custom_snackbar.dart';

class MotorFormModel {
  final brandCtrl = TextEditingController();
  final modelCtrl = TextEditingController();
  final licensePlateCtrl = TextEditingController();
  final yearCtrl = TextEditingController();
  final colorCtrl = TextEditingController();
  final complaintCtrl = TextEditingController();

  var bookingDate = 'Pilih Tanggal'.obs;
  var bookingTime = 'Pilih Waktu'.obs;
  var selectedDateTime = Rxn<DateTime>();
  var selectedServices = <ServiceModel>[].obs;
}

class WalkinCustomerController extends GetxController {
  final BookingsProvider provider;
  final ServiceProvider serviceProvider;
  final AuthProvider authProvider;
  final MotorcyclesProvider motorcyclesProvider;
  final BookingsProvider bookingsProvider;

  WalkinCustomerController({
    required this.provider,
    required this.serviceProvider,
    required this.authProvider,
    required this.motorcyclesProvider,
    required this.bookingsProvider,
  });

  var currentStep = 0.obs;
  var selectedDateTime = Rxn<DateTime>();
  var isTimeSelected = false.obs;
  var isLoading = false.obs;

  var availableServices = <ServiceModel>[].obs;
  var selectedService = <ServiceModel>[].obs;

  var bookedTimes = <DateTime>[].obs;
  var isLoadingTimeslots = false.obs;

  String get bookingDate =>
      selectedDateTime.value != null
          ? DateFormat('dd/MM/yyyy').format(selectedDateTime.value!)
          : '';

  String get bookingTime =>
      isTimeSelected.value && selectedDateTime.value != null
          ? DateFormat('HH:mm').format(selectedDateTime.value!)
          : '';

  void nextStep() {
    if (currentStep.value < 2) {
      currentStep.value++;
    }
  }

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final addressCtrl = TextEditingController();

  var listMotorForm = <MotorFormModel>[MotorFormModel()].obs;

  void addMotor() {
    listMotorForm.add(MotorFormModel());
  }

  void removeMotor(int index) {
    if (listMotorForm.length > 1) {
      listMotorForm.removeAt(index);
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchAvailableServices();
  }

  //Fetch layanan dari API
  Future<void> fetchAvailableServices() async {
    try {
      isLoading.value = true;
      final response = await serviceProvider.fetchServices();
      if (response.isOk && response.body != null) {
        availableServices.value = List<ServiceModel>.from(
          response.body['data'].map((x) => ServiceModel.fromJson(x)),
        );
      } else {
        CustomSnackbar.error(
          "Error",
          response.body?['message'] ?? 'Gagal mengambil data layanan',
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  void toggleService(int motorIndex, ServiceModel service, bool isChecked) {
    final formUI = listMotorForm[motorIndex];
    if (isChecked) {
      formUI.selectedServices.add(service);
    } else {
      formUI.selectedServices.removeWhere((s) => s.id == service.id);
    }
  }

  /// Filter layanan berdasarkan search query
  List<ServiceModel> filterServices(String query) {
    if (query.isEmpty) {
      return availableServices;
    }

    final lowerQuery = query.toLowerCase();
    return availableServices.where((service) {
      final name = service.name.toLowerCase();
      final description = service.description.toLowerCase();
      return name.contains(lowerQuery) || description.contains(lowerQuery);
    }).toList();
  }

  // --- LOGIKA BOOKING & WAKTU ---
  // Method untuk memilih tanggal
  Future<void> pickDate(BuildContext context, int index) async {
    final formUI = listMotorForm[index];
    final currentDateTime = formUI.selectedDateTime.value ?? DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      // Set tanggal baru, reset waktu agar user harus pilih ulang
      formUI.selectedDateTime.value = DateTime(
        picked.year,
        picked.month,
        picked.day,
        0,
        0,
      );

      formUI.bookingDate.value = DateFormat('dd/MM/yyyy').format(picked);
      formUI.bookingTime.value = 'Pilih Waktu';

      listMotorForm.refresh();

      // Fetch booked times untuk tanggal yang dipilih
      await fetchBookedTimes(picked);
    }
  }

  // --- LOGIKA LAYANAN (DITUNGGU VS DITINGGAL) ---
  bool isMotorMustBeLeft(int motorIndex) {
    final formUI = listMotorForm[motorIndex];
    if (formUI.selectedServices.isEmpty) return false;

    // Jika ada 1 saja layanan yang isWaitable == false, maka HARUS ditinggal
    for (var service in formUI.selectedServices) {
      if (service.isWaitable == false) return true;
    }
    return false;
  }

  Future<void> fetchBookedTimes(DateTime date) async {
    try {
      isLoadingTimeslots.value = true;
      final response = await provider.fetchBookingsByDate(date);

      if (response.isOk && response.body != null) {
        final bookings = response.body['data'] ?? [];
        final times = <DateTime>[];

        // Parse booked times dari response - hanya ambil yang belum dibatalkan
        for (var booking in bookings) {
          // Filter berdasarkan status - skip jika booking dibatalkan
          final status =
              booking['status']?.toString().toLowerCase() ?? 'confirmed';
          if (status == 'dibatalkan' || status == 'pending_cancellation') {
            debugPrint(
              "⏭️  Skipping cancelled booking at ${booking['bookingDate']}",
            );
            continue;
          }

          if (booking['bookingDate'] != null) {
            try {
              final bookedDateTime = DateTime.parse(booking['bookingDate']);
              times.add(bookedDateTime);
            } catch (e) {
              debugPrint("Error parsing booking date: $e");
            }
          }
        }

        bookedTimes.value = times;
        debugPrint(
          "🕐 Booked times for ${DateFormat('dd/MM/yyyy').format(date)}: ${times.length} slots",
        );
      } else {
        bookedTimes.value = [];
      }
    } catch (e) {
      debugPrint("❌ Error fetching booked times: $e");
      bookedTimes.value = [];
    } finally {
      isLoadingTimeslots.value = false;
    }
  }

  /// Get list of available time slots (8 AM - 3 PM)
  List<DateTime> getAvailableTimeSlots() {
    final currentDateTime = selectedDateTime.value ?? DateTime.now();
    final slots = <DateTime>[];

    // Create slots from 8 AM to 3 PM (15:00)
    for (int hour = 8; hour < 15; hour++) {
      final slot = DateTime(
        currentDateTime.year,
        currentDateTime.month,
        currentDateTime.day,
        hour,
        0,
      );
      slots.add(slot);
    }

    return slots;
  }

  /// Check if a time slot is booked
  bool isTimeSlotBooked(DateTime timeSlot) {
    return bookedTimes.any((bookedTime) {
      return bookedTime.year == timeSlot.year &&
          bookedTime.month == timeSlot.month &&
          bookedTime.day == timeSlot.day &&
          bookedTime.hour == timeSlot.hour;
    });
  }

  /// Check if a time slot is disabled (booked or already passed)
  bool isTimeSlotDisabled(DateTime timeSlot) {
    final now = DateTime.now();
    final isToday =
        timeSlot.year == now.year &&
        timeSlot.month == now.month &&
        timeSlot.day == now.day;

    // Jika hari ini, check apakah slot sudah lewat dari waktu sekarang
    if (isToday && timeSlot.hour <= now.hour) {
      return true;
    }

    // Check apakah sudah ada booking di slot tersebut
    return isTimeSlotBooked(timeSlot);
  }

  Future<void> pickTime(BuildContext context, int index) async {
    final formUI = listMotorForm[index];
    // Refresh booked times sebelum menampilkan dialog
    if (formUI.selectedDateTime.value != null) {
      await fetchBookedTimes(formUI.selectedDateTime.value!);
    }

    selectedDateTime.value = formUI.selectedDateTime.value;

    final timeSlots = getAvailableTimeSlots();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Pilih Jam Booking',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Jam Operasional: 08:00 - 15:00',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                Obx(
                  () =>
                      isLoadingTimeslots.value
                          ? const SizedBox(
                            height: 200,
                            child: Center(child: CircularProgressIndicator()),
                          )
                          : SizedBox(
                            height: 250,
                            child: GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    childAspectRatio: 1.2,
                                    mainAxisSpacing: 8,
                                    crossAxisSpacing: 8,
                                  ),
                              itemCount: timeSlots.length,
                              itemBuilder: (context, idx) {
                                final timeSlot = timeSlots[idx];
                                final isDisabled = isTimeSlotDisabled(timeSlot);
                                final isBooked = isTimeSlotBooked(timeSlot);
                                final isPassed =
                                    timeSlot.hour <= DateTime.now().hour &&
                                    timeSlot.year == DateTime.now().year &&
                                    timeSlot.month == DateTime.now().month &&
                                    timeSlot.day == DateTime.now().day;
                                final isSelected =
                                    formUI.selectedDateTime.value?.hour ==
                                    timeSlot.hour;

                                return Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap:
                                        isDisabled
                                            ? null
                                            : () {
                                              formUI.selectedDateTime.value =
                                                  timeSlot;
                                              formUI
                                                  .bookingTime
                                                  .value = DateFormat(
                                                'HH:mm',
                                              ).format(timeSlot);
                                              listMotorForm.refresh();
                                              Navigator.pop(context);
                                            },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color:
                                            isDisabled
                                                ? Colors.grey[300]
                                                : isSelected
                                                ? ColorTheme.primary
                                                : Colors.white,
                                        border: Border.all(
                                          color:
                                              isDisabled
                                                  ? Colors.grey[400]!
                                                  : isSelected
                                                  ? ColorTheme.primary
                                                  : Colors.grey[300]!,
                                          width: 1.5,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            DateFormat(
                                              'HH:mm',
                                            ).format(timeSlot),
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  isDisabled
                                                      ? Colors.grey[600]
                                                      : isSelected
                                                      ? Colors.white
                                                      : Colors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            isDisabled
                                                ? (isPassed ? 'Lewat' : 'Penuh')
                                                : 'Tersedia',
                                            style: GoogleFonts.poppins(
                                              fontSize: 10,
                                              color:
                                                  isDisabled
                                                      ? Colors.grey[500]
                                                      : isSelected
                                                      ? Colors.white
                                                      : Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Batal',
                    style: GoogleFonts.poppins(color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  //submit ke API
  Future<void> submitWalkInCustomer() async {
    try {
      isLoading.value = true;
      //Register pelanggan
      String phone = phoneCtrl.text;
      String defaulltPassword = "Speedlab${phone.substring(phone.length - 4)}";
      final response = await authProvider.register({
        "name": nameCtrl.text,
        "email": emailCtrl.text,
        "password": defaulltPassword,
        "phone": phone,
        "address": addressCtrl.text,
        "role": "pelanggan",
      });

      if (response.statusCode != 201 && response.statusCode != 200) {
        debugPrint("Failed to register customer: ${response.body}");
      }

      final userId = response.body['data']['_id'];

      for (int i = 0; i < listMotorForm.length; i++) {
        final formUI = listMotorForm[i];
        MotorModel motorData = MotorModel(
          userId: userId,
          brand: formUI.brandCtrl.text,
          model: formUI.modelCtrl.text,
          year:
              int.tryParse(formUI.yearCtrl.text) ?? 2026, // Convert text ke int
          licensePlate: formUI.licensePlateCtrl.text,
          color: formUI.colorCtrl.text,
        );

        final motorResponse = await motorcyclesProvider.addMotorCycles(
          motorData.toJson(),
        );
        if (motorResponse.statusCode != 201 &&
            motorResponse.statusCode != 200) {
          debugPrint(
            "Gagal menambahkan motor untuk plat ${formUI.licensePlateCtrl.text}: ${motorResponse.body}",
          );
        }

        final dataMotor = motorResponse.body;
        final motorId = dataMotor['data']['_id'];

        List<String> serviceIds =
            formUI.selectedServices.map((s) => s.id.toString()).toList();
        debugPrint("🛠️ DEBUG - Motor $i Service IDs: $serviceIds");
        DateTime finalDateTime =
            formUI.selectedDateTime.value ?? DateTime.now();
        String finalTime = formUI.bookingTime.value;
        if (finalTime == "Pilih Waktu" || isMotorMustBeLeft(i)) {
          finalTime = DateFormat("HH:mm").format(DateTime.now());
        }

        String formatIsoBackend = finalDateTime.toIso8601String();

        final bookingResponse = await bookingsProvider.addBooking({
          "motorcycleId": motorId,
          "serviceIds": serviceIds,
          "bookingDate": formatIsoBackend,
          "bookingTime": formatIsoBackend,
          "complaint": formUI.complaintCtrl.text,
          // "notes": true,
        });

        if (bookingResponse.statusCode != 201 &&
            bookingResponse.statusCode != 200) {
          debugPrint(
            "Gagal membuat booking untuk plat ${formUI.licensePlateCtrl.text}: ${bookingResponse.body}",
          );
        }
        Get.offAllNamed('/dashboard');
        CustomSnackbar.success(
          "Sukses",
          "Berhasil submit booking untuk plat ${formUI.licensePlateCtrl.text}",
        );
      }
    } catch (e) {
      debugPrint("Error submitting walk-in customer: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
