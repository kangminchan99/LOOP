import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:logging/logging.dart';
import 'package:loop/src/core/network/error/dio_error_handler.dart';
import 'package:loop/src/core/network/error/failures.dart';
import 'package:loop/src/features/post/data/data_sources/local/post_local_data_source.dart';
import 'package:loop/src/features/post/data/data_sources/remote/post_api.dart';
import 'package:loop/src/features/post/domain/models/post_detail_model.dart';
import 'package:loop/src/features/post/domain/models/post_list_model.dart';
import 'package:loop/src/features/post/domain/models/post_request_model.dart';
import 'package:loop/src/features/post/domain/models/post_response_model.dart';
import 'package:loop/src/features/post/domain/repositories/abstract_post_repository.dart';
import 'package:loop/src/shared/domain/models/cursor_paginated_response.dart';

class PostRepositoryImpl implements AbstractPostRepository {
  PostRepositoryImpl(this._postApi, this._localDataSource)
    : _session = _localDataSource.session;

  final int _session;
  int? _snapshotRevision;
  DateTime? _snapshotFetchedAt;
  final _logger = Logger('PostRepositoryImpl');

  Future<void> _updateCache(Future<void> Function() update) async {
    if (_session != _localDataSource.session) return;
    try {
      await update();
    } catch (error, stack) {
      _logger.warning('게시글 캐시 갱신 실패', error, stack);
      // 오래된 내용을 다시 표시하지 않도록 캐시를 무효화.
      try {
        await _localDataSource.invalidate();
      } catch (error, stack) {
        _logger.warning('게시글 캐시 정리 실패', error, stack);
      }
    }
  }

  final PostApi _postApi;
  final PostLocalDataSource _localDataSource;

  @override
  Future<Either<Failure, PostDetailModel>> createPost(
    PostRequestModel request,
  ) async {
    try {
      final response = await _postApi.createPost(request);
      await _updateCache(_localDataSource.invalidate);

      final data = response.data;

      if (data == null) {
        return const Left(ServerFailure('응답 데이터가 없습니다.', 500));
      }

      final parsed = PostResponseModel.fromJson(data);

      return Right(
        PostDetailModel(
          id: parsed.id,
          title: parsed.title,
          content: parsed.content,
          authorId: parsed.authorId,
          updatedAt: parsed.updatedAt,
        ),
      );
    } on DioException catch (e) {
      return Left(
        ServerFailure(extractDioErrorMessage(e), e.response?.statusCode),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString(), null));
    }
  }

  @override
  Future<Either<Failure, CursorPaginatedResponse<PostListModel>>> getPosts({
    String? cursor,
  }) async {
    final revision = _localDataSource.revision;
    try {
      final response = await _postApi.getPosts(cursor: cursor);
      final data = response.data;
      if (data == null) return const Left(ServerFailure('응답 데이터가 없습니다.', 500));

      if (_session != _localDataSource.session ||
          revision != _localDataSource.revision) {
        return const Left(CancelTokenFailure('목록이 변경되었습니다. 다시 조회해주세요.', null));
      }
      final page = CursorPaginatedResponse.fromJson(
        json: data,
        itemParser: (e) => PostListModel.fromJson(e),
      );
      if (cursor == null) {
        _snapshotRevision = revision;
        _snapshotFetchedAt = DateTime.now().toUtc();
      }
      return Right(page);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return Left(NetworkFailure(extractDioErrorMessage(e)));
      }
      return Left(
        ServerFailure(extractDioErrorMessage(e), e.response?.statusCode),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString(), null));
    }
  }

  @override
  Future<Either<Failure, PostDetailModel>> getPostById(int postId) async {
    try {
      final response = await _postApi.getPostById(postId);
      final data = response.data;
      if (data == null) return const Left(ServerFailure('응답 데이터가 없습니다.', 500));
      return Right(PostDetailModel.fromJson(data));
    } on DioException catch (e) {
      return Left(
        ServerFailure(extractDioErrorMessage(e), e.response?.statusCode),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString(), null));
    }
  }

  @override
  Future<Either<Failure, void>> deletePost(int postId) async {
    try {
      await _postApi.deletePost(postId);
      await _updateCache(() => _localDataSource.removePost(postId));
      return const Right(null);
    } on DioException catch (e) {
      return Left(
        ServerFailure(extractDioErrorMessage(e), e.response?.statusCode),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString(), null));
    }
  }

  @override
  Future<Either<Failure, PostDetailModel>> updatePost(
    int postId,
    PostRequestModel request,
  ) async {
    try {
      final response = await _postApi.updatePost(postId, request);

      final data = response.data;

      if (data == null) {
        return const Left(ServerFailure('응답 데이터가 없습니다.', 500));
      }

      final parsed = PostResponseModel.fromJson(data);
      await _updateCache(
        () => _localDataSource.updateTitle(postId, parsed.title),
      );

      return Right(
        PostDetailModel(
          id: parsed.id,
          title: parsed.title,
          content: parsed.content,
          authorId: parsed.authorId,
          updatedAt: parsed.updatedAt,
        ),
      );
    } on DioException catch (e) {
      return Left(
        ServerFailure(extractDioErrorMessage(e), e.response?.statusCode),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString(), null));
    }
  }

  @override
  Future<Either<Failure, CursorPaginatedResponse<PostListModel>>> searchPosts({
    required String keyword,
    String? cursor,
  }) async {
    try {
      final response = await _postApi.searchPosts(
        keyword: keyword,
        cursor: cursor,
      );

      final data = response.data;

      if (data == null) {
        return const Left(ServerFailure('응답 데이터가 없습니다.', 500));
      }

      return Right(
        CursorPaginatedResponse.fromJson(
          json: data,
          itemParser: (e) => PostListModel.fromJson(e),
        ),
      );
    } on DioException catch (e) {
      return Left(
        ServerFailure(extractDioErrorMessage(e), e.response?.statusCode),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString(), null));
    }
  }

  @override
  Future<Either<Failure, List<PostListModel>>> getCachedPosts() async {
    try {
      if (_session != _localDataSource.session) return const Right([]);
      final posts = await _localDataSource.getCachedPosts();
      if (_session != _localDataSource.session) return const Right([]);
      return Right(posts);
    } catch (_) {
      return const Left(CacheFailure('저장된 게시글을 불러오지 못했습니다.'));
    }
  }

  @override
  Future<Either<Failure, void>> savePostsCache(
    List<PostListModel> freshPosts,
  ) async {
    try {
      if (_session != _localDataSource.session || _snapshotRevision == null) {
        return const Right(null);
      }
      await _localDataSource.saveSnapshot(
        freshPosts,
        expectedRevision: _snapshotRevision,
        fetchedAt: _snapshotFetchedAt,
      );
      return const Right(null);
    } catch (_) {
      return const Left(CacheFailure('게시글을 기기에 저장하지 못했습니다.'));
    }
  }

  @override
  Future<Either<Failure, void>> clearPostsCache() async {
    try {
      await _localDataSource.clear();
      return const Right(null);
    } catch (_) {
      return const Left(CacheFailure('저장된 게시글을 삭제하지 못했습니다.'));
    }
  }
}
