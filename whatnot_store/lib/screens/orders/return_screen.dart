import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/return_provider.dart';

class ReturnScreen extends StatefulWidget {
  const ReturnScreen({super.key});

  @override
  State<ReturnScreen> createState() => _ReturnScreenState();
}

class _ReturnScreenState extends State<ReturnScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<ReturnProvider>(context, listen: false)
            .fetchMyReturns(context));
  }

  @override
  Widget build(BuildContext context) {
    final rProvider = Provider.of<ReturnProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Returns", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      body: rProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : rProvider.returnsList.isEmpty
              ? const Center(child: Text("No return requests yet"))
              : ListView.builder(
                  itemCount: rProvider.returnsList.length,
                  itemBuilder: (context, index) {
                    final item = rProvider.returnsList[index];
                    final status = item["status"];

                    return Card(
                      margin: const EdgeInsets.all(12),
                      child: ListTile(
                        title: Text("Return #${index + 1}"),
                        subtitle: Text("Status: $status"),
                        trailing: Icon(
                          Icons.info_outline,
                          color: status == "Approved"
                              ? Colors.green
                              : status == "Rejected"
                                  ? Colors.red
                                  : Colors.orange,
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
