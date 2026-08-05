import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/connectivity_provider.dart';
import '../../../core/http/api_exception.dart';
import '../../../core/router/app_router.dart';
import '../../../core/storage/token_storage.dart';
import '../../../shared/widgets/bf_bottom_nav.dart';
import '../../../shared/widgets/bf_error_screen.dart';
import '../../../shared/widgets/bf_loading_indicator.dart';
import '../models/shipment_message.dart';
import '../providers/messages_provider.dart';
import '../services/messaging_service.dart';

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
  XFile? _pendingAttachment;

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

  Future<void> _pickAttachment() async {
    final l10n = AppLocalizations.of(context)!;
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file == null) return;
    // Size guard before encoding (5 MB raw)
    final bytes = await file.readAsBytes();
    if (bytes.length > 5 * 1024 * 1024) {
      if (mounted) {
        setState(() => _sendError = l10n.attachmentTooLarge);
      }
      return;
    }
    if (mounted) {
      setState(() {
        _pendingAttachment = file;
        _sendError = null;
      });
    }
  }

  Future<void> _handleSend() async {
    final text = _inputController.text.trim();
    final hasAttachment = _pendingAttachment != null;
    if ((text.isEmpty && !hasAttachment) || _sending) return;

    if (!ref.read(connectivityNotifierProvider)) {
      setState(() {
        _sendError = AppLocalizations.of(context)!.offlineMessagingUnavailable;
      });
      return;
    }

    setState(() {
      _sending = true;
      _sendError = null;
    });

    final attachmentToSend = _pendingAttachment;
    try {
      await ref
          .read(messagesNotifierProvider(widget.suffix, widget.instanceUrl)
              .notifier)
          .sendMessage(text, attachment: attachmentToSend);
      _inputController.clear();
      if (mounted) setState(() => _pendingAttachment = null);
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
    } on AttachmentTooLargeException {
      if (mounted) {
        setState(() {
          _sendError = AppLocalizations.of(context)!.attachmentTooLarge;
        });
      }
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
    final isOnline = ref.watch(connectivityNotifierProvider);
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
      bottomNavigationBar: const BfBottomNavBar(currentIndex: 1),
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
                  : _MessageList(
                      messages: messages,
                      instanceUrl: widget.instanceUrl,
                      l10n: l10n,
                    ),
            ),
          ),
          _MessageInput(
            controller: _inputController,
            sending: _sending,
            isOnline: isOnline,
            pendingAttachment: _pendingAttachment,
            onSend: _handleSend,
            onAttach: _pickAttachment,
            onRemoveAttachment: () =>
                setState(() => _pendingAttachment = null),
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
    required this.instanceUrl,
    required this.l10n,
  });

  final List<ShipmentMessage> messages;
  final String instanceUrl;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final reversed = messages.reversed.toList();
    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: reversed.length,
      itemBuilder: (_, i) => _MessageBubble(
        message: reversed[i],
        instanceUrl: instanceUrl,
        l10n: l10n,
      ),
    );
  }
}

// ── Message bubble ────────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.instanceUrl,
    required this.l10n,
  });

  final ShipmentMessage message;
  final String instanceUrl;
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
    final cs = Theme.of(context).colorScheme;
    final bubbleColor =
        isClient ? AppColors.primary : cs.surfaceContainerHighest;
    final textColor = isClient ? AppColors.white : cs.onSurface;

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
                    color: bubbleColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isClient ? 16 : 4),
                      bottomRight: Radius.circular(isClient ? 4 : 16),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (message.body.isNotEmpty)
                        Text(
                          message.body,
                          style: AppTextStyles.body.copyWith(color: textColor),
                        ),
                      if (message.attachments.isNotEmpty) ...[
                        if (message.body.isNotEmpty) const SizedBox(height: 8),
                        ...message.attachments.map((att) => _AttachmentTile(
                              attachment: att,
                              instanceUrl: instanceUrl,
                              isClient: isClient,
                              l10n: l10n,
                            )),
                      ],
                    ],
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

// ── Attachment tile inside a bubble ──────────────────────────────────────────

class _AttachmentTile extends StatelessWidget {
  const _AttachmentTile({
    required this.attachment,
    required this.instanceUrl,
    required this.isClient,
    required this.l10n,
  });

