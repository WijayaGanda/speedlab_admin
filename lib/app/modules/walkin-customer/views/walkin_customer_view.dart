import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speedlab_admin/app/utils/theme/color_theme.dart';
import 'package:speedlab_admin/app/utils/widget/custom_modal.dart';
import 'package:speedlab_admin/app/utils/widget/custom_textfield.dart';
import 'package:speedlab_admin/app/utils/widget/info_card.dart';

import '../controllers/walkin_customer_controller.dart';

class WalkinCustomerView extends GetView<WalkinCustomerController> {
  const WalkinCustomerView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WalkinCustomerView'),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return Stepper(
          type: StepperType.vertical,
          currentStep: controller.currentStep.value,
          onStepContinue: () {
            if (controller.currentStep.value == 2) {
              ConfirmationDialog.show(
                title: "Konfirmasi",
                message:
                    "Apakah Anda yakin ingin mengirimkan data ini? Silahkan Cek kembali sebelum submit.",
                onConfirm: () {
                  controller.submitWalkInCustomer();
                },
              );
            } else {
              controller.nextStep();
            }
          },
          onStepCancel: controller.previousStep,

          controlsBuilder: (context, details) {
            return Row(
              children: [
                ElevatedButton(
                  onPressed: details.onStepContinue,
                  child: Text(
                    controller.currentStep.value == 2 ? 'Submit' : 'Lanjut',
                  ),
                ),
                const SizedBox(width: 10),
                if (controller.currentStep.value > 0)
                  TextButton(
                    onPressed: details.onStepCancel,
                    child: const Text('Kembali'),
                  ),
              ],
            );
          },

