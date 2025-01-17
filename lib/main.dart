import 'package:f_journey_driver/core/common/cubits/theme_cubit.dart';
import 'package:f_journey_driver/core/network/http_client.dart';
import 'package:f_journey_driver/core/router.dart';
import 'package:f_journey_driver/core/theme/theme.dart';
import 'package:f_journey_driver/core/theme/util.dart';
import 'package:f_journey_driver/model/repository/auth/auth_api_client.dart';
import 'package:f_journey_driver/model/repository/auth/auth_repository.dart';
import 'package:f_journey_driver/model/repository/payment/payment_api_client.dart';
import 'package:f_journey_driver/model/repository/payment/payment_repository.dart';
import 'package:f_journey_driver/model/repository/reason/reason_api_client.dart';
import 'package:f_journey_driver/model/repository/reason/reason_repository.dart';
import 'package:f_journey_driver/model/repository/trip_match/trip_match_api_client.dart';
import 'package:f_journey_driver/model/repository/trip_match/trip_match_repository.dart';
import 'package:f_journey_driver/model/repository/trip_request/trip_request_api_client.dart';
import 'package:f_journey_driver/model/repository/trip_request/trip_request_repository.dart';
import 'package:f_journey_driver/model/repository/wallet/wallet_api_client.dart';
import 'package:f_journey_driver/model/repository/wallet/wallet_repository.dart';
import 'package:f_journey_driver/model/repository/zone/zone_api_client.dart';
import 'package:f_journey_driver/model/repository/zone/zone_repository.dart';
import 'package:f_journey_driver/viewmodel/auth/auth_bloc.dart';
import 'package:f_journey_driver/viewmodel/reason/reason_cubit.dart';
import 'package:f_journey_driver/viewmodel/transaction/transaction_cubit.dart';
import 'package:f_journey_driver/viewmodel/trip_match/trip_match_cubit.dart';
import 'package:f_journey_driver/viewmodel/trip_request/trip_request_cubit.dart';
import 'package:f_journey_driver/viewmodel/wallet/wallet_cubit.dart';
import 'package:f_journey_driver/viewmodel/zone/zone_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (context) =>
              AuthRepository(authApiClient: AuthApiClient(dio: dio)),
        ),
        RepositoryProvider(
            create: (context) =>
                ZoneRepository(zoneApiClient: ZoneApiClient(dio: dio))),
        RepositoryProvider(
            create: (context) => TripRequestRepository(
                apiClient: TripRequestApiClient(dio: dio))),
        RepositoryProvider(
            create: (context) =>
                WalletRepository(walletApiClient: WalletApiClient(dio: dio))),
        RepositoryProvider(
            create: (context) => TripMatchRepository(
                tripMatchApiClient: TripMatchApiClient(dio: dio))),
        RepositoryProvider(
            create: (context) =>
                ReasonRepository(reasonApiClient: ReasonApiClient(dio: dio))),
        RepositoryProvider(
            create: (context) =>
                PaymentRepository(paymentApiClient: PaymentApiClient(dio: dio)))
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                AuthBloc(authRepository: context.read<AuthRepository>()),
          ),
          BlocProvider(
            create: (context) => ThemeCubit(), // Add ThemeCubit
          ),
          BlocProvider(
              create: (context) =>
                  ZoneBloc(zoneRepository: context.read<ZoneRepository>())),
          BlocProvider(
              create: (context) => TripRequestCubit(
                  repository: context.read<TripRequestRepository>())),
          BlocProvider(
              create: (context) => WalletCubit(
                  walletRepository: context.read<WalletRepository>())),
          BlocProvider(
              create: (context) => TripMatchCubit(
                  repository: context.read<TripMatchRepository>())),
          BlocProvider(
              create: (context) =>
                  ReasonCubit(context.read<ReasonRepository>())),
          BlocProvider(
              create: (context) =>
                  TransactionCubit(context.read<PaymentRepository>()))
        ],
        child: const AppContent(),
      ),
    );
  }
}

class AppContent extends StatelessWidget {
  const AppContent({super.key});

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = createTextTheme(context, "Roboto", "Roboto");
    MaterialTheme theme = MaterialTheme(textTheme);

    return BlocBuilder<ThemeCubit, bool>(
      builder: (context, themeMode) {
        return MaterialApp.router(
          theme: themeMode == true ? theme.dark() : theme.light(),
          routerConfig: router,
        );
      },
    );
  }
}
