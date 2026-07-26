import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/error_widget.dart';

class ErrorScreen extends StatelessWidget {
  final String? errorMessage;

  const ErrorScreen({super.key, this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: CustomErrorWidget(
          title: 'Something went wrong',
          message: errorMessage ??
              'We ran into an unexpected issue while communicating with Firebase. Please try again.',
          onRetry: () => context.go('/home'),
          onGoBack: () => context.pop(),
        ),
      ),
    );
  }
}
