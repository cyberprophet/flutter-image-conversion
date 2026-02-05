import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_conversion/flutter_image_conversion.dart';

import 'utils/file_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _converter = FlutterImageConversion();

  PlatformFile? _selectedPlatformFile;
  File? _selectedFile;
  File? _convertedFile;
  bool _isConverting = false;
  Uint8List? _convertedBytes;
  bool _isConvertingBytes = false;
  String? _error;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['heic', 'heif'],
      withData: kIsWeb,
    );

    if (result == null || result.files.isEmpty) {
      return;
    }

    final platformFile = result.files.single;

    try {
      final file = await fileFromPlatform(platformFile);
      if (!mounted) {
        return;
      }
      setState(() {
        _selectedPlatformFile = platformFile;
        _selectedFile = file;
        _convertedFile = null;
        _convertedBytes = null;
        _error = null;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = e.toString();
      });
    }
  }

  Future<void> _convert() async {
    final input = _selectedFile;
    if (input == null) {
      return;
    }

    setState(() {
      _isConverting = true;
      _error = null;
    });

    try {
      final converted = await _converter.convertHeicToJpeg(input);
      if (!mounted) {
        return;
      }
      setState(() {
        _convertedFile = converted;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isConverting = false;
        });
      }
    }
  }

  Future<void> _convertBytes() async {
    final platformFile = _selectedPlatformFile;
    if (platformFile == null || platformFile.bytes == null) {
      setState(() {
        _error = 'No file bytes available';
      });
      return;
    }

    setState(() {
      _isConvertingBytes = true;
      _error = null;
    });

    try {
      final inputBytes = platformFile.bytes!;
      final converted = await _converter.convertHeicToJpegBytes(inputBytes);
      if (!mounted) {
        return;
      }
      setState(() {
        _convertedBytes = converted;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isConvertingBytes = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('HEIC Converter'),
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            FilledButton.icon(
              onPressed: _isConverting ? null : _pickFile,
              icon: const Icon(Icons.upload_file),
              label: const Text('Pick HEIC File'),
            ),
            const SizedBox(height: 16),
            if (_selectedPlatformFile != null) _fileInfoCard(theme),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _selectedFile == null || _isConverting
                  ? null
                  : _convert,
              child: _isConverting
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Convert to JPEG'),
            ),
            const SizedBox(height: 8),
            FilledButton.tonal(
              onPressed:
                  _selectedPlatformFile == null ||
                      _selectedPlatformFile!.bytes == null ||
                      _isConvertingBytes
                  ? null
                  : _convertBytes,
              child: _isConvertingBytes
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Convert to JPEG (Bytes)'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
            const SizedBox(height: 24),
            _previewSection('Original', _selectedFile),
            const SizedBox(height: 16),
            _previewSection('Converted', _convertedFile),
            const SizedBox(height: 16),
            if (_convertedBytes != null) _bytesInfoCard(theme),
          ],
        ),
      ),
    );
  }

  Widget _fileInfoCard(ThemeData theme) {
    final file = _selectedPlatformFile!;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Selected File', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            _infoRow('Name', file.name),
            _infoRow('Size', _formatBytes(file.size)),
            _infoRow('Type', file.extension ?? 'unknown'),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(width: 64, child: Text(label)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _previewSection(String label, File? file) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        AspectRatio(
          aspectRatio: 1,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: file == null
                ? const Center(child: Text('No image'))
                : ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: kIsWeb
                        ? Image.network(file.path, fit: BoxFit.contain)
                        : Image.file(file, fit: BoxFit.contain),
                  ),
          ),
        ),
      ],
    );
  }

  String _formatBytes(int bytes) {
    const units = ['B', 'KB', 'MB', 'GB'];
    double size = bytes.toDouble();
    int unit = 0;
    while (size >= 1024 && unit < units.length - 1) {
      size /= 1024;
      unit++;
    }
    return '${size.toStringAsFixed(1)} ${units[unit]}';
  }

  Widget _bytesInfoCard(ThemeData theme) {
    final bytes = _convertedBytes!;
    final hexPreview = bytes
        .take(32)
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join(' ');

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Converted Bytes Result', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            _infoRow('Size', _formatBytes(bytes.length)),
            _infoRow('Format', 'Uint8List'),
            const SizedBox(height: 8),
            Text('First 32 bytes (hex):', style: theme.textTheme.bodySmall),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                hexPreview,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
