import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:ukk_tedii/models/application_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;

// Helper function for logging
void logDebug(String message) {
  print('[DEBUG] $message');
}

class ApplicationService {
  final String baseUrl = 'https://learn.smktelkom-mlg.sch.id/jobsheeker';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Apply for a position with optional documents
  Future<Map<String, dynamic>> applyForPosition(
    String positionId, {
    String? coverLetter,
    File? resumeFile,
    File? portfolioFile,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      // Create multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/position-applied'),
      );

      // Add headers
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'APP-KEY': 'd11869cbb24234949e1d47e131adbd7c6fc6d6b2',
      });

      // Log the position ID for debugging
      logDebug('Position ID: $positionId (type: ${positionId.runtimeType})');

      // Create a JSON body with the position ID
      final jsonBody = <String, dynamic>{
        'available_position_id': positionId.trim(),
      };

      // Add cover letter if provided
      if (coverLetter != null && coverLetter.isNotEmpty) {
        jsonBody['cover_letter'] = coverLetter;
      }

      // Convert the JSON body to a string and add it as a form field
      request.fields['data'] = jsonEncode(jsonBody);

      logDebug('Request body: ${jsonEncode(jsonBody)}');

      // Add resume file if provided
      if (resumeFile != null) {
        final mimeType = lookupMimeType(resumeFile.path);
        request.files.add(await http.MultipartFile.fromPath(
          'resume',
          resumeFile.path,
          contentType: mimeType != null ? MediaType.parse(mimeType) : null,
        ));
      }

      // Add portfolio file if provided
      if (portfolioFile != null) {
        final mimeType = lookupMimeType(portfolioFile.path);
        request.files.add(await http.MultipartFile.fromPath(
          'portfolio',
          portfolioFile.path,
          contentType: mimeType != null ? MediaType.parse(mimeType) : null,
        ));
      }

      logDebug('Sending application request to: ${request.url}');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      logDebug('Application response status: ${response.statusCode}');
      logDebug('Response body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'success': true,
          'message': 'Successfully applied for the position',
          'data': jsonDecode(response.body),
        };
      } else {
        try {
          final errorResponse = jsonDecode(response.body);
          return {
            'success': false,
            'message':
                errorResponse['message'] ?? 'Failed to apply for position',
            'statusCode': response.statusCode,
            'response': errorResponse,
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Failed to process server response',
            'statusCode': response.statusCode,
            'response': response.body,
          };
        }
      }
    } catch (e) {
      logDebug('Error applying for position: $e');
      return {
        'success': false,
        'message':
            'An error occurred while applying for the position: ${e.toString()}',
        'error': e.toString(),
      };
    }
  }

  // Get all applications for the current company (HRD view)
  // 🔹 Ambil detail society berdasarkan ID
  Future<Map<String, dynamic>?> _fetchSocietyById(String societyId) async {
    try {
      final token = await _getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/societies/$societyId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'APP-KEY': 'd11869cbb24234949e1d47e131adbd7c6fc6d6b2',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? data; // kadang data langsung ada di root
      }
    } catch (e) {
      print('⚠️ Gagal ambil data society $societyId: $e');
    }
    return null;
  }

  Future<List<Application>> getCompanyApplications() async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No authentication token found');

      final response = await http.get(
        Uri.parse('$baseUrl/position-applied?page=1&quantity=100'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'APP-KEY': 'd11869cbb24234949e1d47e131adbd7c6fc6d6b2',
        },
      );

      print('📡 API Response - Status: ${response.statusCode}');
      print('📡 API Response - Body: ${response.body}');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List data = body['data'] ?? [];

        List<Application> applications = [];

        for (var item in data) {
          var app = Application.fromJson(item);

          // Jika nama pelamar kosong, ambil dari /societies/{id}
          if ((app.applicantName.isEmpty || app.applicantName == 'Anonymous') &&
              app.applicantId.isNotEmpty) {
            try {
              final societyData = await _fetchSocietyById(app.applicantId);
              if (societyData != null && societyData['name'] != null) {
                // Update application with society name
                app = app.copyWith(
                  applicantName: societyData['name'].toString(),
                  applicantAddress: societyData['address']?.toString() ??
                      app.applicantAddress,
                  applicantPhone:
                      societyData['phone']?.toString() ?? app.applicantPhone,
                  applicantGender:
                      societyData['gender']?.toString() ?? app.applicantGender,
                );
                print('✅ Updated applicant data for ${societyData['name']}');
              }
            } catch (e) {
              print('⚠️ Error updating society data: $e');
            }
          }

          applications.add(app);
        }

        return applications;
      } else {
        throw Exception('Failed to load company applications');
      }
    } catch (e) {
      print('❌ Error in getCompanyApplications: $e');
      throw Exception('Error loading company applications: $e');
    }
  }

  // Get all applications for the current user (applicant view)
  Future<List<Application>> getUserApplications() async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/user/applications'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'APP-KEY': 'd11869cbb24234949e1d47e131adbd7c6fc6d6b2',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body)['data'];
        return data.map((json) => Application.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load user applications');
      }
    } catch (e) {
      throw Exception('Error loading user applications: $e');
    }
  }

  Future<void> updateApplicationStatus(
      String applicationId, String status) async {
    try {
      final token = await _getToken();
      final response = await http.put(
        Uri.parse('$baseUrl/applications/$applicationId/status'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'status': status}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update application status');
      }
    } catch (e) {
      throw Exception('Error updating application status: $e');
    }
  }

  // Get application details by ID
  Future<Application> getApplicationById(String applicationId) async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/applications/$applicationId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return Application.fromJson(jsonDecode(response.body)['data']);
      } else {
        throw Exception('Failed to load application details');
      }
    } catch (e) {
      throw Exception('Error loading application details: $e');
    }
  }

  // Submit a new job application with file upload
  Future<Map<String, dynamic>> submitApplication({
    required String jobId,
    required String jobTitle,
    required String coverLetter,
    required File resumeFile,
    String? portfolioFile,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Authentication required. Please log in again.',
        };
      }

      // Create multipart request for submitting application documents
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/application-documents'),
      );

      // Add headers
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'APP-KEY': 'd11869cbb24234949e1d47e131adbd7c6fc6d6b2',
      });

      try {
        // Add form fields
        request.fields['job_id'] = jobId;
        request.fields['job_title'] = jobTitle;
        request.fields['cover_letter'] = coverLetter;

        // Add resume file with size logging
        final mimeType = lookupMimeType(resumeFile.path);
        final fileExtension = path.extension(resumeFile.path).toLowerCase();
        final fileSize = await resumeFile.length();

        logDebug('Uploading resume file:');
        logDebug('- Path: ${resumeFile.path}');
        logDebug(
            '- Size: $fileSize bytes (${(fileSize / 1024).toStringAsFixed(1)} KB)');
        logDebug('- MIME Type: $mimeType');

        request.files.add(await http.MultipartFile.fromPath(
          'resume',
          resumeFile.path,
          contentType: MediaType.parse(mimeType ?? 'application/octet-stream'),
          filename:
              'resume_${DateTime.now().millisecondsSinceEpoch}$fileExtension',
        ));

        // Add portfolio file if provided with size logging
        if (portfolioFile != null && File(portfolioFile).existsSync()) {
          final portfolioMimeType = lookupMimeType(portfolioFile);
          final portfolioExtension =
              path.extension(portfolioFile).toLowerCase();
          final portfolioFileInstance = File(portfolioFile);
          final portfolioFileSize = await portfolioFileInstance.length();

          logDebug('Uploading portfolio file:');
          logDebug('- Path: $portfolioFile');
          logDebug(
              '- Size: $portfolioFileSize bytes (${(portfolioFileSize / 1024).toStringAsFixed(1)} KB)');
          logDebug('- MIME Type: $portfolioMimeType');

          request.files.add(await http.MultipartFile.fromPath(
            'portfolio',
            portfolioFile,
            contentType: MediaType.parse(
                portfolioMimeType ?? 'application/octet-stream'),
            filename:
                'portfolio_${DateTime.now().millisecondsSinceEpoch}$portfolioExtension',
          ));
        }

        // Log request details before sending
        logDebug('Sending request to: ${request.url}');
        logDebug('Headers: ${request.headers}');
        logDebug('Files count: ${request.files.length}');

        // Send the request with timeout
        final streamedResponse = await request.send().timeout(
          const Duration(seconds: 60),
          onTimeout: () {
            throw TimeoutException('Request timed out after 60 seconds');
          },
        );

        final response = await http.Response.fromStream(streamedResponse);

        // Log response details
        logDebug('Response status: ${response.statusCode}');
        logDebug('Response headers: ${response.headers}');
        logDebug('Response body: ${response.body}');
        logDebug('Response request: ${response.request}');

        // Check if response is HTML (error page)
        if (response.headers['content-type']?.contains('text/html') == true) {
          return {
            'success': false,
            'message':
                'Server returned an HTML error page. Please try again later.',
            'statusCode': response.statusCode,
          };
        }

        // Try to parse the response as JSON
        try {
          final responseData = jsonDecode(response.body);

          if (response.statusCode == 201) {
            return {
              'success': true,
              'data': responseData['data'],
              'statusCode': response.statusCode,
            };
          } else {
            return {
              'success': false,
              'message':
                  responseData['message'] ?? 'Failed to submit application',
              'statusCode': response.statusCode,
            };
          }
        } catch (e) {
          // If JSON parsing fails, return the raw response
          return {
            'success': false,
            'message':
                'Invalid server response format. Status: ${response.statusCode}',
            'response': response.body,
            'statusCode': response.statusCode,
          };
        }
      } on http.ClientException catch (e) {
        return {
          'success': false,
          'message': 'Network error: ${e.message}',
        };
      } on FormatException catch (e) {
        return {
          'success': false,
          'message': 'Error parsing server response',
          'error': e.toString(),
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred',
        'error': e.toString(),
      };
    }
  }
}
