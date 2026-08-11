import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';

class WalletService {
  final DioClient _dioClient;

  WalletService({DioClient? dioClient}) : _dioClient = dioClient ?? DioClient();

  /// ดึงข้อมูลยอดเงินและประวัติธุรกรรม (GET /api/wallet)
  Future<Response> getWallet() {
    return _dioClient.get('/wallet');
  }

  /// แจ้งถอนเงินเข้าบัญชีธนาคาร (POST /api/wallet/withdraw)
  Future<Response> withdraw({
    required double amount,
    required String bankName,
    required String accountName,
    required String accountNumber,
  }) {
    return _dioClient.post(
      '/wallet/withdraw',
      data: {
        'amount': amount,
        'bank_name': bankName,
        'account_name': accountName,
        'account_number': accountNumber,
      },
    );
  }

  /// ดึงประวัติการถอนเงิน (GET /api/wallet/withdrawals)
  Future<Response> getWithdrawals() {
    return _dioClient.get('/wallet/withdrawals');
  }
}
