import '../services/local/expense_local_service.dart';
import '../services/remote/expense_remote_service.dart';
import 'base_provider.dart';
import '../models/expense.dart';

class ExpenseProvider extends BaseProvider<Expense> {
  ExpenseProvider() {
    localService = ExpenseLocalService();
    remoteService = ExpenseRemoteService();
  }
}
