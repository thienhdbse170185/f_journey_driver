import 'package:bloc/bloc.dart';
import 'package:f_journey_driver/model/repository/wallet/wallet_repository.dart';
import 'package:f_journey_driver/model/response/wallet/vnpay_response.dart';
import 'package:meta/meta.dart';

part 'wallet_state.dart';

class WalletCubit extends Cubit<WalletState> {
  final WalletRepository walletRepository;
  WalletCubit({required this.walletRepository}) : super(WalletInitial());

  Future<void> updateWalletBalanceStarted(int balance) async {
    emit(ImportWalletInProgress());
    try {
      final response = await walletRepository.updateWalletBalance(balance);
      emit(ImportWalletSuccess(response));
    } on Exception catch (e) {
      emit(ImportWalletFailure(e.toString()));
    }
  }

  Future<void> checkPaymentStarted(Uri uri) async {
    emit(CheckPaymentInProgress());
    VnpayResponse vnpayResponse = VnpayResponse.fromUrl(uri);
    try {
      final response = await walletRepository.checkPayment(vnpayResponse);
      emit(CheckPaymentSuccess(response));
    } on Exception {
      emit(CheckPaymentFailure('Error! Cannot check payment'));
    }
  }
}
