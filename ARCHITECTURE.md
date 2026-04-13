# SpeedLab Admin - Clean Architecture + GetX

Proyek ini telah direstrukturisasi menggunakan **Clean Architecture** dengan **GetX** sebagai state management.

## 📁 Struktur Folder

```
lib/
├── app/
│   ├── bindings/           # Dependency injection untuk GetX
│   │   └── initial_binding.dart
│   ├── config/             # Konfigurasi aplikasi (theme, dll)
│   │   └── theme.dart
│   ├── routes/             # Route management dengan GetX
│   │   ├── app_pages.dart
│   │   └── app_routes.dart
│   └── utils/              # Utility dan constants
│       └── constants.dart
│
├── data/                   # Data Layer
│   ├── datasources/        # Sumber data
│   │   ├── local/          # Local storage (SharedPreferences)
│   │   │   ├── motor_local_datasource.dart
│   │   │   └── motor_local_datasource_impl.dart
│   │   └── remote/         # API calls
│   │       ├── motor_remote_datasource.dart
│   │       └── motor_remote_datasource_impl.dart
│   ├── models/             # Data models dengan JSON serialization
│   │   ├── motor_model.dart
│   │   └── user_model.dart
│   └── repositories/       # Implementation dari domain repositories
│       ├── motor_repository_impl.dart
│       └── auth_repository_impl.dart
│
├── domain/                 # Domain Layer (Business Logic)
│   ├── entities/           # Entity objects (pure Dart classes)
│   │   ├── motor.dart
│   │   └── user.dart
│   └── repositories/       # Repository interfaces (contracts)
│       ├── motor_repository.dart
│       └── auth_repository.dart
│
├── presentation/           # Presentation Layer (UI)
│   ├── controllers/        # GetX Controllers (seperti Controller di Laravel)
│   │   ├── auth_controller.dart
│   │   ├── motor_controller.dart
│   │   └── home_controller.dart
│   ├── pages/              # Halaman aplikasi
│   │   ├── auth/
│   │   │   ├── login_page.dart
│   │   │   └── login_binding.dart
│   │   ├── beranda/
│   │   │   ├── beranda_page.dart
│   │   │   └── beranda_binding.dart
│   │   ├── home/
│   │   │   ├── home_page.dart
│   │   │   └── home_binding.dart
│   │   ├── motor/
│   │   │   ├── tambah_motor_page.dart
│   │   │   ├── tambah_motor_binding.dart
│   │   │   ├── detail_motor_page.dart
│   │   │   └── detail_motor_binding.dart
│   │   ├── pesanan/
│   │   │   ├── pesanan_page.dart
│   │   │   └── pesanan_binding.dart
│   │   └── profil/
│   │       ├── profil_page.dart
│   │       └── profil_binding.dart
│   └── widgets/            # Reusable widgets
│       ├── dashboard_card.dart
│       └── motor_list_item.dart
│
└── main.dart              # Entry point aplikasi
```

## 🎯 Konsep Clean Architecture

### 1. **Domain Layer** (Layer Bisnis)
- **Entities**: Objek murni Dart tanpa ketergantungan framework
- **Repositories**: Interface/contract untuk akses data
- Tidak bergantung pada layer lain

### 2. **Data Layer** (Layer Data)
- **Models**: Implementasi entities dengan JSON serialization
- **DataSources**: 
  - Remote (API calls)
  - Local (SharedPreferences, Database)
- **Repository Implementations**: Implementasi konkret dari domain repositories

### 3. **Presentation Layer** (Layer UI)
- **Controllers**: Logika UI dan state management (mirip Controller di Laravel)
- **Pages**: Tampilan UI
- **Widgets**: Komponen UI yang reusable

## 🚀 GetX State Management

### Controllers (Mirip Laravel Controller)
Controllers di GetX berfungsi seperti Controller di Laravel - memisahkan logic dari UI:

```dart
class MotorController extends GetxController {
  // Observable state
  final RxList<Motor> _motors = <Motor>[].obs;
  List<Motor> get motors => _motors;
  
  // Methods (seperti method di Laravel Controller)
  Future<void> fetchMotors() async { ... }
  Future<void> createMotor(...) async { ... }
  Future<void> updateMotor(...) async { ... }
}
```

### Menggunakan Controller di Page
```dart
class BerandaPage extends GetView<MotorController> {
  @override
  Widget build(BuildContext context) {
    // Akses controller dengan 'controller'
    return Obx(() => ListView.builder(
      itemCount: controller.motors.length,
      itemBuilder: (context, index) {
        final motor = controller.motors[index];
        return MotorListItem(motor: motor);
      },
    ));
  }
}
```

## 📱 Routing dengan GetX

### Navigasi
```dart
// Pindah ke halaman baru
Get.toNamed('/tambah-motor');

// Pindah dengan menghapus halaman sebelumnya
Get.offNamed('/login');

// Pindah dan hapus semua halaman sebelumnya
Get.offAllNamed('/home');

// Kembali ke halaman sebelumnya
Get.back();

// Kirim data
Get.toNamed('/detail-motor', arguments: motorObject);

// Terima data
final Motor motor = Get.arguments as Motor;
```

