import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jd_style_logistics/core/constants/app_colors.dart';
import 'package:jd_style_logistics/core/widgets/theme_toggle_button.dart';

class CustomerChatSupportScreen extends StatefulWidget {
  const CustomerChatSupportScreen({super.key});

  @override
  State<CustomerChatSupportScreen> createState() =>
      _CustomerChatSupportScreenState();
}

class _Message {
  final String text;
  final bool fromUser;
  final String time;
  const _Message(
      {required this.text, required this.fromUser, required this.time});
}

class _CustomerChatSupportScreenState
    extends State<CustomerChatSupportScreen> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _agentTyping = false;

  final _messages = <_Message>[
    const _Message(
        text: 'Hi! Welcome to JD Logistics Support. How can I help you today?',
        fromUser: false,
        time: '10:31 AM'),
    const _Message(
        text: 'Your order JD-IND-2048 is currently in transit near Vadodara. ETA: Jun 20.',
        fromUser: false,
        time: '10:31 AM'),
  ];

  static const _quickReplies = [
    'Where is my shipment?',
    'Track my order',
    'Reschedule delivery',
    'File a complaint',
  ];

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _send([String? preset]) {
    final text = preset ?? _msgCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_Message(text: text, fromUser: true, time: _now()));
      _agentTyping = true;
    });
    _msgCtrl.clear();
    _scrollToBottom();

    Future.delayed(const Duration(milliseconds: 1600), () {
      if (!mounted) return;
      setState(() {
        _agentTyping = false;
        _messages.add(_Message(
            text: _agentReply(text), fromUser: false, time: _now()));
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _now() {
    final now = DateTime.now();
    final h = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final m = now.minute.toString().padLeft(2, '0');
    final period = now.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  String _agentReply(String msg) {
    final lower = msg.toLowerCase();
    if (lower.contains('track') || lower.contains('where') || lower.contains('shipment')) {
      return 'Your shipment JD-IND-2048 is en route from Mumbai to Delhi. '
          'Last checkpoint: Vadodara, Gujarat at 4:20 AM. ETA: Jun 20, 7:30 PM.';
    }
    if (lower.contains('reschedule') || lower.contains('delivery')) {
      return 'Sure! Please provide your preferred delivery date and time window. '
          'We will arrange a reschedule free of charge within 24 hours.';
    }
    if (lower.contains('complaint') || lower.contains('damage') || lower.contains('lost')) {
      return 'I\'m sorry to hear that. Please share your order ID and a brief '
          'description. Our team will initiate a complaint within 2 hours.';
    }
    return 'Thank you for reaching out! Our support team will get back to you within '
        '30 minutes. Is there anything else I can help with?';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg1 : const Color(0xFFEAF4FF),
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBg2 : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded,
              color: isDark ? Colors.white : AppColors.textDark, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Row(children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.support_agent_rounded,
                color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('JD Support',
                style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textDark,
                    fontWeight: FontWeight.w700,
                    fontSize: 15)),
            Row(children: [
              Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                      color: AppColors.success, shape: BoxShape.circle)),
              const SizedBox(width: 4),
              const Text('Online',
                  style: TextStyle(
                      color: AppColors.success,
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
            ]),
          ]),
        ]),
        actions: const [ThemeToggleButton(mini: true)],
      ),
      body: Column(
        children: [
          // Messages area
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              itemCount: _messages.length + (_agentTyping ? 1 : 0),
              itemBuilder: (_, i) {
                if (_agentTyping && i == _messages.length) {
                  return _TypingBubble(isDark: isDark);
                }
                final msg = _messages[i];
                return _Bubble(msg: msg, isDark: isDark);
              },
            ),
          ),

          // Quick replies
          if (_messages.length <= 2)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: _quickReplies
                    .map((q) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => _send(q),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.25)),
                              ),
                              child: Text(q,
                                  style: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),

          // Input bar
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkBg2 : Colors.white,
              border: Border(
                  top: BorderSide(
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.skyBorder)),
            ),
            child: Row(children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkBg3 : const Color(0xFFF4FAFF),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.skyBorder),
                  ),
                  child: TextField(
                    controller: _msgCtrl,
                    style: TextStyle(
                        color: isDark ? Colors.white : AppColors.textDark,
                        fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: TextStyle(
                          color: isDark
                              ? AppColors.darkSubtext
                              : AppColors.textDarkHint,
                          fontSize: 14),
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => _send(),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: AppColors.primaryGradient),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.send_rounded,
                      color: Colors.white, size: 20),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final _Message msg;
  final bool isDark;
  const _Bubble({required this.msg, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final isUser = msg.fromUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 28,
              height: 28,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.support_agent_rounded,
                  color: AppColors.primary, size: 14),
            ),
          ],
          Flexible(
            child: Container(
              constraints:
                  BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser
                    ? AppColors.primary
                    : (isDark ? AppColors.darkBg2 : Colors.white),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft:
                      Radius.circular(isUser ? 18 : 4),
                  bottomRight:
                      Radius.circular(isUser ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? AppColors.clayShadowDark
                        : AppColors.clayShadowLight,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: isUser
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Text(msg.text,
                      style: TextStyle(
                          color: isUser
                              ? Colors.white
                              : (isDark ? Colors.white : AppColors.textDark),
                          fontSize: 13,
                          height: 1.4)),
                  const SizedBox(height: 4),
                  Text(msg.time,
                      style: TextStyle(
                          color: isUser
                              ? Colors.white.withValues(alpha: 0.7)
                              : (isDark
                                  ? AppColors.darkSubtext
                                  : AppColors.textDarkHint),
                          fontSize: 10)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  final bool isDark;
  const _TypingBubble({required this.isDark});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(children: [
          Container(
            width: 28,
            height: 28,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.support_agent_rounded,
                color: AppColors.primary, size: 14),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkBg2 : Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
              ),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              _Dot(delay: 0, isDark: isDark),
              const SizedBox(width: 4),
              _Dot(delay: 150, isDark: isDark),
              const SizedBox(width: 4),
              _Dot(delay: 300, isDark: isDark),
            ]),
          ),
        ]),
      );
}

class _Dot extends StatefulWidget {
  final int delay;
  final bool isDark;
  const _Dot({required this.delay, required this.isDark});
  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _anim = Tween(begin: 1.0, end: 0.3)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _anim,
        builder: (_, __) => Opacity(
          opacity: _anim.value,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: widget.isDark ? AppColors.darkSubtext : AppColors.textDarkSecondary,
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
}
