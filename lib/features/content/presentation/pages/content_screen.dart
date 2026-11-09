import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_html/flutter_html.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/services/url_launcher_service.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_snack_bar.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/app_simple_header.dart';
import '../../domain/models/content_type.dart';
import '../cubit/content_cubit.dart';
import '../cubit/content_state.dart';
import '../utils/content_link_handler.dart';
import '../widgets/content_shimmer.dart';
import '../widgets/content_error_view.dart';

class ContentScreen extends StatefulWidget {
  final ContentType contentType;

  const ContentScreen({super.key, required this.contentType});

  @override
  State<ContentScreen> createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen> {
  late final ContentLinkHandler _linkHandler;

  @override
  void initState() {
    super.initState();
    _linkHandler = ContentLinkHandler(UrlLauncherService());
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = context.locale.languageCode.toLowerCase() == 'ar';

    return BlocProvider(
      create: (_) => sl<ContentCubit>()..loadContent(widget.contentType),
      child: Directionality(
        textDirection: isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
        child: Scaffold(
          backgroundColor: AppColors.lightGreyClr,
          body: Column(
            children: [
              AppSimpleHeader(title: widget.contentType.titleKey.tr()),
              Expanded(
                child: SafeArea(
                  top: false,
                  child: BlocBuilder<ContentCubit, ContentState>(
                    builder: (context, state) {
                      return state.when(
                        initial: () => const ContentShimmer(),
                        loading: () => const ContentShimmer(),
                        success: (data) {
                          final html = data.description.trim();
                          if (html.isEmpty) {
                            return _ContentEmptyView(contentType: widget.contentType);
                          }
                          return _HtmlContentView(
                            html: html,
                            isRtl: isRtl,
                            linkHandler: _linkHandler,
                          );
                        },
                        failed: (error) => ContentErrorView(
                          message: error.tr(),
                          onRetry: () =>
                              context.read<ContentCubit>().retry(widget.contentType),
                        ),
                      );
                    },
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

class _HtmlContentView extends StatelessWidget {
  final String html;
  final bool isRtl;
  final ContentLinkHandler linkHandler;

  const _HtmlContentView({
    required this.html,
    required this.isRtl,
    required this.linkHandler,
  });

  @override
  Widget build(BuildContext context) {
    final textAlign = isRtl ? TextAlign.right : TextAlign.left;
    final fontFamily = Theme.of(context).textTheme.bodyMedium?.fontFamily;

    return SingleChildScrollView(
      padding: EdgeInsetsDirectional.fromSTEB(20.w, 20.h, 20.w, 32.h),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Html(
            data: html,
            extensions: [
              // Section headings (h2 like "Definitions") render as dark
              // bold text with a short blue accent bar underneath.
              TagExtension(
                tagsToExtend: {'h2'},
                builder: (ext) {
                  final heading = ext.element?.text.trim() ?? '';
                  return Column(
                    crossAxisAlignment: isRtl
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        heading,
                        textAlign: textAlign,
                        style: AppTextStyles.of(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.inkClr,
                          height: 1.4,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Container(
                        width: 36.w,
                        height: 3.h,
                        decoration: BoxDecoration(
                          color: AppColors.blueClr,
                          borderRadius: BorderRadius.circular(3.r),
                        ),
                      ),
                      SizedBox(height: 12.h),
                    ],
                  );
                },
              ),
            ],
            onLinkTap: (url, _, _) async {              final opened = await linkHandler.handle(context, url);
              if (!opened && context.mounted) {
                showAppSnackBar(
                  context,
                  'content.unable_to_open_link'.tr(),
                  type: SnackBarType.error,
                );
              }
            },
            style: {
              '*': Style(
                fontFamily: fontFamily,
                color: AppColors.blackClr,
                direction: isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
                textAlign: textAlign,
              ),
              'body': Style(
                margin: Margins.zero,
                padding: HtmlPaddings.zero,
                fontSize: FontSize(16.sp),
                lineHeight: const LineHeight(1.7),
              ),
              'header': Style(margin: Margins.only(bottom: 18.h)),
              'footer': Style(margin: Margins.only(top: 24.h)),
              'section': Style(margin: Margins.only(bottom: 20.h)),
              'div': Style(margin: Margins.only(bottom: 12.h)),
              'h1': Style(
                margin: Margins.only(bottom: 18.h),
                fontSize: FontSize(24.sp),
                fontWeight: FontWeight.w700,
                color: AppColors.blackClr,
                lineHeight: const LineHeight(1.3),
              ),
              'h2': Style(
                // Rendered by customRenders above; kept minimal as fallback.
                margin: Margins.only(top: 22.h, bottom: 10.h),
                fontSize: FontSize(18.sp),
                fontWeight: FontWeight.w700,
                color: AppColors.inkClr,
                lineHeight: const LineHeight(1.4),
              ),
              'p': Style(
                margin: Margins.only(bottom: 12.h),
                fontSize: FontSize(16.sp),
                lineHeight: const LineHeight(1.7),
                whiteSpace: WhiteSpace.pre,
              ),
              'ul': Style(
                margin: Margins.only(bottom: 14.h),
                padding: isRtl
                    ? HtmlPaddings.only(right: 22.w)
                    : HtmlPaddings.only(left: 22.w),
              ),
              'li': Style(
                margin: Margins.only(bottom: 8.h),
                fontSize: FontSize(16.sp),
                lineHeight: const LineHeight(1.65),
              ),
              'a': Style(
                color: AppColors.primaryClr,
                textDecoration: TextDecoration.underline,
                fontWeight: FontWeight.w600,
              ),
            },
          ),
        ),
      ),
    );
  }
}

class _ContentEmptyView extends StatelessWidget {
  final ContentType contentType;

  const _ContentEmptyView({required this.contentType});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.article_outlined, size: 56.sp, color: AppColors.blueClr),
            SizedBox(height: 16.h),
            Text(
              'content.empty_title'.tr(),
              style: AppTextStyles.font18BlackSemiBold(context),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              'content.empty_message'.tr(args: [contentType.titleKey.tr()]),
              style: AppTextStyles.font14GreyRegular(context),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

