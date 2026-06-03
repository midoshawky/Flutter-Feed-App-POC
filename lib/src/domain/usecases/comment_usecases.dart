import '../entities/comment_entity.dart';
import '../repositories/post_repository.dart';

class AddCommentUseCase {
  final PostRepository repository;
  AddCommentUseCase(this.repository);

  Future<void> call(String postId, CommentEntity comment) =>
      repository.addComment(postId, comment);
}

class AddReplyUseCase {
  final PostRepository repository;
  AddReplyUseCase(this.repository);

  Future<void> call({
    required String postId,
    required String parentCommentId,
    required CommentEntity reply,
  }) =>
      repository.addReply(
        postId: postId,
        parentCommentId: parentCommentId,
        reply: reply,
      );
}

class DeleteCommentUseCase {
  final PostRepository repository;
  DeleteCommentUseCase(this.repository);

  Future<void> call(String commentId) => repository.deleteComment(commentId);
}

class UpdateCommentUseCase {
  final PostRepository repository;
  UpdateCommentUseCase(this.repository);

  Future<void> call(String commentId, String text) =>
      repository.updateComment(commentId, text);
}
