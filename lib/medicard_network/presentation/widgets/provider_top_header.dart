import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../network/data/provider_page_response_model.dart';
import '../../logic/provider_page_cubit.dart';
import '../../logic/provider_page_state.dart';
import 'provider_rebuild_scopes.dart';
import 'provider_shared_widgets.dart';

/// Compact provider header. Rebuilds only on provider-data, loading, error,
/// or view changes — never on list/scroll/cart churn.
class ProviderTopHeader extends StatelessWidget {
  final ProviderBranch? selectedBranch;
  final void Function(List<ProviderBranch>?, String?) onBranchTap;

  const ProviderTopHeader({
    super.key,
    required this.selectedBranch,
    required this.onBranchTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProviderPageCubit, ProviderPageState>(
      buildWhen: ProviderRebuildScopes.isHeaderSliceChanged,
      builder: (context, state) {
        final cubit = context.read<ProviderPageCubit>();
        void handleBack() {
          if (state.currentView == ProviderViewType.reviews) {
            cubit.switchView(state.catalogView);
          } else if (context.canPop()) {
            context.pop();
          } else {
            context.go('/medicard-home');
          }
        }

        final data = state.providerData;
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Color(0xFFEEF1F5))),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(8.w, 8.h, 16.w, 10.h),
            child: state.isProviderLoading
                ? SizedBox(
                    height: 54.h,
                    child: Row(
                      children: [
                        _HeaderBackButton(onPressed: handleBack),
                        const Expanded(
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                color: Color(0xFF3872B1),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 40.r),
                      ],
                    ),
                  )
                : data != null
                ? ProviderInfoRow(
                    data: data,
                    servicesCount: state.displayServicesCount,
                    selectedBranch: selectedBranch,
                    onBack: handleBack,
                    onBranchTap: () => onBranchTap(data.branches, data.name),
                    onRatingTap: () => context.push(
                      '/provider-reviews',
                      extra: {
                        'cubit': cubit,
                        'providerId': cubit.providerId,
                        'providerName': data.name,
                      },
                    ),
                  )
                : Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: _HeaderBackButton(onPressed: handleBack),
                  ),
          ),
        );
      },
    );
  }
}

class _HeaderBackButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _HeaderBackButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40.r,
      height: 40.r,
      child: IconButton(
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        onPressed: onPressed,
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: const Color(0xFF111827),
          size: 20.sp,
        ),
      ),
    );
  }
}
