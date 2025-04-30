import 'dart:io';

Future<void> main() async {
  final interfaces = await NetworkInterface.list(
    type: InternetAddressType.IPv4,
    includeLoopback: false,
  );

  for (var interface in interfaces) {
    // Optional: Match name (e.g., "Wi-Fi" on Windows)
    if (interface.name.toLowerCase().contains('wi-fi')) {
      for (var addr in interface.addresses) {
        print('Wi-Fi IPv4 address: ${addr.address}');
      }
    }
  }
}
