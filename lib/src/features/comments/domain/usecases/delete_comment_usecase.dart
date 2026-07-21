import 'package:fpdart/fpdart.dart';
import 'package:loop/src/core/network/error/failures.dart';
import 'package:loop/src/features/comments/domain/repositories/abstract_comment_repository.dart';

class DeleteCommentUseCase {
  final AbstractCommentRepository _repository;

  DeleteCommentUseCase(this._repository);

  Future<Either<Failure, void>> call({
    required int postId,
    required int commentId,
  }) {
    return _repository.deleteComment(postId: postId, commentId: commentId);
  }
}
