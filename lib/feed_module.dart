library feed_module;

// Export Domain Entities
export 'src/domain/entities/post_entity.dart';
export 'src/domain/entities/comment_entity.dart';
export 'src/domain/entities/user_entity.dart';

// Export Models
export 'src/models/post.dart';
export 'src/models/comment.dart';
export 'src/models/user.dart';

// Export Providers
export 'src/presentation/providers/feed_providers.dart';
export 'src/presentation/providers/optimistic_feed_provider.dart';
export 'src/presentation/providers/di_providers.dart';

// Export UI Widgets
export 'src/presentation/screens/feed_screen.dart';
export 'src/presentation/widgets/post_card.dart';
export 'src/presentation/widgets/create_post_card.dart';

// Export Services
export 'src/services/firestore_seed_service.dart';
export 'src/services/mock_data_service.dart';
