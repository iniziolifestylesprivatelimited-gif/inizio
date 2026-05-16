import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';

class ChatScreen extends StatefulWidget {
  final String adminId;
  const ChatScreen({super.key, required this.adminId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  final TextEditingController controller = TextEditingController();
  final ScrollController scroll = ScrollController();

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (scroll.hasClients) {
        scroll.animateTo(
          scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final chat = Provider.of<ChatProvider>(context, listen: false);

    final meId = auth.user!.id;
    final token = auth.token!;

    chat.connectSocket(meId);
    chat.setPeer(widget.adminId, token: token);
    chat.fetchChat(token, meId, widget.adminId).then((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    final chat = Provider.of<ChatProvider>(context, listen: false);
    chat.stopTyping(); // be nice
    controller.dispose();
    scroll.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final chat = Provider.of<ChatProvider>(context, listen: false);
    if (state != AppLifecycleState.resumed) chat.stopTyping();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final chat = context.watch<ChatProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Chat with Support", style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: const Color(0xFFF7F7F7),
              child: ListView.builder(
                controller: scroll,
                padding: const EdgeInsets.all(12),
                itemCount: chat.messages.length + (chat.isTypingFromPeer ? 1 : 0),
                itemBuilder: (_, index) {
                  if (chat.isTypingFromPeer && index == chat.messages.length) {
                    return const _TypingBubble();
                  }

                  final msg = chat.messages[index];
                  final senderId = (msg["sender"] ?? "").toString();
                  final isMe = senderId == auth.user!.id;
                  final status = (msg["status"] ?? (msg["isRead"] == true ? "seen" : "sent")).toString();

                  return Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      constraints: const BoxConstraints(maxWidth: 280),
                      decoration: BoxDecoration(
                        color: isMe ? Colors.black : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: isMe ? null : Border.all(color: Colors.black12),
                        boxShadow: const [BoxShadow(blurRadius: 1, color: Colors.black12)],
                      ),
                      child: Column(
                        crossAxisAlignment:
                            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          Text(
                            (msg["message"] ?? "").toString(),
                            style: TextStyle(
                              color: isMe ? Colors.white : Colors.black,
                              fontSize: 15,
                            ),
                          ),
                          if (isMe) ...[
                            const SizedBox(height: 4),
                            _Ticks(status: status),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          SafeArea(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      onChanged: (_) => chat.sendTyping(),
                      decoration: InputDecoration(
                        hintText: "Type a message…",
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.black87),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Material(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        final text = controller.text.trim();
                        if (text.isEmpty) return;
                        chat.sendMessage(text);
                        controller.clear();
                        chat.stopTyping();
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(Icons.send, color: Colors.white),
                      ),
                    ),
                  ),
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
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black12),
        ),
        child: const Text(
          "typing…",
          style: TextStyle(color: Colors.black54),
        ),
      ),
    );
  }
}

class _Ticks extends StatelessWidget {
  final String status; // sent | delivered | seen
  const _Ticks({required this.status});

  @override
  Widget build(BuildContext context) {
    // black & white ticks only
    if (status == "seen") {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.check, size: 16, color: Colors.white),
          Icon(Icons.check, size: 16, color: Colors.white),
        ],
      );
    } else if (status == "delivered") {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.check, size: 16, color: Colors.white70),
          Icon(Icons.check, size: 16, color: Colors.white70),
        ],
      );
    } else {
      return const Icon(Icons.check, size: 16, color: Colors.white70);
    }
  }
}
