import 'package:flutter/material.dart';

class ErrorBannerWidget extends StatefulWidget {
  final String message;
  final VoidCallback? onClose;

  const ErrorBannerWidget({super.key, required this.message, this.onClose});

  @override
  State<ErrorBannerWidget> createState() => _ErrorBannerWidgetState();
}

class _ErrorBannerWidgetState extends State<ErrorBannerWidget> {
  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: const Key('error_banner'),
      direction: DismissDirection.horizontal,
      onDismissed: (_) => widget.onClose?.call(),
      child: Container(
        color: Colors.red,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                widget.message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: widget.onClose,
            ),
          ],
        ),
      ),
    );
  }
}
