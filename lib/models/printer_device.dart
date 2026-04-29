/// A paired Bluetooth printer surfaced on the dashboard.
class PrinterDevice {
  final String name;
  final String address;
  final String description;
  final bool isConnected;

  const PrinterDevice({
    required this.name,
    required this.address,
    required this.description,
    this.isConnected = false,
  });

  PrinterDevice copyWith({bool? isConnected}) => PrinterDevice(
        name: name,
        address: address,
        description: description,
        isConnected: isConnected ?? this.isConnected,
      );
}
