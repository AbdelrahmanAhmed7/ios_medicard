import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/theming/app_spacing.dart';
import '../../../../core/theming/app_toast.dart';
import '../../../../core/widgets/app_blue_header.dart';
import '../../../addresses/presentation/widgets/address_selection_sheet.dart';
import '../../../notifications/presentation/cubit/notification_cubit.dart';
import '../../../notifications/presentation/cubit/notification_state.dart';

import '../cubit/location_cubit.dart';
import '../cubit/location_state.dart';
import 'location_display.dart';
import 'search_bar_widget.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: double.infinity,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: kMainTabHeaderContentHeight,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.pageHorizontal,
              8,
              AppSpacing.pageHorizontal,
              12,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                _HeaderTopRow(),
                SizedBox(height: 10),
                Expanded(child: _HeaderSearchBar()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderTopRow extends StatelessWidget {
  const _HeaderTopRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: BlocBuilder<LocationCubit, LocationState>(
            builder: (context, state) {
              return LocationDisplay(
                text: _locationText(state, context),
                onTap: () => _openAddressSheet(context),
              );
            },
          ),
        ),
        const SizedBox(width: 16),
        const _NotificationsButton(),
      ],
    );
  }

  String _locationText(LocationState state, BuildContext context) {
    return switch (state) {
      LocationInitial() || LocationLoading() => 'home.getting_location'.tr(),
      LocationLoaded(:final name) => name,
      LocationError(:final message) => message,
    };
  }

  void _openAddressSheet(BuildContext context) {
    final locationCubit = context.read<LocationCubit>();
    AddressSelectionSheet.show(
      context,
      onSelect: (address) {
        if (!address.hasCoordinates) {
          showWarningToast('addresses.location_unavailable'.tr());
          return;
        }
        final label = address.isWork
            ? 'addresses.work'.tr()
            : 'addresses.home'.tr();
        locationCubit.selectAddress(
          id: address.id,
          name: label,
          latitude: address.lat!,
          longitude: address.long!,
        );
      },
      onUseCurrentLocation: () async {
        await locationCubit.clearSelectedAddress();
        await locationCubit.retryLocation();
      },
    );
  }
}

class _NotificationsButton extends StatefulWidget {
  const _NotificationsButton();

  @override
  State<_NotificationsButton> createState() => _NotificationsButtonState();
}

class _NotificationsButtonState extends State<_NotificationsButton> {
  @override
  void initState() {
    super.initState();
    unawaited(context.read<NotificationCubit>().init());
  }

  @override
  Widget build(BuildContext context) {
    return BlocSelector<NotificationCubit, NotificationState, int>(
      selector: (state) =>
          state.items.where((notification) => !notification.isRead).length,
      builder: (context, unreadCount) {
        final hasUnread = unreadCount > 0;
        return SizedBox(
          width: 40,
          height: 40,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: IconButton(
                  tooltip: 'notifications.title'.tr(),
                  onPressed: () => context.push('/notifications'),
                  padding: EdgeInsets.zero,
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFF8FAFC),
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: Icon(
                    hasUnread
                        ? Icons.notifications_rounded
                        : Icons.notifications_none_rounded,
                    color: const Color(0xFF3872B1),
                    size: 22,
                  ),
                ),
              ),
              if (hasUnread)
                PositionedDirectional(
                  key: const ValueKey('notification-unread-badge'),
                  top: -6,
                  end: -6,
                  child: IgnorePointer(
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 19,
                        minHeight: 19,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        transitionBuilder: (child, animation) =>
                            ScaleTransition(scale: animation, child: child),
                        child: Text(
                          unreadCount > 99 ? '99+' : '$unreadCount',
                          key: ValueKey(unreadCount),
                          textScaler: TextScaler.noScaling,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _HeaderSearchBar extends StatelessWidget {
  const _HeaderSearchBar();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<LocationCubit>().state;
    // Rebuild when locale changes so the hint text updates.
    final _ = context.locale;
    return SearchBarWidget(
      latitude: state is LocationLoaded ? state.latitude : null,
      longitude: state is LocationLoaded ? state.longitude : null,
    );
  }
}
