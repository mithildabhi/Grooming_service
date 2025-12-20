import 'package:flutter/material.dart';

class ReviewCard extends StatelessWidget {
  final Map<String, dynamic> review;
  final VoidCallback onDelete;
  final void Function(String reply) onReply;

  const ReviewCard({
    super.key,
    required this.review,
    required this.onDelete,
    required this.onReply,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController replyCtrl = TextEditingController(
      text: review['reply'] ?? '',
    );
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  review['customerName'] ?? 'Guest',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Text('${review['rating'] ?? 0} ★'),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: onDelete,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text('Service: ${review['serviceName'] ?? ''}'),
            const SizedBox(height: 6),
            Text(review['comment'] ?? ''),
            const SizedBox(height: 8),
            if ((review['reply'] ?? '').toString().isNotEmpty)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('Admin reply: ${review['reply']}'),
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: replyCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Reply to this review',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => onReply(replyCtrl.text.trim()),
                  child: const Text('Reply'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
