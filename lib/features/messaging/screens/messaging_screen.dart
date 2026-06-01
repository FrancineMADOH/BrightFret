import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/http/api_exception.dart';
import '../../../core/router/app_router.dart';
import '../../../core/storage/token_storage.dart';
import '../../../shared/widgets/bf_error_screen.dart';
import '../../../shared/widgets/bf_loading_indicator.dart';
import '../models/shipment_message.dart';
import '../providers/messages_provider.dart';

/// S11 — Chat between the client and the forwarder.
/// Polls for new messages every 30s via [Timer.periodic] + silent [MessagesNotifier.refresh].
class MessagingScreen extends ConsumerStatefulWidget {
  const MessagingScreen({
    super.key,
    required this.suffix,
    this.instanceUrl = '',
  });

  final String suffix;
  final String instanceUrl;

  @override
  ConsumerState<MessagingScreen> createState() => _MessagingScreenState();
}

class _MessagingScreenState extends ConsumerState<MessagingScreen> {
  late final TextEditingController _inputController;
  Timer? _pollTimer;
  bool _sending = false;
  String? _sendError;
  bool _redirectingToAuth = false;

  static const _pollInterval = Duration(seconds: 30);

  @override
  void initState() {
    super.initState();
    _inputController = TextEditingController();
    _pollTimer = Timer.periodic(_pollInterval, (_) {
      if (!mounted) return;
      ref
          .read(messagesNotifierProvider(widget.suffix, widget.instanceUrl)
              .notifier)
          .refresh();
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _inputController.dispose();
    super.dispose();
  }

  Future<void> _handleSend() async {
    final text = _inputController.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() {
      _sending = true;
      _sendError = null;
    });

    try {
      await ref
          .read(messagesNotifierProvider(widget.suffix, widget.instanceUrl)
              .notifier)
          .sendMessage(text);
      _inputController.clear();
    } on UnauthorizedException {
      if (!mounted) return;
      await ref
          .read(tokenStorageProvider)
          .deleteToken(widget.instanceUrl, widget.suffix);
      if (!mounted) return;
      context.goNamed(
        AppRoute.phoneVerify.name,
        pathParameters: {'suffix': widget.suffix},
        queryParameters: {'instance': widget.instanceUrl},
      );
    } on ApiException {
      if (mounted) {
        setState(() {
          _sendError = AppLocalizations.of(context)!.messageSendError;
        });
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _handleLoadError(BuildContext context, Object error) {
    if (error is UnauthorizedException && !_redirectingToAuth) {
      _redirectingToAuth = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!context.mounted) return;
        await ref
            .read(tokenStorageProvider)
            .deleteToken(widget.instanceUrl, widget.suffix);
        if (context.mounted) {
          context.goNamed(
            AppRoute.phoneVerify.name,
            pathParameters: {'suffix': widget.suffix},
            queryParameters: {'instance': widget.instanceUrl},
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(
      messagesNotifierProvider(widget.suffix, widget.instanceUrl),
    );
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.sectionMessaging,
          style: AppTextStyles.label.copyWith(color: AppColors.white),
        ),
        leading: BackButton(
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(AppRoute.home.path),
        ),
      ),
      body: Column(
        children: [
          if (_sendError != null)
            _ErrorBanner(message: _sendError!),
          Expanded(
            child: messagesAsync.when(
              loading: () => const BfLoadingIndicator(),
              error: (err, _) {
                _handleLoadError(context, err);
                if (err is UnauthorizedException) {
                  return const BfLoadingIndicator();
                }
                if (err is NetworkException) {
                  return BfErrorScreen(
                    icon: Icons.wifi_off_outlined,
                    title: l10n.errorNetworkTitle,
                    body: l10n.offlineMessagingUnavailable,
                    actions: [
                      BfErrorAction(
                        label: l10n.retry,
                        onTap: () => ref.invalidate(
                          messagesNotifierProvider(
                              widget.suffix, widget.instanceUrl),
                        ),
                      ),
                    ],
                  );
                }
                return BfErrorScreen(
                  icon: Icons.message_outlined,
                  title: l10n.errorNetworkTitle,
                  body: l10n.errorNetworkBody,
                  actions: [
                    BfErrorAction(
                      label: l10n.retry,
                      onTap: () => ref.invalidate(
                        messagesNotifierProvider(
                            widget.suffix, widget.instanceUrl),
                      ),
                    ),
                  ],
                );
              },
              data: (messages) => messages.isEmpty
                  ? _EmptyState(l10n: l10n)
                  : _MessageList(messages: messages, l10n: l10n),
            ),
          ),
          _MessageInput(
            controller: _inputController,
            sending: _sending,
            onSend: _handleSend,
            l10n: l10n,
          ),
        ],
      ),
    );
  }
}

// ── Error banner ──────────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.statusError.withAlpha(25),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.error_outline,
                color: AppColors.statusError, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.statusError),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 72,
              color: AppColors.statusArchived.withAlpha(100),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noMessagesYet,
              style:
                  AppTextStyles.body.copyWith(color: AppColors.statusArchived),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Message list ──────────────────────────────────────────────────────────────

class _MessageList extends StatelessWidget {
  const _MessageList({
    required this.messages,
    required this.l10n,
  });

  final List<ShipmentMessage> messages;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final reversed = messages.reversed.toList();
    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: reversed.length,
      itemBuilder: (_, i) =>
          _MessageBubble(message: reversed[i], l10n: l10n),
    );
  }
}

// ── Message bubble ────────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.l10n,
  });

  final ShipmentMessage message;
  final AppLocalizations l10n;

  static String _formatTime(DateTime dt, AppLocalizations l10n) {
    final diff = DateTime.now().difference(dt);
    if (diff.isNegative || diff.inMinutes < 1) return l10n.justNow;
    if (diff.inHours < 1) return l10n.minutesAgo(diff.inMinutes);
    if (diff.inDays < 1) return l10n.hoursAgo(diff.inHours);
    return l10n.daysAgo(diff.inDays);
  }

  @override
  Widget build(BuildContext context) {
    final isClient = message.isFromClient;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isClient ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isClient) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary.withAlpha(220),
              child: const Icon(Icons.support_agent,
                  color: AppColors.white, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isClient
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isClient ? AppColors.primary : AppColors.divider,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isClient ? 16 : 4),
                      bottomRight: Radius.circular(isClient ? 4 : 16),
                    ),
                  ),
                  child: Text(
                    message.body,
                    style: AppTextStyles.body.copyWith(
                      color:
                          isClient ? AppColors.white : Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(message.createdAt, l10n),
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.statusArchived),
                ),
              ],
            ),
          ),
          if (isClient) const SizedBox(width: 8),
        ],
      ),
    );
  }
}

// ── Message input ─────────────────────────────────────────────────────────────

class _MessageInput extends StatelessWidget {
  const _MessageInput({
    required this.controller,
    required this.sending,
    required this.onSend,
    required this.l10n,
  });

  final TextEditingController controller;
  final bool sending;
  final VoidCallback onSend;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(color: AppColors.divider),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: l10n.messageHint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
                onSubmitted: (_) => onSend(),
              ),
            ),
            const SizedBox(width: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: sending
                  ? const SizedBox(
                      width: 48,
                      height: 48,
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      ),
                    )
                  : IconButton(
                      key: const ValueKey('send'),
                      onPressed: onSend,
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.all(12),
                        shape: const CircleBorder(),
                      ),
                      icon: const Icon(Icons.send_rounded),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
