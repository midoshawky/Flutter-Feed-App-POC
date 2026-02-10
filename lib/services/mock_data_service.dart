import '../models/user.dart';
import '../models/post.dart';
import '../models/comment.dart';

class MockDataService {
  static final List<User> users = [
    User(
      id: '1',
      name: 'Muhammed Shawky',
      username: '@m_shawky',
      avatarUrl: 'https://i.pravatar.cc/150?u=1',
    ),
    User(
      id: '2',
      name: 'Jane Doe',
      username: '@jane_d',
      avatarUrl: 'https://i.pravatar.cc/150?u=2',
    ),
    User(
      id: '3',
      name: 'John Smith',
      username: '@jsmith',
      avatarUrl: 'https://i.pravatar.cc/150?u=3',
    ),
  ];

  static final List<Post> posts = [
    Post(
      userId: '1',
      content:
          'Excited to showcase this Flutter Feed POC! It\'s built with Riverpod for robust state management and designed for seamless web integration. #Flutter #WebDev',
      type: PostType.text,
      likesCount: 24,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      comments: [
        Comment(
          userId: '2',
          userName: 'Jane Doe',
          text: 'Looks amazing! The UI is very clean.',
          timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
        ),
      ],
    ),
    Post(
      userId: '2',
      content:
          'Just finished a beautiful hike in the mountains. The views were breathtaking! 🏔️',
      imageUrl:
          'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&w=800&q=80',
      type: PostType.image,
      likesCount: 156,
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      comments: [],
    ),
    Post(
      userId: '3',
      content:
          'Working on some cool new features for the next release. Stay tuned!',
      type: PostType.text,
      likesCount: 12,
      timestamp: DateTime.now().subtract(const Duration(hours: 8)),
      comments: [
        Comment(
          userId: '1',
          userName: 'Muhammed Shawky',
          text: 'Can\'t wait to see what\'s coming next!',
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        ),
      ],
    ),
  ];

  static User? getUserById(String id) {
    try {
      return users.firstWhere((u) => u.id == id);
    } catch (_) {
      return null;
    }
  }
}
