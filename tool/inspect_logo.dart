import 'dart:io';

Future<void> main() async {
  final file = File('assets/logo.png');
  if (!await file.exists()) {
    print('missing');
    return;
  }

  final bytes = await file.readAsBytes();
  if (bytes.length < 24 || bytes[0] != 0x89) {
    print('notpng');
    return;
  }

  final bd = bytes.buffer.asByteData();
  final width = bd.getUint32(16);
  final height = bd.getUint32(20);
  print('width=$width height=$height size=${bytes.length}');
}
