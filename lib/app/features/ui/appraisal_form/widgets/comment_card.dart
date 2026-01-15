import 'package:flutter/material.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/features/widgets/input_text_field.dart';

class CommentCard extends StatefulWidget {
  final String projectTitle;
  final String userName;
  final String userAvatar;
  final String commentText;
  final String commentTime;
  final int likesCount;
  final int repliesCount;
  final VoidCallback? onLike;
  final VoidCallback? onReply;
  final Function(String)? onSubmitComment;
  final bool isExpanded;
  final VoidCallback? onToggleExpand;

  const CommentCard({
    super.key,
    required this.projectTitle,
    required this.userName,
    required this.userAvatar,
    required this.commentText,
    this.commentTime = '',
    this.likesCount = 0,
    this.repliesCount = 0,
    this.onLike,
    this.onReply,
    this.onSubmitComment,
    this.isExpanded = false,
    this.onToggleExpand,
  });

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  final TextEditingController _commentController = TextEditingController();
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isExpanded;
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    widget.onToggleExpand?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: _toggleExpand,
            child: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.projectTitle,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: const Color(0xFF64748B),
                  ),
                ],
              ),
            ),
          ),

          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundImage:
                            widget.userAvatar.isNotEmpty
                                ? NetworkImage(widget.userAvatar)
                                : null,
                        backgroundColor: const Color(0xFF94A3B8),
                        child:
                            widget.userAvatar.isEmpty
                                ? Text(
                                  widget.userName.isNotEmpty
                                      ? widget.userName[0].toUpperCase()
                                      : 'U',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                                : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  widget.userName,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'added new ',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                                const Text(
                                  'Comment',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF0EA5E9),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.commentText,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF475569),
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      InkWell(
                        onTap: widget.onLike,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.thumb_up,
                              size: 16,
                              color: Color(0xFF0EA5E9),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'likes',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      InkWell(
                        onTap: widget.onReply,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.reply,
                              size: 16,
                              color: Color(0xFF64748B),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'replies',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: InputTextField(
                          hintText: 'Type your comment here',
                          isRequiredField: false,
                          controller: _commentController,
                          maxLine: 1,
                          disableTitle: true,
                          bgrColor: true,
                          suffixIcon: AppAssets.icFileKeeper,
                          onSuffixAction: () {},
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        height: 44,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0EA5E9),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 22),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                          ),
                          onPressed: () {
                            if (_commentController.text.isNotEmpty) {
                              widget.onSubmitComment?.call(
                                _commentController.text,
                              );
                              _commentController.clear();
                            }
                          },
                          child: const Text(
                            'Gửi',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
