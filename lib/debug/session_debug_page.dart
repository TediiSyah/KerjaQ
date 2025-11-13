import 'package:flutter/material.dart';
import 'package:ukk_tedii/utils/session_manager.dart';

class SessionDebugPage extends StatefulWidget {
  const SessionDebugPage({super.key});

  @override
  State<SessionDebugPage> createState() => _SessionDebugPageState();
}

class _SessionDebugPageState extends State<SessionDebugPage> {
  Map<String, String?> sessionData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSessionData();
  }

  Future<void> _loadSessionData() async {
    setState(() => isLoading = true);

    final userData = await SessionManager.getUserData();
    final companyData = await SessionManager.getCompanyData();

    setState(() {
      sessionData = {
        ...userData,
        ...companyData,
      };
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Session Debug'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSessionData,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Session Data',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(height: 24),
                        ...sessionData.entries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.key,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: entry.value != null
                                        ? Colors.green[50]
                                        : Colors.red[50],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: entry.value != null
                                          ? Colors.green[200]!
                                          : Colors.red[200]!,
                                    ),
                                  ),
                                  child: Text(
                                    entry.value ?? 'null (tidak ada data)',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: entry.value != null
                                          ? Colors.black87
                                          : Colors.red[700],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () async {
                    await SessionManager.clearSession();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Session cleared!'),
                      ),
                    );
                    _loadSessionData();
                  },
                  icon: const Icon(Icons.delete),
                  label: const Text('Clear Session'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ],
            ),
    );
  }
}
