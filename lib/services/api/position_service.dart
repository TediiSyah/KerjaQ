import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class PositionService {
  // Helper method to get auth headers
  Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'APP-KEY': 'd11869cbb24234949e1d47e131adbd7c6fc6d6b2',
    };
    
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }

  // Helper method to handle API errors
  Map<String, dynamic> _handleError(dynamic e,
      [int attempt = 0, int maxRetries = 3]) {
    print('❌ Error: $e');
    if (e is http.ClientException) {
      return {
        'success': false,
        'message': 'Network error. Please check your connection and try again.',
      };
    } else if (attempt >= maxRetries - 1) {
      return {
        'success': false,
        'message': 'An error occurred. Please try again later.',
      };
    }
    return {};
  }

  /// Get company ID from shared preferences
  Future<String?> _getCompanyId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('company_id');
  }

  /// Create new position with the provided details
  /// This method creates a new job position with the given parameters
  Future<Map<String, dynamic>> createPosition({
    required String positionName,
    required int capacity,
    required String description,
    required String submissionStartDate,
    required String submissionEndDate,
  }) async {
    // Get company ID for HRD users
    final companyId = await _getCompanyId();
    if (companyId == null) {
      return {
        'success': false,
        'message': 'Company ID not found. Please log in again.',
      };
    }
    print('🔄 Starting to create position: $positionName for company: $companyId');

    const maxRetries = 3;
    var attempt = 0;

    while (attempt < maxRetries) {
      attempt++;
      print('🔄 Attempt $attempt of $maxRetries - Creating position...');

      http.Client? client;

      try {
        final headers = await _getAuthHeaders();
        final url = Uri.parse('${ApiService.baseUrl}/available-positions');

        final body = {
          'position_name': positionName,
          'capacity': capacity,
          'description': description,
          'submission_start_date': submissionStartDate,
          'submission_end_date': submissionEndDate,
          'company_id': companyId,  // Add company ID to the request
        };

        print('📤 Sending request to: $url');
        print('📝 Request body: $body');

        client = http.Client();
        final response = await client
            .post(
              url,
              headers: headers,
              body: json.encode(body),
            )
            .timeout(const Duration(seconds: 30));

        print('📥 Response status: ${response.statusCode}');
        print('📥 Response body: ${response.body}');

        final responseData = json.decode(response.body);

        if (response.statusCode == 200 || response.statusCode == 201) {
          return {
            'success': true,
            'message': 'Position created successfully',
            'data': responseData,
          };
        } else {
          return {
            'success': false,
            'message': responseData['message'] ?? 'Failed to create position',
          };
        }
      } on http.ClientException catch (e) {
        print('❌ Network error on attempt $attempt: $e');
        if (attempt >= maxRetries) {
          return {
            'success': false,
            'message':
                'Network error. Please check your connection and try again.',
          };
        }
      } catch (e) {
        print('❌ Error creating position on attempt $attempt: $e');
        if (attempt >= maxRetries) {
          return {
            'success': false,
            'message': 'Failed to create position: ${e.toString()}',
          };
        }
      } finally {
        client?.close();
      }

      // Wait before retrying
      if (attempt < maxRetries) {
        final delay = Duration(seconds: 2 * attempt);
        print('⏳ Retrying in ${delay.inSeconds} seconds...');
        await Future.delayed(delay);
      }
    }

    return {
      'success': false,
      'message': 'Failed to create position after $maxRetries attempts',
    };
  }

  /// Fetch all active available positions
  /// This endpoint returns only positions that are currently active
  Future<List<dynamic>> fetchAvailablePositions() async {
    print('🔍 Starting to fetch ACTIVE available positions...');

    try {
      final headers = await _getAuthHeaders();

      // Use the active positions endpoint
      final endpoint = '/available-positions/active';
      final url = Uri.parse('${ApiService.baseUrl}$endpoint');
      print('🌐 Fetching from URL: $url');

      final response = await http.get(url, headers: headers);
      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('📊 Raw API Response: $responseData');

        // Handle different response formats
        if (responseData is List) {
          print('✅ Found ${responseData.length} active positions in List format');
          return responseData;
        } else if (responseData is Map && responseData['data'] is List) {
          final positions = responseData['data'] as List;
          print('✅ Found ${positions.length} active positions in Map with data List format');
          return positions;
        } else if (responseData is Map &&
            responseData['data'] is Map &&
            responseData['data']['data'] is List) {
          final positions = responseData['data']['data'] as List;
          print('✅ Found ${positions.length} active positions in nested data format');
          return positions;
        } else if (responseData is Map && responseData['success'] == true) {
          // Handle case where the API returns {success: true, data: [...]}
          if (responseData['data'] is List) {
            final positions = responseData['data'] as List;
            print('✅ Found ${positions.length} active positions in success response');
            return positions;
          }
        }

        print('⚠️ Unexpected response format: $responseData');
        return [];
      } else if (response.statusCode == 401) {
        print('🔑 Authentication failed (401) - Token might be invalid or expired');
        // Re-throw the 401 error to be handled by the caller
        throw Exception('401');
      } else {
        print('❌ Failed to fetch positions: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('❌ Error in fetchAvailablePositions: $e');
      // Re-throw the exception to be handled by the caller
      rethrow;
    }
  }

  /// Fetch positions for specific company (my company)
  Future<List<dynamic>> fetchMyCompanyPositions() async {
    try {
      final headers = await _getAuthHeaders();
      // Use the companies/me endpoint that was found to be working
      final url = Uri.parse('${ApiService.baseUrl}/companies/me');

      print('🌐 Fetching company positions from: $url');
      final response = await http.get(url, headers: headers);

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData is List) {
          return responseData;
        } else if (responseData is Map && responseData['data'] is List) {
          return responseData['data'];
        }
      }

      print('❌ Failed to fetch company positions: ${response.body}');
      return [];
    } catch (e) {
      print('❌ Error in fetchMyCompanyPositions: $e');
      return [];
    }
  }

  /// Fetch applicants for specific company
  Future<List<dynamic>> fetchMyCompanyApplicants() async {
    try {
      final headers = await _getAuthHeaders();
      final url = Uri.parse('${ApiService.baseUrl}/api/company/applications');

      print('🌐 Fetching company applicants from: $url');
      final response = await http.get(url, headers: headers);

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData is List) {
          return responseData;
        } else if (responseData is Map && responseData['data'] is List) {
          return responseData['data'];
        }
      }

      print('❌ Failed to fetch applicants: ${response.body}');
      return [];
    } catch (e) {
      print('❌ Error in fetchMyCompanyApplicants: $e');
      return [];
    }
  }

  /// Get position by ID
  Future<Map<String, dynamic>> getPositionById(String positionId) async {
    try {
      final headers = await _getAuthHeaders();
      final url =
          Uri.parse('${ApiService.baseUrl}/available-positions$positionId');

      print('🌐 Fetching position with ID: $positionId');
      final response = await http.get(url, headers: headers);

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return {
          'success': true,
          'data': responseData,
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to fetch position',
        };
      }
    } catch (e) {
      print('❌ Error in getPositionById: $e');
      return {
        'success': false,
        'message': 'An error occurred while fetching position',
      };
    }
  }

  /// Close a position
  Future<Map<String, dynamic>> closePosition(String positionId) async {
    try {
      final headers = await _getAuthHeaders();
      final url = Uri.parse(
          '${ApiService.baseUrl}/available-positions/$positionId/close');

      print('🛑 Closing position with ID: $positionId');
      final response = await http.post(
        url,
        headers: headers,
      );

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Position closed successfully',
          'data': responseData['data'] ?? {},
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to close position',
        };
      }
    } catch (e) {
      print('❌ Error in closePosition: $e');
      return _handleError(e);
    }
  }

  /// Update existing position
  Future<Map<String, dynamic>> editPosition({
    required String positionId,
    required String positionName,
    required int capacity,
    required String description,
    required String submissionStartDate,
    required String submissionEndDate,
  }) async {
    print('🔄 Starting editPosition with ID: $positionId');

    const maxRetries = 3;
    var attempt = 0;

    while (attempt < maxRetries) {
      attempt++;
      print('🔄 Attempt $attempt of $maxRetries - Updating position...');

      http.Client? client;

      try {
        final headers = await _getAuthHeaders();
        final url =
            Uri.parse('${ApiService.baseUrl}/available-positions/$positionId');

        final body = {
          'position_name': positionName,
          'capacity': capacity,
          'description': description,
          'submission_start_date': submissionStartDate,
          'submission_end_date': submissionEndDate,
        };

        print('📤 Sending request to: $url');
        print('📝 Request body: $body');

        client = http.Client();
        final response = await client
            .put(
              url,
              headers: headers,
              body: json.encode(body),
            )
            .timeout(const Duration(seconds: 30));

        print('📥 Response status: ${response.statusCode}');
        print('📥 Response body: ${response.body}');

        final responseData = json.decode(response.body);

        if (response.statusCode == 200 || response.statusCode == 201) {
          return {
            'success': true,
            'message': 'Position updated successfully',
            'data': responseData,
          };
        } else {
          return {
            'success': false,
            'message': responseData['message'] ?? 'Failed to update position',
          };
        }
      } on http.ClientException catch (e) {
        print('❌ Network error on attempt $attempt: $e');
        if (attempt >= maxRetries) {
          return {
            'success': false,
            'message':
                'Network error. Please check your connection and try again.',
          };
        }
      } catch (e) {
        print('❌ Error updating position on attempt $attempt: $e');
        if (attempt >= maxRetries) {
          return {
            'success': false,
            'message': 'Failed to update position: ${e.toString()}',
          };
        }
      } finally {
        client?.close();
      }

      // Wait before retrying
      if (attempt < maxRetries) {
        final delay = Duration(seconds: 2 * attempt);
        print('⏳ Retrying in ${delay.inSeconds} seconds...');
        await Future.delayed(delay);
      }
    }

    return {
      'success': false,
      'message': 'Failed to update position after $maxRetries attempts',
    };
  }
}
