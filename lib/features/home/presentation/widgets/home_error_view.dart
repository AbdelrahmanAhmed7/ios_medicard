import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../domain/models/home_failure.dart';

/// Full-content error state shown inside the sliver scroll when the API fails.
/// Displays a friendly message and a retry button.
class HomeErrorView extends StatelessWidget {
  final HomeFailureType failure;
  final String? message;
  final VoidCallback onRetry;
  final bool isRetrying;

  const HomeErrorView({
    super.key,
    this.failure = HomeFailureType.unknown,
    this.message,
    required this.onRetry,
    this.isRetrying = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final messageKey = switch (failure) {
      HomeFailureType.noInternet => 'home.no_internet_message',
      HomeFailureType.connectionTimeout => 'home.connection_timeout_message',
      HomeFailureType.transferTimeout => 'home.transfer_timeout_message',
      HomeFailureType.server => 'home.server_error_message',
      HomeFailureType.unauthorized => 'home.unauthorized_message',
      HomeFailureType.unknown => 'home.unknown_error_message',
    };
    final icon = failure == HomeFailureType.noInternet
        ? Icons.wifi_off_rounded
        : Icons.cloud_off_rounded;

    return SafeArea(
      top: false,
      child: LayoutBuilder(
        builder: (context, constraints) => Padding(
          padding: EdgeInsets.symmetric(
            horizontal: constraints.maxWidth < 360 ? 20 : 32,
            vertical: 48,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  icon,
                  size: 36,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'home.network_error_title'.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message ?? messageKey.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: isRetrying ? null : onRetry,
                  icon: isRetrying
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.refresh_rounded, size: 18),
                  label: Text(
                    (isRetrying ? 'home.retrying' : 'common.try_again').tr(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
