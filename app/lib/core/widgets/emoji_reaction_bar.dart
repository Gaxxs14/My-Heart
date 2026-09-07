import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class EmojiReactionBar extends StatelessWidget {
  final List<dynamic> reactions;
  final String? currentUserId;
  final Function(String emoji) onReact;
  final bool compact;
  final List<String> availableEmojis;

  const EmojiReactionBar({
    super.key,
    required this.reactions,
    required this.currentUserId,
    required this.onReact,
    this.compact = false,
    this.availableEmojis = const ['❤️', '🥰', '😍', '🥺', '🔥', '💌', '✨'],
  });

  @override
  Widget build(BuildContext context) {
    // Group reactions by emoji
    final Map<String, List<String>> emojiGroups = {};
    String? myActiveEmoji;

    for (final r in reactions) {
      if (r is Map) {
        final emoji = r['emoji']?.toString() ?? '';
        final userId = r['user_id']?.toString() ?? '';
        final userName = r['user_name']?.toString() ?? 'Pareja';

        if (emoji.isNotEmpty) {
          emojiGroups.putIfAbsent(emoji, () => []).add(userName);
          if (userId == currentUserId) {
            myActiveEmoji = emoji;
          }
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Active reaction pills (if any)
        if (emojiGroups.isNotEmpty) ...[
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: emojiGroups.entries.map((entry) {
              final emoji = entry.key;
              final users = entry.value;
              final isMyReaction = emoji == myActiveEmoji;

              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onReact(emoji);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isMyReaction ? AppTheme.softPink : const Color(0xFFF7F7F7),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isMyReaction ? AppTheme.primaryRose : const Color(0xFFE0E0E0),
                      width: isMyReaction ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(emoji, style: const TextStyle(fontSize: 13)),
                      const SizedBox(width: 4),
                      Text(
                        '${users.length}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isMyReaction ? AppTheme.primaryRose : AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
        ],

        // Emoji Selector Tray
        Container(
          padding: EdgeInsets.symmetric(horizontal: compact ? 6 : 10, vertical: compact ? 4 : 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7F9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFFE5EC)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: availableEmojis.map((emoji) {
              final isSelected = emoji == myActiveEmoji;

              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onReact(emoji);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  padding: EdgeInsets.all(isSelected ? 6 : 4),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.softPink : Colors.transparent,
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(color: AppTheme.primaryRose, width: 2)
                        : Border.all(color: Colors.transparent),
                    boxShadow: isSelected
                        ? [BoxShadow(color: AppTheme.primaryRose.withOpacity(0.3), blurRadius: 6)]
                        : null,
                  ),
                  child: Text(
                    emoji,
                    style: TextStyle(fontSize: compact ? 15 : 18),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
