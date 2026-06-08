import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../models/post_dto.dart';
import '../models/comment_dto.dart';
import '../models/user_dto.dart';
import 'api_client.dart';

class FeedApiDataSource {
  final ApiClient _client;
  final Map<String, UserDto> _userCache = {};

  FeedApiDataSource(this._client);

  // ── Posts ───────────────────────────────────────────────────────────────────

  Future<List<PostDto>> getFeedPosts({int page = 1, int limit = 10}) async {
    final response = await _client.dio.get(
      '/api/posts',
      queryParameters: {'per_page': limit, 'page': page},
    );
    final List<dynamic> items = response.data['data'] as List? ?? [];
    return items.map((item) {
      final json = item as Map<String, dynamic>;
      _cacheUserFromJson(json['user'] as Map<String, dynamic>?);
      return PostDto.fromJson(json);
    }).toList();
  }

  Future<PostDto?> getPostById(String postId) async {
    final response = await _client.dio.get('/api/posts/$postId');
    final data = response.data['data'];
    if (data == null) return null;
    final json = data as Map<String, dynamic>;
    _cacheUserFromJson(json['user'] as Map<String, dynamic>?);
    return PostDto.fromJson(json);
  }

  Future<String> uploadMedia(Uint8List bytes, String filename) async {
    final formData = FormData();
    formData.fields.add(const MapEntry('type', 'post_media'));
    formData.files.add(MapEntry(
      'file',
      MultipartFile.fromBytes(bytes, filename: filename),
    ));

    final response = await _client.dio.post('/api/upload', data: formData);
    final data = response.data['data'];
    return data['id'].toString();
  }

  Future<void> createPost({
    required String content,
    required String type,
    required List<String> tags,
    List<String> mediaIds = const [],
  }) async {
    final formData = FormData();
    formData.fields.add(MapEntry('content', content));
    formData.fields.add(MapEntry('type', type));
    for (int i = 0; i < tags.length; i++) {
      formData.fields.add(MapEntry('tags[$i]', tags[i]));
    }
    for (int i = 0; i < mediaIds.length; i++) {
      formData.fields.add(MapEntry('media_ids[$i]', mediaIds[i]));
    }
    await _client.dio.post('/api/posts', data: formData);
  }

  Future<void> updatePost(
    String postId, {
    String? content,
    String? type,
  }) async {
    final formData = FormData();
    formData.fields.add(const MapEntry('_method', 'PUT'));
    if (content != null) formData.fields.add(MapEntry('content', content));
    if (type != null) formData.fields.add(MapEntry('type', type));
    await _client.dio.post('/api/posts/$postId', data: formData);
  }

  Future<void> deletePost(String postId) async {
    await _client.dio.delete('/api/posts/$postId');
  }

  Future<void> createRepost(String postId, String content) async {
    await _client.dio.post(
      '/api/posts/$postId/repost',
      data: {'content': content},
    );
  }

  // ── Likes ────────────────────────────────────────────────────────────────────

  Future<void> toggleLike(String postId) async {
    await _client.dio.post(
      '/api/likes/toggle',
      data: {
        'likeable_id': int.tryParse(postId) ?? postId,
        'likeable_type': 'post',
      },
    );
  }

  // ── Comments ─────────────────────────────────────────────────────────────────

  Future<List<CommentDto>> getPostComments(String postId) async {
    final response = await _client.dio.get('/api/posts/$postId/comments');
    final List<dynamic> items = response.data['data'] as List? ?? [];
    return items
        .map((c) => CommentDto.fromJson(c as Map<String, dynamic>))
        .toList();
  }

  Future<void> addComment(
    String postId, {
    required String text,
    String? parentId,
  }) async {
    await _client.dio.post(
      '/api/posts/$postId/comments',
      data: {
        'text': text,
        if (parentId != null) 'parent_id': int.tryParse(parentId) ?? parentId,
      },
    );
  }

  Future<void> deleteComment(String commentId) async {
    await _client.dio.delete('/api/comments/$commentId');
  }

  Future<void> updateComment(String commentId, String text) async {
    await _client.dio.post('/api/comments/$commentId', data: {'text': text});
  }

  // ── Follows ──────────────────────────────────────────────────────────────────

  Future<void> toggleFollow(String username) async {
    await _client.dio.post('/api/follows/toggle/$username');
  }

  // ── Users ─────────────────────────────────────────────────────────────────────

  Future<UserDto?> getUserById(String id) async {
    if (_userCache.containsKey(id)) return _userCache[id];
    return null;
  }

  Future<List<UserDto>> getUsers(List<String> ids) async {
    return ids
        .map((id) => _userCache[id])
        .whereType<UserDto>()
        .toList();
  }

  void _cacheUserFromJson(Map<String, dynamic>? userJson) {
    if (userJson == null) return;
    final dto = UserDto.fromJson(userJson);
    _userCache[dto.id] = dto;
  }
}
