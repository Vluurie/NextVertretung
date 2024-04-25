import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:next_cloud_plans/ui/pages/child_ui/custom_button.dart';
import 'package:path_provider/path_provider.dart' as path;
import 'package:flutter_pdfview/flutter_pdfview.dart';

// PDF View Page
class PDFViewPage extends StatelessWidget {
  const PDFViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: PDFViewerComponent(),
    );
  }
}

// PDF Viewer Component
class PDFViewerComponent extends StatefulWidget {
  const PDFViewerComponent({super.key});

  @override
  PDFViewerComponentState createState() => PDFViewerComponentState();
}

class PDFViewerComponentState extends State<PDFViewerComponent> {
  String? localPath;

  @override
  void initState() {
    super.initState();
    loadLocalPDF();
  }

  Future<void> loadLocalPDF() async {
    final directory = await path.getApplicationDocumentsDirectory();
    final file = File('${directory.path}/saved_pdf.pdf');
    if (await file.exists()) {
      setState(() {
        localPath = file.path;
      });
    }
  }

  Future<void> pickAndSavePDF() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result != null) {
        File file = File(result.files.single.path!);
        final directory = await path.getApplicationDocumentsDirectory();
        final newFile = await file.copy('${directory.path}/saved_pdf.pdf');
        setState(() {
          localPath = newFile.path;
        });
      }
    } catch (e) {
      debugPrint("Failed to pick and save file: $e");
    }
  }

  Future<void> deletePDF() async {
    if (localPath != null) {
      final file = File(localPath!);
      await file.delete();
      setState(() {
        localPath = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Stundenplan"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: localPath != null ? deletePDF : null,
          ),
        ],
      ),
      body: localPath == null
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: CustomElevatedButton(
                  label: 'PDF Stundenplan auswählen und speichern',
                  onPressed: pickAndSavePDF,
                ),
              ),
            )
          : PDFView(
              filePath: localPath,
              enableSwipe: true,
              swipeHorizontal: false,
              autoSpacing: true,
              pageFling: true,
              pageSnap: true,
              defaultPage: 0,
              fitPolicy: FitPolicy.BOTH,
              preventLinkNavigation: false,
              onRender: (pages) {
                setState(() {});
              },
              onError: (error) {
                debugPrint("Error rendering PDF: $error");
              },
              onPageError: (page, error) {
                debugPrint("Error on page $page: $error");
              },
              onViewCreated: (PDFViewController pdfViewController) {
                pdfViewController.setPage(0);
              },
            ),
    );
  }
}
