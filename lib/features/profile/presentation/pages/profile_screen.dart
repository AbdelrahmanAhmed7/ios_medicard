import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    if (kDebugMode) debugPrint('[ProfileFlow] ProfileCubit created for ProfileScreen');
    _profileCubit.loadProfile();
  }

  @override
  void dispose() {
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
              success: (data) => ProfileContent(data: data),
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
