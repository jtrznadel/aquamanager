import 'dart:convert';

import 'package:aquamanager_frontend/models/aquarium.dart';
import 'package:aquamanager_frontend/models/fish.dart';
import 'package:aquamanager_frontend/models/task.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';

  // Aquarium endpoints
  static Future<List<Aquarium>> getAquariums() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/aquariums'));
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

  static Future<Aquarium?> createAquarium(Aquarium aquarium) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/aquariums'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(aquarium.toJson()),
      );
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
  static Future<List<Fish>> getFish(int aquariumId) async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/aquariums/$aquariumId/fish'));
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
        headers: {'Content-Type': 'application/json'},
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
  static Future<List<Task>> getTasks(int aquariumId) async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/aquariums/$aquariumId/tasks'));
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
        headers: {'Content-Type': 'application/json'},
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
