import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../domain/models/home_failure.dart';

import '../../../../core/theming/app_text_styles.dart';

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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxHeight < 560;
          return Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: constraints.maxWidth < 360 ? 20 : 32,
                vertical: isCompact ? 24 : 40,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withValues(
                        alpha: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(
                      icon,
                      size: 40,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'home.network_error_title'.tr(),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.of(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    message ?? messageKey.tr(),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.of(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: isRetrying ? null : onRetry,
                      icon: isRetrying
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.refresh_rounded, size: 20),
                      label: Text(
                        (isRetrying ? 'home.retrying' : 'common.try_again')
                            .tr(),
                        style: AppTextStyles.of(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
