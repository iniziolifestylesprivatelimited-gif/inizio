import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_template.dart';
import 'terms_screen.dart';


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final gstController = TextEditingController();
  File? gstFile;
  String? gstFileExtension;

  bool agreeToTerms = false; // ✅ New field

  // ✅ Select Document
  void pickGSTDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png', 'jpeg'],
    );

    if (result != null) {
      setState(() {
        gstFile = File(result.files.single.path!);
        gstFileExtension = result.files.single.extension?.toLowerCase();
      });
    }
  }

  // ✅ Register
  void register() async {
    if (!_formKey.currentState!.validate() || gstFile == null) {
      await showOkAlertDialog(
        context: context,
        title: 'Missing Information',
        message: 'Please fill all fields and upload your GST document.',
      );
      return;
    }

    if (!agreeToTerms) {
      await showOkAlertDialog(
        context: context,
        title: 'Terms & Conditions',
        message: 'You must agree to the Terms & Conditions to continue.',
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final response = await authProvider.register(
      nameController.text.trim(),
      emailController.text.trim(),
      gstController.text.trim(),
      gstFile!,
    );

    final message = response['message'] ?? 'Something went wrong';

    await showOkAlertDialog(
      context: context,
      title: 'Registration Status',
      message: message,
    );

    if (message.toLowerCase().contains('awaiting admin approval')) {
      Navigator.pop(context);
    }
  }

  Widget _buildGSTPreview() {
    if (gstFile == null) {
      return Container(
        height: 140,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black12),
        ),
        child: const Center(
          child: Text("No Document Selected", style: TextStyle(color: Colors.black54)),
        ),
      );
    }

    // ✅ If PDF → Show Icon
    if (gstFileExtension == "pdf") {
      return Container(
        height: 140,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black26),
        ),
        child: Row(
          children: [
            const Icon(Icons.picture_as_pdf, size: 50, color: Colors.red),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                gstFile!.path.split('/').last,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      );
    }

    // ✅ If Image → Show Thumbnail
    return Container(
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black26),
        image: DecorationImage(
          image: FileImage(gstFile!),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = Provider.of<AuthProvider>(context).isLoading;

    return AppTemplate(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            const Text(
              "Create Account",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 30),

            // Name
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Name",
                border: UnderlineInputBorder(),
              ),
              validator: (v) => v!.isEmpty ? "Enter Name" : null,
            ),
            const SizedBox(height: 20),

            // Email
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                border: UnderlineInputBorder(),
              ),
              validator: (v) => v!.isEmpty ? "Enter Email" : null,
            ),
            const SizedBox(height: 20),

            // GST Number
            TextFormField(
              controller: gstController,
              decoration: const InputDecoration(
                labelText: "GST Number",
                border: UnderlineInputBorder(),
              ),
              validator: (v) => v!.isEmpty ? "Enter GST Number" : null,
            ),
            const SizedBox(height: 25),

            const Text("GST Document", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),

            _buildGSTPreview(),
            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: pickGSTDocument,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Colors.black87),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.upload, color: Colors.black),
                label: const Text("Upload Document", style: TextStyle(color: Colors.black)),
              ),
            ),

            const SizedBox(height: 30),

            // ✅ Terms and Conditions Checkbox
            Row(
              children: [
                Checkbox(
                  value: agreeToTerms,
                  onChanged: (v) => setState(() => agreeToTerms = v ?? false),
                  activeColor: Colors.black,
                ),
                Flexible(
                  child: Wrap(
                    children: [
                      const Text("I agree to the "),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const TermsScreen()),
                          );
                        },
                        child: const Text(
                          "Terms & Conditions",
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ✅ Register Button
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: register,
                      child: const Text("Register", style: TextStyle(color: Colors.white)),
                    ),
                  ),

            const SizedBox(height: 10),

            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Back to Login", style: TextStyle(color: Colors.black)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
