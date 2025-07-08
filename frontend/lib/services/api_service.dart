import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/aquarium.dart';
import '../models/fish.dart';
import '../models/task.dart';

class ApiService {
  static const String baseUrl =
      'https://q8w5fnjug9.execute-api.eu-central-1.amazonaws.com/prod/api';

  // Headers for all requests
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Health check endpoint for testing
  static Future<bool> healthCheck() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://q8w5fnjug9.execute-api.eu-central-1.amazonaws.com/prod/health'),
        headers: headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Health check error: $e');
      return false;
    }
  }

  // Aquarium endpoints
  static Future<List<Aquarium>> getAquariums() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/aquariums'),
        headers: headers,
      );

      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> data = responseData['data'];
          return data.map((json) => Aquarium.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching aquariums: $e');
      return [];
    }
  }

  static Future<Aquarium?> getAquarium(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/aquariums/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          return Aquarium.fromJson(responseData['data']);
        }
      }
      return null;
    } catch (e) {
      print('Error fetching aquarium: $e');
      return null;
    }
  }

  static Future<Aquarium?> createAquarium(Aquarium aquarium) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/aquariums'),
        headers: headers,
        body: json.encode(aquarium.toJson()),
      );

      print('Create aquarium response: ${response.statusCode}');
      print('Create aquarium body: ${response.body}');

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          return Aquarium.fromJson(responseData['data']);
        }
      }
      return null;
    } catch (e) {
      print('Error creating aquarium: $e');
      return null;
    }
  }

  // Fish endpoints
  static Future<List<Fish>> getFish([int? aquariumId]) async {
    try {
      String url = aquariumId != null
          ? '$baseUrl/aquariums/$aquariumId/fish'
          : '$baseUrl/fish';

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> data = responseData['data'];
          return data.map((json) => Fish.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching fish: $e');
      return [];
    }
  }

  static Future<Fish?> addFish(Fish fish) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/fish'),
        headers: headers,
        body: json.encode(fish.toJson()),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          return Fish.fromJson(responseData['data']);
        }
      }
      return null;
    } catch (e) {
      print('Error adding fish: $e');
      return null;
    }
  }

  // Task endpoints
  static Future<List<Task>> getTasks([int? aquariumId]) async {
    try {
      String url = aquariumId != null
          ? '$baseUrl/aquariums/$aquariumId/tasks'
          : '$baseUrl/tasks';

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> data = responseData['data'];
          return data.map((json) => Task.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching tasks: $e');
      return [];
    }
  }

  static Future<Task?> addTask(Task task) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/tasks'),
        headers: headers,
        body: json.encode(task.toJson()),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          return Task.fromJson(responseData['data']);
        }
      }
      return null;
    } catch (e) {
      print('Error adding task: $e');
      return null;
    }
  }

  static Future<bool> completeTask(int taskId) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/tasks/$taskId/complete'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return responseData['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error completing task: $e');
      return false;
    }
  }
}