  final MessageAttachment attachment;
  final String instanceUrl;
  final bool isClient;
  final AppLocalizations l10n;

  void _open(BuildContext context) {
    if (attachment.url.isEmpty) return;
    final fullUrl = '$instanceUrl${attachment.url}';
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _FullScreenImageViewer(
          url: fullUrl,
          label: attachment.name,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (attachment.isImage && attachment.url.isNotEmpty) {
      final fullUrl = '$instanceUrl${attachment.url}';
      return GestureDetector(
        onTap: () => _open(context),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            fullUrl,
            width: 200,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _fallbackChip(context),
          ),
        ),
      );
    }
    return _fallbackChip(context);
  }

  Widget _fallbackChip(BuildContext context) {
    final textColor = isClient
        ? AppColors.white
        : Theme.of(context).colorScheme.onSurface;
    return InkWell(
      onTap: () => _open(context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.attach_file, size: 16, color: textColor.withAlpha(180)),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              attachment.name,
              style: AppTextStyles.caption.copyWith(
                color: textColor,
                decoration: TextDecoration.underline,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Full-screen image viewer (for message attachments) ────────────────────────

class _FullScreenImageViewer extends StatelessWidget {
  const _FullScreenImageViewer({required this.url, required this.label});

  final String url;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(label,
            style: const TextStyle(color: Colors.white, fontSize: 14)),
      ),
      body: InteractiveViewer(
        maxScale: 5.0,
        minScale: 0.5,
        child: Center(
          child: Image.network(
            url,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.broken_image_outlined,
              color: Colors.white54,
              size: 64,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Message input ─────────────────────────────────────────────────────────────

class _MessageInput extends StatelessWidget {
  const _MessageInput({
    required this.controller,
    required this.sending,
    required this.isOnline,
    required this.pendingAttachment,
    required this.onSend,
    required this.onAttach,
    required this.onRemoveAttachment,
    required this.l10n,
  });

  final TextEditingController controller;
  final bool sending;
  final bool isOnline;
  final XFile? pendingAttachment;
  final VoidCallback onSend;
  final VoidCallback onAttach;
  final VoidCallback onRemoveAttachment;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: cs.surface,
          border: Border(top: BorderSide(color: cs.outlineVariant)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Attachment preview row
            if (pendingAttachment != null)
              _AttachmentPreview(
                file: pendingAttachment!,
                onRemove: onRemoveAttachment,
                l10n: l10n,
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Attach button
                IconButton(
                  icon: Icon(
                    Icons.attach_file,
                    color: isOnline
                        ? AppColors.primary
                        : AppColors.statusArchived,
                  ),
                  tooltip: l10n.attachFile,
                  onPressed: isOnline ? onAttach : null,
                ),
                // Text field
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
                      fillColor: cs.surfaceContainerHighest,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                    ),
                    onSubmitted: (_) => onSend(),
                  ),
                ),
                const SizedBox(width: 8),
                // Send button
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: sending
                      ? const SizedBox(
                          width: 48,
                          height: 48,
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child:
                                CircularProgressIndicator(strokeWidth: 2.5),
                          ),
                        )
                      : IconButton(
                          key: const ValueKey('send'),
                          onPressed: isOnline ? onSend : null,
                          style: IconButton.styleFrom(
                            backgroundColor: isOnline
                                ? AppColors.primary
                                : AppColors.statusArchived,
                            foregroundColor: AppColors.white,
                            disabledBackgroundColor: AppColors.statusArchived,
                            padding: const EdgeInsets.all(12),
                            shape: const CircleBorder(),
                          ),
                          icon: Icon(
                            isOnline ? Icons.send_rounded : Icons.wifi_off,
                          ),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Attachment preview (before send) ─────────────────────────────────────────

class _AttachmentPreview extends StatelessWidget {
  const _AttachmentPreview({
    required this.file,
    required this.onRemove,
    required this.l10n,
  });

  final XFile file;
  final VoidCallback onRemove;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(file.path),
              width: 56,
              height: 56,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              file.name,
              style: AppTextStyles.caption,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            tooltip: l10n.removeAttachment,
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}
