import 'package:get_it/get_it.dart';
import 'package:inn_logist_app/services/remote/address_remote_service.dart';
import 'package:inn_logist_app/services/remote/expense_remote_service.dart';
import 'package:inn_logist_app/services/remote/fuel_consumption_remote_service.dart';
import '../services/remote/document_remote_service.dart';
import '../services/remote/report_remote_service.dart';
import '../services/remote/profile_service.dart';
import '../services/remote/order_remote_service.dart';
import '../constants.dart';
import '../services/mocks/mock_document_service.dart';
import '../services/mocks/mock_report_service.dart';
import '../services/mocks/mock_order_service.dart';
import '../services/mocks/mock_profile_service.dart';
import '../services/mocks/mock_expense_service.dart';
import '../services/mocks/mock_fuel_service.dart';
import '../services/mocks/mock_address_service.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  if (Constants.useMockData) {
    getIt
      ..registerLazySingleton<DocumentRemoteService>(
          () => MockDocumentService())
      ..registerLazySingleton<ReportRemoteService>(() => MockReportService())
      ..registerLazySingleton<ProfileService>(() => MockProfileService())
      ..registerLazySingleton<OrderRemoteService>(() => MockOrderService())
      ..registerLazySingleton<ExpenseRemoteService>(() => MockExpenseService())
      ..registerLazySingleton<FuelConsumptionRemoteService>(
          () => MockFuelService())
      ..registerLazySingleton<AddressRemoteService>(() => MockAddressService());
    // Додавайте інші мок-сервіси тут
  } else {
    getIt
      ..registerLazySingleton<DocumentRemoteService>(
          () => DocumentRemoteService())
      ..registerLazySingleton<ReportRemoteService>(() => ReportRemoteService())
      ..registerLazySingleton<ProfileService>(() => ProfileService())
      ..registerLazySingleton<OrderRemoteService>(() => OrderRemoteService());
    // Додавайте інші реальні сервіси тут
  }
}
