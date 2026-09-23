import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vetra/core/network/network_exceptions.dart';
import 'package:vetra/features/ai/data/models/ai_scan_model.dart';

DioException _dioError({int? status, DioExceptionType type = DioExceptionType.badResponse}) {
  final options = RequestOptions(path: '/api/v1/disease/reports');
  return DioException(
    requestOptions: options,
    type: type,
    response: status == null
        ? null
        : Response(requestOptions: options, statusCode: status, data: {'message': 'rejected'}),
  );
}

void main() {
  group('isServerRejection: answered-and-refused vs never-answered', () {
    test('4xx and 5xx answers are rejections (show to user, do not queue)', () {
      for (final status in [400, 401, 403, 404, 409, 422, 500, 503]) {
        expect(isServerRejection(NetworkException.fromDioError(_dioError(status: status))), isTrue,
            reason: 'HTTP $status');
        expect(isServerRejection(_dioError(status: status)), isTrue, reason: 'raw DioException $status');
      }
    });

    test('no connection or timeout is not a rejection (safe to queue)', () {
      for (final type in [
        DioExceptionType.connectionError,
        DioExceptionType.connectionTimeout,
        DioExceptionType.receiveTimeout,
        DioExceptionType.sendTimeout,
      ]) {
        expect(isServerRejection(NetworkException.fromDioError(_dioError(type: type))), isFalse,
            reason: '$type');
      }
      expect(isServerRejection(Exception('socket closed')), isFalse);
    });
  });

  group('AIScanModel.isAnalysisFailure', () {
    Map<String, dynamic> scan({String status = 'COMPLETED', String? diagnosis, double? confidence}) => {
          'id': 'e1415e0d-daaa-4d37-9b2a-e010e4fd4e0c',
          'animalId': 'a1b2c3d4-0000-4000-8000-0000000000a1',
          'imageUrl': 'data:image/jpeg;base64,xyz',
          'aiProvider': 'GEMINI',
          'aiModel': 'gemini-3.5-flash',
          'diagnosis': diagnosis,
          'confidenceScore': confidence,
          'status': status,
        };

    test('backend inference failure (status FAILED, no diagnosis) is a failure', () {
      expect(AIScanModel.fromJson(scan(status: 'FAILED')).isAnalysisFailure, isTrue);
    });

    test('AI never ran (status PENDING, no diagnosis) is a failure', () {
      expect(AIScanModel.fromJson(scan(status: 'PENDING')).isAnalysisFailure, isTrue);
    });

    test('a real diagnosis is a result', () {
      final model = AIScanModel.fromJson(
          scan(status: 'COMPLETED', diagnosis: 'Lumpy Skin Disease', confidence: 0.82));
      expect(model.isAnalysisFailure, isFalse);
    });

    test('a scan saved offline is pending upload, not a failure', () {
      final model = AIScanModel(
        id: 'local',
        animalId: 'a',
        imageUrl: '/tmp/x.jpg',
        status: 'PENDING_UPLOAD',
      );
      expect(model.isAnalysisFailure, isFalse);
    });
  });
}
