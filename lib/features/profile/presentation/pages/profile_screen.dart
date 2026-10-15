import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/cubit/app_refresh_cubit.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theming/app_toast.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import '../widgets/profile_content.dart';
import '../widgets/profile_error_view.dart';
import '../widgets/profile_shimmer.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileCubit _profileCubit;

  @override
  void initState() {
    super.initState();
    if (kDebugMode) debugPrint('[ProfileFlow] Standalone ProfileScreen opened');
    _profileCubit = sl<ProfileCubit>();
    if (kDebugMode) {
      debugPrint('[ProfileFlow] ProfileCubit created for ProfileScreen');
    }
    _profileCubit.loadProfile();
    // Family count / reward points can change on other screens (family
    // add/delete). Refresh the summary silently when asked — no user action.
    sl<AppRefreshCubit>().profileSummaryRefresh.addListener(
      _onProfileSummaryRefresh,
    );
  }

  void _onProfileSummaryRefresh() {
    // TEMP-PROFILE-REFRESH: remove after verifying on device.
    debugPrint('[TEMP] profileSummaryRefresh received, refreshing summary');
    _profileCubit.refreshSummary();
  }

  @override
  void dispose() {
    sl<AppRefreshCubit>().profileSummaryRefresh.removeListener(
      _onProfileSummaryRefresh,
    );
    _profileCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _profileCubit,
      child: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          state.maybeWhen(
            failed: (error) => showErrorToast(error),
            orElse: () {},
          );
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8F9FA),
            body: state.when(
              initial: () => const SizedBox.shrink(),
              loading: () => const ProfileShimmer(),
              success: (data, summary) =>
                  ProfileContent(data: data, summary: summary),
              updating: (data) => ProfileContent(data: data),
              updated: (data) => ProfileContent(data: data),
              failed: (error) => ProfileErrorView(error: error),
            ),
          );
        },
      ),
    );
  }
}
