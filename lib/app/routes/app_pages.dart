import 'package:get/get.dart';

import '../modules/add_service/bindings/add_service_binding.dart';
import '../modules/add_service/views/add_service_view.dart';
import '../modules/booking_list/bindings/booking_list_binding.dart';
import '../modules/booking_list/views/booking_list_view.dart';
import '../modules/dashboard/bindings/dashboard_binding.dart';
import '../modules/dashboard/views/dashboard_view.dart';
import '../modules/edit_service/bindings/edit_service_binding.dart';
import '../modules/edit_service/views/edit_service_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/riwayat_servis/bindings/riwayat_servis_binding.dart';
import '../modules/riwayat_servis/views/riwayat_servis_view.dart';
import '../modules/service_history/bindings/service_history_binding.dart';
import '../modules/service_history/views/service_history_view.dart';
import '../modules/service_list/bindings/service_list_binding.dart';
import '../modules/service_list/views/service_list_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.DASHBOARD,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.BOOKING_LIST,
      page: () => const BookingListView(),
      binding: BookingListBinding(),
    ),
    GetPage(
      name: _Paths.SERVICE_HISTORY,
      page: () => const ServiceHistoryView(),
      binding: ServiceHistoryBinding(),
    ),
    GetPage(
      name: _Paths.SERVICE_LIST,
      page: () => const ServiceListView(),
      binding: ServiceListBinding(),
    ),
    GetPage(
      name: _Paths.ADD_SERVICE,
      page: () => const AddServiceView(),
      binding: AddServiceBinding(),
    ),
    GetPage(
      name: _Paths.EDIT_SERVICE,
      page: () => const EditServiceView(),
      binding: EditServiceBinding(),
    ),
    GetPage(
      name: _Paths.RIWAYAT_SERVIS,
      page: () => const RiwayatServisView(),
      binding: RiwayatServisBinding(),
    ),
  ];
}
