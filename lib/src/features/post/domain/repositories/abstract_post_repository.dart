import 'package:fpdart/fpdart.dart';
import 'package:loop/src/core/network/error/failures.dart';
import 'package:loop/src/features/post/domain/models/create_post_request_model.dart';
import 'package:loop/src/features/post/domain/models/post_detail_model.dart';

abstract class AbstractPostRepository {
  Future<Either<Failure, PostDetailModel>> createPost(
    CreatePostRequestModel request,
  );
}
