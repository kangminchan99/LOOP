import 'package:fpdart/fpdart.dart';
import 'package:loop/src/core/network/error/failures.dart';
import 'package:loop/src/features/comments/domain/models/comment_model.dart';
import 'package:loop/src/features/comments/domain/models/comment_request_model.dart';
import 'package:loop/src/features/comments/domain/repositories/abstract_comment_repository.dart';

class CreateCommentUseCase {
  final AbstractCommentRepository _repository;

  CreateCommentUseCase(this._repository);

  Future<Either<Failure, CommentModel>> call({
    required int postId,
    required String content,
  }) {
    final trimmed = content.trim();

    if (trimmed.isEmpty) {
      return Future.value(const Left(ServerFailure('댓글 내용을 입력해주세요.', null)));
    }

    return _repository.createComment(
      postId: postId,
      request: CommentRequestModel(content: trimmed),
    );
  }
}
