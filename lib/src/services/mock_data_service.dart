import '../models/user.dart';
import '../models/post.dart';
import '../models/comment.dart';

class MockDataService {
  static final List<User> users = [
    User(
      id: '1',
      name: 'Mohamed Abduallah',
      username: '@MohamedAbd',
      avatarUrl: 'https://i.pravatar.cc/150?u=1',
    ),
    User(
      id: '2',
      name: 'Sara Hany',
      username: '@SaraHany16',
      avatarUrl: 'https://i.pravatar.cc/150?u=2',
    ),
    User(
      id: '3',
      name: 'Ahmed A.',
      username: '@AhmedAbdelrahman5',
      avatarUrl: 'https://i.pravatar.cc/150?u=3',
    ),
    User(
      id: '4',
      name: 'Hany Mohamed',
      username: '@SaraHany16', // Based on the prompt text 
      avatarUrl: 'https://i.pravatar.cc/150?u=4',
    ),
    User(
      id: '5',
      name: 'Ahmed Wael',
      username: '@AhmedWael0',
      avatarUrl: 'https://i.pravatar.cc/150?u=5',
    ),
    User(
      id: '6',
      name: 'أحمد عبدالله',
      username: '@AhmedMO19',
      avatarUrl: 'https://i.pravatar.cc/150?u=6',
    ),
    User(
      id: '7',
      name: 'Saleh Sallam',
      username: '@Sallehh',
      avatarUrl: 'https://i.pravatar.cc/150?u=7',
    ),
    User(
      id: '8',
      name: 'Nada Hassan',
      username: '@NadodH',
      avatarUrl: 'https://i.pravatar.cc/150?u=8',
    ),
    User(
      id: '9',
      name: 'Moaz Mohamed',
      username: '@MoazMO',
      avatarUrl: 'https://i.pravatar.cc/150?u=9',
    )
  ];

  static final List<Post> posts = [
    Post(
      userId: '2',
      content: 'How about we end the debate of a lifetime? Choose your side!',
      tags: ['#Figma', '#MobileDesign', '#WebDesign'],
      type: PostType.multiImage,
      mediaUrls: [
        'https://images.unsplash.com/photo-1541462608143-67571c6738dd?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1542744094-24638ea0b3b5?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1555066931-4365d14bab8c?auto=format&fit=crop&w=800&q=80',
      ],
      likesCount: 24,
      repostsCount: 1,
      timestamp: DateTime.now().subtract(const Duration(hours: 19)),
      comments: [
        Comment(
          userId: '1',
          userName: 'Mohamed Abduallah',
          text: 'Quo blanditiis saepe consequatur et. Velit et ad ea magnam consequuntur earum. Quia est perferendis. Unde in ipsam',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          replies: [
             Comment(
                userId: '5',
                userName: 'Ahmed Wael',
                text: 'still the wordmark looks cleans and modern',
                timestamp: DateTime.now().subtract(const Duration(days: 2)),
                replies: []
             ),
             Comment(
                userId: '7',
                userName: 'Saleh Sallam',
                text: 'every financial decision shapes the bigger picture',
                timestamp: DateTime.now().subtract(const Duration(days: 2)),
                replies: []
             )
          ]
        ),
        Comment(
          userId: '8',
          userName: 'Nada Hassan',
          text: 'Perfect!',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          replies: [
            Comment(
              userId: '1',
              userName: 'Mohamed Abduallah',
              text: 'Good point!',
              timestamp: DateTime.now().subtract(const Duration(days: 1)),
            ),
             Comment(
                userId: '9',
                userName: 'Moaz Mohamed',
                text: 'every financial decision shapes the bigger picture',
                timestamp: DateTime.now().subtract(const Duration(days: 2)),
             )
          ]
        )
      ],
    ),
    Post(
      userId: '3',
      content: 'Every invoice, every expense, every financial decision shapes the bigger picture',
      type: PostType.text,
      likesCount: 10,
      repostsCount: 0,
      timestamp: DateTime.now().subtract(const Duration(hours: 19)),
      comments: [],
    ),
    Post(
      userId: '4',
      content: 'How about we end the debate of a lifetime? Choose your side!',
      type: PostType.image,
      imageUrl: 'https://images.unsplash.com/photo-1616469829581-73993eb86b02?auto=format&fit=crop&w=800&q=80',
      mediaUrls: [
        'https://images.unsplash.com/photo-1616469829581-73993eb86b02?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1542744094-24638ea0b3b5?auto=format&fit=crop&w=800&q=80',
      ],
      likesCount: 18,
      repostsCount: 1,
      timestamp: DateTime.now().subtract(const Duration(hours: 19)),
      comments: [],
    ),
    Post(
      userId: '5',
      content: 'Accounting isn’t just numbers it’s the language of your business. Every invoice, every expense, every financial decision shapes the bigger picture. When your records are clear and accurate, your next steps become stronger and smarter. Start organizing your books today and let your numbers tell your success story.',
      type: PostType.text,
      likesCount: 24,
      repostsCount: 0,
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      comments: [],
    ),
    Post(
      userId: '6',
      content: 'Accounting isn’t just numbers it’s the language of your business. Every invoice, every expense, every financial decision shapes the bigger picture.',
      type: PostType.video,
      imageUrl: 'https://images.unsplash.com/photo-1498050108023-c5249f4df085?auto=format&fit=crop&w=800&q=80',
      likesCount: 54,
      repostsCount: 3,
      timestamp: DateTime.now().subtract(const Duration(days: 4)),
      comments: [],
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
