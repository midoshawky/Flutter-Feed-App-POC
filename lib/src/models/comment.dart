class Comment {
  final String id;
  final String userId;
  final String userName;
  final String userUsername;
  final String userAvatarUrl;
  final String text;
  final DateTime timestamp;
  final List<Comment> replies;
  final int likesCount;

  Comment({
    String? id,
    required this.userId,
    required this.userName,
    this.userUsername = '',
    this.userAvatarUrl = '',
    required this.text,
    required this.timestamp,
    this.replies = const [],
    this.likesCount = 0,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  Comment copyWith({
    List<Comment>? replies,
    int? likesCount,
  }) {
    return Comment(
      id: id,
      userId: userId,
      userName: userName,
      userUsername: userUsername,
      userAvatarUrl: userAvatarUrl,
      text: text,
      timestamp: timestamp,
      replies: replies ?? this.replies,
      likesCount: likesCount ?? this.likesCount,
    );
  }
}
