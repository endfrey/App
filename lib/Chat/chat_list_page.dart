import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wstore/services/shared_pref.dart';
import 'chat_room_page.dart';

class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key});

  // ฟังก์ชันลบค่า unread
  Future<void> _markAsRead(String chatId) async {
    final chatRef = FirebaseFirestore.instance.collection("chats").doc(chatId);
    await chatRef.update({"unreadCount": 0});
  }

  @override
  Widget build(BuildContext context) {
    final SharedPreferenceHelper sharedPref = SharedPreferenceHelper();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F9FF),
      appBar: AppBar(
        title: const Text("แชทกับลูกค้า"),
        backgroundColor: const Color(0xFF00ACC1),
        elevation: 2,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("chats")
            .orderBy("updatedAt", descending: true)
            .snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snap.hasData || snap.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "ยังไม่มีห้องแชท",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            );
          }

          final docs = snap.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 6),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final data = docs[i].data() as Map<String, dynamic>;
              final chatId = docs[i].id;

              return FutureBuilder(
                future: sharedPref.getUserName(),
                builder: (context, AsyncSnapshot<String?> snapshot) {
                  String fallbackName = snapshot.data ?? "ลูกค้า";

                  final username = data["username"] ?? data["userName"] ?? fallbackName;
                  final lastMessage = data["lastMessage"] ?? "";

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 2,
                    child: ListTile(
                      // เอา leading ออก
                      title: Text(
                        username,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Color(0xFF0C4A6E),
                        ),
                      ),
                      subtitle: Text(
                        lastMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 14,
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatRoomPage(
                              chatId: chatId,
                              currentUserId: "admin",
                            ),
                          ),
                        );

                        await _markAsRead(chatId);
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
