import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../models/todo_item.dart';

class TodosService {
  final ApiClient apiClient;

  TodosService({required this.apiClient});

  Future<List<TodoItem>> listTodos() async {
    try {
      final response = await apiClient.dio.get('/api/todos');
      final list = response.data as List<dynamic>? ?? [];
      return list
          .map((e) => TodoItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      final message = e.response?.data?['error'] ?? 'Failed to load quests';
      throw Exception(message);
    }
  }

  Future<TodoItem> createTodo(String title, {String priority = 'medium'}) async {
    try {
      final response = await apiClient.dio.post(
        '/api/todos',
        data: {
          'title': title,
          'priority': priority,
        },
      );
      return TodoItem.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final message = e.response?.data?['error'] ?? 'Failed to create quest';
      throw Exception(message);
    }
  }

  Future<TodoItem> updateTodo(
    String id, {
    String? title,
    String? status,
    String? priority,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (title != null) data['title'] = title;
      if (status != null) data['status'] = status;
      if (priority != null) data['priority'] = priority;

      final response = await apiClient.dio.patch('/api/todos/$id', data: data);
      return TodoItem.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final message = e.response?.data?['error'] ?? 'Failed to update quest';
      throw Exception(message);
    }
  }

  Future<void> deleteTodo(String id) async {
    try {
      await apiClient.dio.delete('/api/todos/$id');
    } on DioException catch (e) {
      final message = e.response?.data?['error'] ?? 'Failed to delete quest';
      throw Exception(message);
    }
  }
}
