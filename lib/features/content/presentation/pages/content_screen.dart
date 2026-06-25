import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theming/app_toast.dart';
import '../../domain/models/content_type.dart';
import '../cubit/content_cubit.dart';
import '../cubit/content_state.dart';
import '../widgets/content_shimmer.dart';
import '../widgets/content_error_view.dart';

class ContentScreen extends StatefulWidget {
  final ContentType contentType;

  const ContentScreen({super.key, required this.contentType});

  @override
  State<ContentScreen> createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen> {
  String _getPageTitle() {
    switch (widget.contentType) {
      case ContentType.privacyPolicy:
        return 'content.privacy_policy'.tr();
      case ContentType.refundPolicy:
        return 'content.refund_policy'.tr();
      case ContentType.termsAndConditions:
        return 'content.terms_and_conditions'.tr();
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return BlocProvider(
      create: (_) => sl<ContentCubit>()..loadContent(widget.contentType),
      child: BlocConsumer<ContentCubit, ContentState>(
        listener: (context, state) {
          state.maybeWhen(
            failed: (error) => showErrorToast(error),
            orElse: () {},
          );
        },
        builder: (context, state) {
          return state.when(
            initial: () => const SizedBox.shrink(),
            loading: () => const ContentShimmer(),
            success: (data) {
              return Scaffold(
                backgroundColor: const Color(0xFFF8F9FA),
                body: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2D5FA6),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                      padding: EdgeInsetsDirectional.fromSTEB(
                        16.w,
                        statusBarHeight + 12.h,
                        16.w,
                        20.h,
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          Expanded(
                            child: Text(
                              _getPageTitle(),
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(width: 40.w),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                        child: Text(
                          data.description ?? '',
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: const Color(0xFF1A1A2E),
                            height: 1.7,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            failed: (_) => ContentErrorView(
              onRetry: () => context.read<ContentCubit>().loadContent(widget.contentType),
            ),
          );
        },
      ),
    );
  }
}