## 🔧 Dependency Injection

Semua dependency diatur di `InitialBinding`:

```dart
class InitialBinding extends Bindings {
  @override
  Future<void> dependencies() async {
    // Setup SharedPreferences
    final sharedPreferences = await SharedPreferences.getInstance();
    Get.put(sharedPreferences, permanent: true);

    // Setup Repositories
    Get.lazyPut(() => MotorRepositoryImpl(...));
    Get.lazyPut(() => AuthRepositoryImpl(...));

    // Setup Controllers
    Get.put(AuthController(...), permanent: true);
    Get.put(MotorController(...), permanent: true);
  }
}
```

## 🛠️ Cara Menggunakan

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Jalankan Aplikasi
```bash
flutter run
```

### 3. Menambahkan Fitur Baru

#### a. Buat Entity (domain/entities/)
```dart
class NewEntity {
  final String id;
  final String name;
  
  NewEntity({required this.id, required this.name});
}
```

#### b. Buat Repository Interface (domain/repositories/)
```dart
abstract class NewRepository {
  Future<List<NewEntity>> getAll();
  Future<NewEntity> create(NewEntity entity);
}
```

#### c. Buat Model (data/models/)
```dart
class NewModel extends NewEntity {
  NewModel({required super.id, required super.name});
  
  factory NewModel.fromJson(Map<String, dynamic> json) { ... }
  Map<String, dynamic> toJson() { ... }
}
```

#### d. Buat DataSource (data/datasources/)
```dart
abstract class NewDataSource {
  Future<List<NewModel>> getAll();
}

class NewDataSourceImpl implements NewDataSource {
  @override
  Future<List<NewModel>> getAll() async { ... }
}
```

#### e. Buat Repository Implementation (data/repositories/)
```dart
class NewRepositoryImpl implements NewRepository {
  final NewDataSource dataSource;
  
  NewRepositoryImpl({required this.dataSource});
  
  @override
  Future<List<NewEntity>> getAll() async {
    final models = await dataSource.getAll();
    return models.map((m) => m.toEntity()).toList();
  }
}
```

#### f. Buat Controller (presentation/controllers/)
```dart
class NewController extends GetxController {
  final NewRepository repository;
  
  NewController({required this.repository});
  
  final RxList<NewEntity> _items = <NewEntity>[].obs;
  List<NewEntity> get items => _items;
  
  @override
  void onInit() {
    super.onInit();
    fetchItems();
  }
  
  Future<void> fetchItems() async {
    final result = await repository.getAll();
    _items.value = result;
  }
}
```

#### g. Buat Page & Binding (presentation/pages/)
```dart
// new_page.dart
class NewPage extends GetView<NewController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => ListView.builder(
        itemCount: controller.items.length,
        itemBuilder: (context, index) {
          return Text(controller.items[index].name);
        },
      )),
    );
  }
}

// new_binding.dart
class NewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => NewController(repository: Get.find()));
  }
}
```

#### h. Daftarkan Route (app/routes/)
```dart
// Di app_routes.dart, tambahkan:
static const NEW = _Paths.NEW;
static const NEW = '/new';

// Di app_pages.dart, tambahkan:
GetPage(
  name: _Paths.NEW,
  page: () => NewPage(),
  binding: NewBinding(),
),
```

## 📝 Best Practices

1. **Pisahkan Logic dari UI**: Semua logic ada di Controller, UI hanya menampilkan
2. **Gunakan Reactive Programming**: Gunakan `Obx()` atau `GetBuilder()` untuk update UI
3. **Repository Pattern**: Semua akses data melalui repository
4. **Dependency Injection**: Gunakan GetX binding untuk DI
5. **Naming Convention**: 
   - Controller: `NamaController`
   - Page: `NamaPage`
   - Binding: `NamaBinding`
   - Model: `NamaModel`
   - Entity: `Nama` (tanpa suffix)

## 🔄 Data Flow

```
UI (Page) 
  ↓ user action
Controller 
  ↓ call method
Repository (Interface)
  ↓ implemented by
Repository Implementation
  ↓ call
DataSource (Remote/Local)
  ↓ return
Model
  ↓ convert to
Entity
  ↓ return to
Controller
  ↓ update state
UI (Page) updates automatically
```

## 🎨 Keuntungan Struktur Ini

1. **Mudah di-maintain**: Kode terorganisir dengan baik
2. **Testable**: Setiap layer bisa di-test secara terpisah
3. **Scalable**: Mudah menambah fitur baru
4. **Reusable**: Controller dan widget bisa digunakan ulang
5. **Separation of Concerns**: UI, Logic, dan Data terpisah
6. **Mirip Laravel**: Konsep Controller memisahkan logic dari view

## 📚 Resources

- [GetX Documentation](https://pub.dev/packages/get)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter Best Practices](https://flutter.dev/docs/development/data-and-backend/state-mgmt/intro)
