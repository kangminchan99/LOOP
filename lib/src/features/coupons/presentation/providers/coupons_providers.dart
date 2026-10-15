import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loop/src/core/providers/init_provider.dart';
import 'package:loop/src/features/auth/presentation/providers/auth_providers.dart'
    show loginProvider;
import 'package:loop/src/features/auth/presentation/providers/login/login_state.dart';
import 'package:loop/src/features/coupons/data/data_sources/remote/coupons_api.dart';
import 'package:loop/src/features/coupons/data/repositories/coupons_repository_impl.dart';
import 'package:loop/src/features/coupons/domain/repositories/abstract_coupons_repository.dart';
import 'package:loop/src/features/coupons/domain/usecases/get_coupon_event_usecase.dart';
import 'package:loop/src/features/coupons/domain/usecases/get_coupon_events_usecase.dart';
import 'package:loop/src/features/coupons/domain/usecases/get_my_coupon_usecase.dart';
import 'package:loop/src/features/coupons/domain/usecases/get_my_coupons_usecase.dart';
import 'package:loop/src/features/coupons/domain/usecases/issue_coupon_usecase.dart';
import 'package:loop/src/features/coupons/presentation/providers/coupon_event_detail_notifier.dart';
import 'package:loop/src/features/coupons/presentation/providers/coupon_event_detail_state.dart';
import 'package:loop/src/features/coupons/presentation/providers/coupon_event_list_notifier.dart';
import 'package:loop/src/features/coupons/presentation/providers/coupon_event_list_state.dart';

// 인증 인터셉터가 설정된 공용 Dio로 API 객체 생성
final couponsApiProvider = Provider<CouponsApi>((ref) {
  final dio = ref.watch(dioProvider);
  return CouponsApi(dio);
});

// 외부에는 추상 Repository 타입으로 제공
final couponsRepositoryProvider = Provider<AbstractCouponsRepository>((ref) {
  final api = ref.watch(couponsApiProvider);
  return CouponsRepositoryImpl(api);
});

final getCouponEventsUseCaseProvider = Provider<GetCouponEventsUseCase>((ref) {
  final repository = ref.watch(couponsRepositoryProvider);
  return GetCouponEventsUseCase(repository);
});

final getCouponEventUseCaseProvider = Provider<GetCouponEventUseCase>((ref) {
  final repository = ref.watch(couponsRepositoryProvider);
  return GetCouponEventUseCase(repository);
});

final getMyCouponUseCaseProvider = Provider<GetMyCouponUseCase>((ref) {
  final repository = ref.watch(couponsRepositoryProvider);
  return GetMyCouponUseCase(repository);
});

final issueCouponUseCaseProvider = Provider<IssueCouponUseCase>((ref) {
  final repository = ref.watch(couponsRepositoryProvider);
  return IssueCouponUseCase(repository);
});

final getMyCouponsUseCaseProvider = Provider<GetMyCouponsUseCase>((ref) {
  final repository = ref.watch(couponsRepositoryProvider);
  return GetMyCouponsUseCase(repository);
});

final couponEventListProvider =
    StateNotifierProvider.autoDispose<
      CouponEventListNotifier,
      CouponEventListState
    >((ref) {
      // 사용자 ID만 구독한다.
      // 닉네임·포인트 변경으로 목록이 다시 생성되는 것을 피한다.
      final userId = ref.watch(
        loginProvider.select(
          (state) => state is LoginSuccess ? state.user.id : null,
        ),
      );

      final notifier = CouponEventListNotifier(
        getCouponEventsUseCase: ref.watch(getCouponEventsUseCaseProvider),
      );

      // 로그인 상태일 때만 첫 페이지 조회를 시작한다.
      if (userId != null) {
        unawaited(notifier.load());
      }

      return notifier;
    });

final couponEventDetailProvider = StateNotifierProvider.autoDispose
    .family<CouponEventDetailNotifier, CouponEventDetailState, int>((
      ref,
      eventId,
    ) {
      // 이 Notifier가 생성될 당시 로그인한 사용자
      final loginState = ref.read(loginProvider);
      final userId = loginState is LoginSuccess ? loginState.user.id : null;

      var sessionValid = true;

      // 종료된 Provider의 ref를 뒤늦게 사용하지 않도록 한다.
      ref.onDispose(() {
        sessionValid = false;
      });

      // 로그아웃·계정 변경을 감지하면 기존 작업을 무효화하고 재생성한다.
      ref.listen<LoginState>(loginProvider, (previous, next) {
        final nextUserId = next is LoginSuccess ? next.user.id : null;

        if (nextUserId != userId) {
          sessionValid = false;
          ref.invalidateSelf();
        }
      });

      bool isSessionCurrent() {
        if (!sessionValid || userId == null) return false;

        final current = ref.read(loginProvider);
        return current is LoginSuccess && current.user.id == userId;
      }

      final notifier = CouponEventDetailNotifier(
        eventId: eventId,
        getCouponEventUseCase: ref.watch(getCouponEventUseCaseProvider),
        getMyCouponUseCase: ref.watch(getMyCouponUseCaseProvider),
        issueCouponUseCase: ref.watch(issueCouponUseCaseProvider),
        isSessionCurrent: isSessionCurrent,
      );

      // 로그인한 경우 상세 정보와 본인 쿠폰 조회를 시작한다.
      if (isSessionCurrent()) {
        unawaited(notifier.load());
      }

      return notifier;
    });
