import 'package:agenda/core/network/api_exception.dart';
import 'package:agenda/core/network/dio_error_mapper.dart';
import 'package:dio/dio.dart';

import '../domain/repositories/therapists_repository.dart';
import 'models/therapist_model.dart';
import 'therapists_remote_datasource.dart';

class TherapistsRepositoryImpl implements TherapistsRepository {
  TherapistsRepositoryImpl(this._remote);

  final TherapistsRemoteDataSource _remote;

  @override
  Future<List<TherapistModel>> fetchTherapists({String? query}) async {
    try {
      return await _remote.fetchTherapists(query: query);
    } on DioException catch (e) {
      throw ApiException(dioExceptionToMessage(e));
    } catch (e) {
      throw ApiException('Error al obtener terapeutas: $e');
    }
  }

  @override
  Future<TherapistModel> createTherapist({
    required String name,
    String? email,
    String? phoneNumber,
  }) async {
    try {
      return await _remote.createTherapist(
        name: name,
        email: email,
        phoneNumber: phoneNumber,
      );
    } on DioException catch (e) {
      throw ApiException(dioExceptionToMessage(e));
    } catch (e) {
      throw ApiException('Error al crear terapeuta: $e');
    }
  }

  @override
  Future<TherapistModel> updateTherapist(
    String id, {
    String? name,
    String? email,
    String? phoneNumber,
  }) async {
    try {
      return await _remote.updateTherapist(
        int.parse(id),
        name: name,
        email: email,
        phoneNumber: phoneNumber,
      );
    } on DioException catch (e) {
      throw ApiException(dioExceptionToMessage(e));
    } catch (e) {
      throw ApiException('Error al actualizar terapeuta: $e');
    }
  }

  @override
  Future<void> deleteTherapist(String id) async {
    try {
      await _remote.deleteTherapist(int.parse(id));
    } on DioException catch (e) {
      throw ApiException(dioExceptionToMessage(e));
    } catch (e) {
      throw ApiException('Error al eliminar terapeuta: $e');
    }
  }
}