          steps: [
            Step(
              title: const Text('Data Pelanggan'),
              content: Column(
                children: [
                  CustomTextField(
                    controller: controller.nameCtrl,
                    labelText: "Nama Lengkap",
                    prefixIcon: Icons.person,
                    isObscure: false,
                    hintText: "Contoh: John Doe",
                  ),
                  CustomTextField(
                    controller: controller.emailCtrl,
                    labelText: "Email",
                    prefixIcon: Icons.email,
                    isObscure: false,
                    hintText: "Contoh: johndoe@example.com",
                  ),
                  CustomTextField(
                    controller: controller.phoneCtrl,
                    labelText: "Nomor Telepon",
                    prefixIcon: Icons.phone,
                    isObscure: false,
                    hintText: "Contoh: 081234567890",
                  ),
                  CustomTextField(
                    controller: controller.addressCtrl,
                    labelText: "Address",
                    hintText: "Masukkan alamat anda",
                    prefixIcon: Icons.home,
                    iconLabel: Icons.location_city,
                    isObscure: false,
                  ),
                ],
              ),
              isActive: controller.currentStep.value >= 0,
            ),
            Step(
              title: const Text('Data Motor'),
              content: Column(
                children: [
                  // 1. Tampilkan List Form Motor pakai Obx
                  Obx(
                    () => Column(
                      children: List.generate(controller.listMotorForm.length, (
                        index,
                      ) {
                        final motorForm = controller.listMotorForm[index];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 15),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Motor Ke-${index + 1}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    // Tombol Hapus (Muncul kalau form lebih dari 1)
                                    if (controller.listMotorForm.length > 1)
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed:
                                            () => controller.removeMotor(index),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                // TextField ambil controllernya dari class MotorFormModel
                                CustomTextField(
                                  controller: motorForm.brandCtrl,
                                  labelText: "Merek Motor",
                                  prefixIcon: Icons.motorcycle,
                                  iconLabel: Icons.branding_watermark,
                                  isObscure: false,
                                  hintText: "Contoh: Honda, Yamaha, Suzuki",
                                ),
                                CustomTextField(
                                  controller: motorForm.modelCtrl,
                                  labelText: "Model Motor",
                                  prefixIcon: Icons.motorcycle,
                                  iconLabel: Icons.model_training,
                                  isObscure: false,
                                  hintText: "Contoh: CBR, Vario, Nmax",
                                ),
                                CustomTextField(
                                  controller: motorForm.yearCtrl,
                                  labelText: "Tahun Motor",
                                  prefixIcon: Icons.motorcycle,
                                  iconLabel: Icons.calendar_today,
                                  isObscure: false,
                                  hintText: "Contoh: 2020, 2021, 2022",
                                ),
                                CustomTextField(
                                  controller: motorForm.licensePlateCtrl,
                                  labelText: "Plat Nomor",
                                  prefixIcon: Icons.motorcycle,
                                  iconLabel: Icons.numbers,
                                  isObscure: false,
                                  hintText: "Contoh: B 1234 AB",
                                ),
                                CustomTextField(
                                  controller: motorForm.colorCtrl,
                                  labelText: "Warna Motor",
                                  prefixIcon: Icons.motorcycle,
                                  iconLabel: Icons.color_lens,
                                  isObscure: false,
                                  hintText: "Contoh: Merah, Biru, Hitam",
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  // 2. Tombol untuk Menambah Form Motor Baru
                  TextButton.icon(
                    onPressed: () => controller.addMotor(),
                    icon: const Icon(Icons.add_circle),
                    label: const Text("Tambah Motor Lain"),
                  ),
                ],
              ),
              isActive: controller.currentStep.value >= 1,
            ),
            Step(
              title: const Text('Jadwal & Layanan'),
              isActive: controller.currentStep.value >= 2,
              content: Column(
                children: List.generate(controller.listMotorForm.length, (
                  index,
                ) {
                  final formUI = controller.listMotorForm[index];
                  String platNomor =
                      formUI.licensePlateCtrl.text.isNotEmpty
                          ? formUI.licensePlateCtrl.text
                          : "Motor ${index + 1}";

                  return Card(
                    // color: Colors.blue.shade50,
                    margin: const EdgeInsets.only(bottom: 15),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Pengaturan: $platNomor",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const Divider(),

                          // --- PILIH LAYANAN ---
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Pilih Layanan:",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.add_circle_outline,
                                  // color: ColorTheme.secondaryColor,
                                ),
                                onPressed: () {
                                  CustomModal.showBottomSheetWithSearch(
                                    height: Get.height * 0.7,
                                    title: "Layanan Yang Tersedia",
                                    searchHint: "Cari layanan...",
                                    contentBuilder: (searchQuery) {
                                      return Obx(() {
                                        if (controller.isLoading.value) {
                                          return const Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        }

                                        // Filter services based on search query
                                        final filteredServices = controller
                                            .filterServices(searchQuery);

                                        if (filteredServices.isEmpty) {
                                          return Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.search_off,
                                                  size: 64,
                                                  color: Colors.grey[400],
                                                ),
                                                const SizedBox(height: 16),
                                                Text(
                                                  searchQuery.isEmpty
                                                      ? "Tidak ada layanan tersedia"
                                                      : "Tidak ada hasil untuk \"$searchQuery\"",
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 16,
                                                    color: Colors.grey[600],
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            ),
                                          );
                                        }

                                        return ListView.builder(
                                          itemCount: filteredServices.length,
                                          itemBuilder: (context, serviceindex) {
                                            final service =
                                                filteredServices[serviceindex];
                                            return Card(
                                              elevation: 15,
                                              color: Colors.white,
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 5,
                                                  ),
                                              child: Obx(() {
                                                bool isSelected = formUI
                                                    .selectedServices
                                                    .any(
                                                      (item) =>
                                                          item.id == service.id,
                                                    );

                                                return CheckboxListTile(
                                                  title: Text(
                                                    service.name,
                                                    style: GoogleFonts.poppins(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  subtitle: Text(
                                                    service.description,
                                                    style:
                                                        GoogleFonts.poppins(),
                                                  ),
                                                  value: isSelected,
                                                  onChanged: (bool? value) {
                                                    controller.toggleService(
                                                      index,
                                                      service,
                                                      value ?? false,
                                                    );
                                                  },
                                                  activeColor:
                                                      ColorTheme.primary,
                                                  controlAffinity:
                                                      ListTileControlAffinity
                                                          .leading,
                                                );
                                              }),
                                            );
                                          },
                                        );
                                      });
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 10),

                          Obx(() {
                            if (formUI.selectedServices.isEmpty) {
                              // Tampilkan teks info jika belum ada yang dipilih
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15.0,
                                ),
                                child: Text(
                                  "*Belum ada layanan yang dipilih",
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.redAccent,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              );
                            }

                            // Tampilkan list card layanan yang sudah dipilih
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15.0,
                                vertical: 10,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Layanan Terpilih:",
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Looping data selectedService untuk dibuatkan List
                                  ...formUI.selectedServices.map((service) {
                                    return Container(
                                      margin: const EdgeInsets.only(
                                        bottom: 8.0,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 15,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: ColorTheme.primary.withValues(
                                            alpha: 0.3,
                                          ),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withValues(
                                              alpha: 0.1,
                                            ),
                                            spreadRadius: 1,
                                            blurRadius: 3,
                                            offset: const Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons
                                                .build_circle, // Icon opsional buat pemanis
                                            color: ColorTheme.secondaryColor,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              service
                                                  .name, // Sesuaikan dengan property model kamu
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          // Tombol untuk hapus layanan langsung dari luar
                                          InkWell(
                                            onTap: () {
                                              // Memanggil fungsi toggleService untuk membatalkan pilihan
                                              controller.toggleService(
                                                index,
                                                service,
                                                false,
                                              );
                                            },
                                            child: const Icon(
                                              Icons.remove_circle_outline,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(), // Ubah iterable map menjadi list
                                ],
                              ),
                            );
                          }),

                          const SizedBox(height: 10),
                          // --- PILIH TANGGAL (Selalu Muncul) ---
                          InkWell(
                            onTap: () => controller.pickDate(context, index),
                            child: Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: ColorTheme.darkBgPrimary,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today,
                                    color: ColorTheme.secondaryColor,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Obx(
                                      () => Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Tanggal Booking",
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: Colors.black54,
                                            ),
                                          ),
                                          Text(
                                            formUI.selectedDateTime.value !=
                                                    null
                                                ? formUI.bookingDate.value
                                                : 'Pilih Tanggal',
                                            style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_forward_ios,
                                    color: ColorTheme.primary,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: 10),

                          // --- PILIH JAM (Tersembunyi jika harus ditinggal) ---
                          Obx(() {
                            bool mustLeave = controller.isMotorMustBeLeft(
                              index,
                            );

                            if (mustLeave) {
                              // WARNING HARUS DITINGGAL
                              return Container(
                                margin: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.warning_amber_rounded,
                                      color: Colors.orange,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        "Layanan berat. Motor wajib ditinggal. Dikerjakan saat mekanik kosong.",
                                        style: TextStyle(
                                          color: Colors.orange.shade900,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              // FORM JAM BISA DITUNGGU
                              return InkWell(
                                onTap:
                                    () => controller.pickTime(context, index),
                                child: Container(
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: ColorTheme.darkBgPrimary,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.access_time,
                                        color: ColorTheme.secondaryColor,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 15),
                                      Expanded(
                                        child: Obx(
                                          () => Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Waktu Booking",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 12,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                              Text(
                                                formUI.bookingTime.isEmpty
                                                    ? 'Pilih Waktu'
                                                    : formUI.bookingTime.value,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const Icon(
                                        Icons.arrow_forward_ios,
                                        color: ColorTheme.primary,
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                          }),
                          const SizedBox(height: 15),

                          // --- KELUHAN ---
                          TextField(
                            controller: formUI.complaintCtrl,
                            maxLines: 2,
                            decoration: const InputDecoration(
                              labelText: "Keluhan Tambahan",
                              hintText: "Misal: Rem blong",
                              border: OutlineInputBorder(),
                              fillColor: Colors.white,
                              filled: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        );
      }),
    );
  }
}
