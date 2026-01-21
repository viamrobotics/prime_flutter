import 'package:flutter/widgets.dart';
import 'package:prime_flutter/prime_flutter.dart';

class ToastPage extends StatefulWidget {
  final ToastVariant variant;
  final bool showAction;
  final String message;

  const ToastPage({super.key, this.variant = ToastVariant.neutral, this.showAction = false, this.message = 'Toast message'});

  @override
  State<ToastPage> createState() => _ToastPageState();
}

class _ToastPageState extends State<ToastPage> {
  @override
  void initState() {
    super.initState();
    // Auto-show toast when page loads/reloads to simulate preview
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showToast();
    });
  }

  void _showToast() {
    Toast.show(
      context,
      message: widget.message,
      variant: widget.variant,
      duration: const Duration(days: 365), // Keep it visible for docs preview
      action: widget.showAction ? Button(variant: ButtonVariant.ghost, label: const Text('ACTION'), onPressed: () {}) : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PrimeScaffold(
      body: Center(
        child: Button(label: const Text('Show Toast'), onPressed: _showToast),
      ),
    );
  }
}
