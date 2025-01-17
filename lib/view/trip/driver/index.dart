import 'package:f_journey_driver/core/utils/price_util.dart';
import 'package:f_journey_driver/model/dto/trip_match_dto.dart';
import 'package:f_journey_driver/model/dto/trip_request_dto.dart';
import 'package:f_journey_driver/model/response/auth/get_user_profile_response.dart';
import 'package:f_journey_driver/view/profile/profile_driver.dart';
import 'package:f_journey_driver/view/trip/driver/home.dart';
import 'package:f_journey_driver/viewmodel/auth/auth_bloc.dart';
import 'package:f_journey_driver/viewmodel/trip_match/trip_match_cubit.dart';
import 'package:f_journey_driver/viewmodel/trip_request/trip_request_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TabsDriverWidget extends StatefulWidget {
  const TabsDriverWidget({super.key});

  @override
  State<TabsDriverWidget> createState() => _TabsDriverWidgetState();
}

class _TabsDriverWidgetState extends State<TabsDriverWidget> {
  int _selectedIndex = 0;
  String balance = "0";
  GetUserProfileResult? profile;
  List<TripRequestDto> tripRequests = [];
  List<TripMatchDto> acceptedTripMatches = [],
      inProgressTripmatches = [],
      completedTripMatches = [],
      canceledTripMatches = [];

  late List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    final state = context.read<AuthBloc>().state;
    if (state is ProfileUserApproved) {
      final balanceFormated =
          PriceUtil.formatPrice(state.profile.wallet.balance);
      setState(() {
        profile = state.profile;
        balance = balanceFormated;
      });
    }

    context.read<TripRequestCubit>().getAllTripRequest();
    final tripRequestState = context.read<TripRequestCubit>().state;
    if (tripRequestState is GetAllTripRequestSuccess) {
      setState(() {
        tripRequests = tripRequestState.tripRequests;
      });
    }

    context.read<TripMatchCubit>().getTripMatchByDriverId(profile!.id);
    final tripMatchState = context.read<TripMatchCubit>().state;
    if (tripMatchState is GetTripMatchByDriverIdSuccess) {
      setState(() {
        acceptedTripMatches = tripMatchState.acceptedTripMatches;
        inProgressTripmatches = tripMatchState.inProgressTripMatches;
        completedTripMatches = tripMatchState.completedTripMatches;
        canceledTripMatches = tripMatchState.canceledTripMatches;
      });
    }

    _widgetOptions = <Widget>[
      HomeDriverWidget(
        userId: profile?.id ?? 0,
        balance: balance,
        tripRequests: tripRequests,
        acceptedTripMatches: acceptedTripMatches,
        inProgressTripmatches: inProgressTripmatches,
        completedTripMatches: completedTripMatches,
        canceledTripMatches: canceledTripMatches,
      ),
      ProfileDriverWidget(
        profileImageUrl: profile?.profileImageUrl ?? '',
        name: profile?.name ?? 'Tên mặc định',
        email: profile?.email ?? 'Email mặc định',
        userId: profile?.id ?? 0,
      ),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        enableFeedback: false,
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: _selectedIndex == 0
                ? const Icon(Icons.home_rounded)
                : const Icon(Icons.home_outlined),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: _selectedIndex == 4
                ? const Icon(Icons.account_circle_rounded)
                : const Icon(Icons.account_circle_outlined),
            label: 'Cá nhân',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedFontSize: 12,
        unselectedFontSize: 12,
      ),
    );
  }
}
