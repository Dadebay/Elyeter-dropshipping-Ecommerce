import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../domain/entities/payment.dart';

/// The bank's card page.
///
/// Pops `true` the moment the bank sends the WebView to the payment's
/// `return_url` — the page there is never relied on — and `false` when the
/// customer closes it first.
class PaymentWebViewPage extends StatefulWidget {
  const PaymentWebViewPage({super.key, required this.payment});

  final Payment payment;

  @override
  State<PaymentWebViewPage> createState() => _PaymentWebViewPageState();
}

class _PaymentWebViewPageState extends State<PaymentWebViewPage> {
  late final WebViewController _controller;
  int _progress = 0;
  bool _closed = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            if (_isReturn(request.url)) {
              _finish(true);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          // A server-side redirect does not always pass through
          // `onNavigationRequest` on Android; this catches it as it starts.
          onPageStarted: (url) {
            if (_isReturn(url)) _finish(true);
          },
          onProgress: (progress) {
            if (mounted) setState(() => _progress = progress);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.payment.invoiceUrl!));
  }

  bool _isReturn(String url) {
    final returnUrl = widget.payment.returnUrl;
    return returnUrl != null &&
        returnUrl.isNotEmpty &&
        url.startsWith(returnUrl);
  }

  void _finish(bool redirected) {
    if (_closed || !mounted) return;
    _closed = true;
    Navigator.of(context).pop(redirected);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _finish(false);
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          clipBehavior: Clip.none,
          backgroundColor: AppColors.white,
          surfaceTintColor: Colors.transparent,
          centerTitle: true,
          leading: IconButton(
            tooltip: context.l10n.commonClose,
            onPressed: () => _finish(false),
            icon: HugeIcon(icon: AppIcons.close, color: AppColors.black),
          ),
          title: Text(
            context.l10n.paymentTitle,
            style: context.textTheme.titleMedium?.copyWith(
              color: AppColors.black,
              fontWeight: FontWeight.w700,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(2),
            child: _progress < 100
                ? LinearProgressIndicator(
                    value: _progress == 0 ? null : _progress / 100,
                    minHeight: 2,
                    color: AppColors.primary,
                    backgroundColor: Colors.transparent,
                  )
                : const SizedBox(height: 2),
          ),
        ),
        body: SafeArea(
          top: false,
          child: WebViewWidget(controller: _controller),
        ),
      ),
    );
  }
}
