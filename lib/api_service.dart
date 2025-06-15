import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<void> scanCurrency(File imageFile) async {
  var uri = Uri.parse("http://192.168.58.180/predict");

  var request = http.MultipartRequest('POST', uri)
    ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));

  var response = await request.send();

  if (response.statusCode == 200) {
    final respStr = await response.stream.bytesToString();
    final data = jsonDecode(respStr); 
    print('Hasil deteksi: $data');
    print('Nominal: ${data['filename']}, Mata Uang: ${data['currency']}');
  } else {
    print('Gagal deteksi! Status: ${response.statusCode}');
  }
}
