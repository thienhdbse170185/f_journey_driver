import 'dart:developer';

import 'package:f_journey_driver/core/utils/snackbar_util.dart';
import 'package:f_journey_driver/model/dto/trip_match_dto.dart';
import 'package:f_journey_driver/viewmodel/reason/reason_cubit.dart';
import 'package:f_journey_driver/viewmodel/trip_match/trip_match_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TripMatchDetailWidget extends StatefulWidget {
  final TripMatchDto tripMatch;
  const TripMatchDetailWidget({super.key, required this.tripMatch});

  @override
  State<TripMatchDetailWidget> createState() => _TripMatchDetailWidgetState();
}

class _TripMatchDetailWidgetState extends State<TripMatchDetailWidget> {
  List<Map<String, dynamic>> cancellationReasons = [];
  int? selectedReasonId;

  @override
  void initState() {
    super.initState();
    context.read<ReasonCubit>().getAllReasons();
  }

  void _showCancellationDialog() async {
    await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text("Lý do hủy chuyến đi"),
              content: SizedBox(
                height: 5 * 56.0, // Approximate height for 5 list items
                width: double.maxFinite,
                child: ListView.builder(
                  itemCount: cancellationReasons.length,
                  itemBuilder: (context, index) {
                    final reason = cancellationReasons[index];
                    return RadioListTile<int>(
                      title: Text(reason['content']),
                      selected: selectedReasonId == reason['id'],
                      value: reason['id'] as int,
                      groupValue: selectedReasonId,
                      onChanged: (value) {
                        setState(() {
                          selectedReasonId = value;
                        });
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Hủy"),
                ),
                TextButton(
                  onPressed: selectedReasonId != null
                      ? () {
                          context.read<TripMatchCubit>().updateTripMatchStatus(
                              widget.tripMatch.id,
                              'Canceled',
                              selectedReasonId,
                              false);
                          Navigator.of(context).pop();
                          log("Selected reason ID: $selectedReasonId");
                        }
                      : null,
                  child: const Text("Xác nhận"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ReasonCubit, ReasonState>(
          listener: (context, state) {
            if (state is GetAllReasonSuccess) {
              setState(() {
                cancellationReasons = state.reasons
                    .map((e) => {'id': e.reasonId, 'content': e.content})
                    .toList();
              });
            } else if (state is GetAllReasonFailure) {
              log("Failed to get reasons: //${state.message}");
            }
          },
        ),
        BlocListener<TripMatchCubit, TripMatchState>(
          listener: (context, state) {
            if (state is UpdateTripMatchStatusSuccess) {
              SnackbarUtil.openSuccessSnackbar(
                  context, "Cập nhật trạng thái thành công");
            } else if (state is UpdateTripMatchStatusFailure) {
              SnackbarUtil.openFailureSnackbar(
                  context, "Update trip match status failed");
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chi tiết chuyến đi'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tài xế',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage:
                          NetworkImage(widget.tripMatch.driver.profileImageUrl),
                      radius: 40,
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.tripMatch.driver.name,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(
                            "Biển số xe: ${widget.tripMatch.driver.licensePlate}"),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 2.0),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          widget.tripMatch.driver.vehicleImageUrl,
                          width: 100,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Chi tiết chuyến đi',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('From: ${widget.tripMatch.tripRequest.fromZoneName}'),
                    Text('To: ${widget.tripMatch.tripRequest.toZoneName}'),
                    Text(
                        'Date: ${widget.tripMatch.tripRequest.tripDate} | Slot: ${widget.tripMatch.tripRequest.slot}'),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              if (widget.tripMatch.status == 'Pending')
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: OutlinedButton(
                    onPressed: _showCancellationDialog,
                    child: const Text('Hủy chuyến đi'),
                  ),
                )
              else if (widget.tripMatch.status == 'Accepted')
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: ElevatedButton(
                      onPressed: () {
                        context.read<TripMatchCubit>().updateTripMatchStatus(
                            widget.tripMatch.id, 'InProgress', null, false);
                        SnackbarUtil.openSuccessSnackbar(
                            context, "Bắt đầu chuyến thành công!");
                      },
                      child: const Text('Bắt đầu khởi hành')),
                )
              else if (widget.tripMatch.status == 'Completed')
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: const FilledButton(
                      onPressed: null, child: Text('Chuyến này đã hoàn thành')),
                )
              else if (widget.tripMatch.status == 'Canceled')
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: const FilledButton(
                      onPressed: null, child: Text('Chuyến này đã bị hủy')),
                )
              else if (widget.tripMatch.status == 'InProgress')
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    children: [
                      const FilledButton(
                        onPressed: null,
                        child: Text('Chuyến đi đang diễn ra'),
                      ),
                      const SizedBox(height: 8),
                      FilledButton(
                        onPressed: () {
                          // Handle completion of trip
                          context.read<TripMatchCubit>().updateTripMatchStatus(
                                widget.tripMatch.id,
                                'Completed',
                                null,
                                false,
                              );
                          log("Trip marked as completed");
                        },
                        child: const Text('Đã hoàn thành chuyến'),
                      ),
                    ],
                  ),
                )
              else if (widget.tripMatch.status == 'Rejected')
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: const FilledButton(
                      onPressed: null, child: Text('Chuyến này đã bị từ chối')),
                )
            ],
          ),
        ),
      ),
    );
  }
}
