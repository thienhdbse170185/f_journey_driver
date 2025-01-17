import 'package:f_journey_driver/core/common/widgets/settings_bottom_sheet.dart';
import 'package:f_journey_driver/core/router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RegisterResultWidget extends StatefulWidget {
  final bool? isRejected; // Use final to ensure immutability
  const RegisterResultWidget({super.key, this.isRejected});

  @override
  State<RegisterResultWidget> createState() => _RegisterResultWidgetState();
}

class _RegisterResultWidgetState extends State<RegisterResultWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {},
        ),
        title: const Text('Trạng thái hồ sơ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              showSettingsBottomSheet(context);
            },
          ),
        ],
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        padding:
            const EdgeInsets.only(top: 64, bottom: 16, left: 16, right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/document.png',
              width: 260,
            ),
            const SizedBox(height: 32),
            // Check if the application was rejected
            if (widget.isRejected == true)
              Column(
                children: [
                  Text(
                    'Hồ sơ của bạn đã bị từ chối!',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Vui lòng cập nhật lại hồ sơ vì dữ liệu bị sai sót.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.outline),
                    textAlign: TextAlign.center,
                  ),
                ],
              )
            else
              Column(
                children: [
                  Text('Hồ sơ đang được xét duyệt',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text(
                    'Tụi mình sẽ gửi thông báo cho bạn khi có kết quả xét duyệt thông qua Mail bạn đã cung cấp nhé! Thân chào bạn.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.outline),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: () {
                context.go(RouteName.getStarted);
              },
              child: const Text('Vâng, cảm ơn bạn!'),
            ),
          ],
        ),
      ),
    );
  }
}
