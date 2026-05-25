import 'dart:async';
import 'dart:convert';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';

class BleManager {
  static final BleManager _instance = BleManager._internal();
  factory BleManager() => _instance;
  BleManager._internal();

  final _ble = FlutterReactiveBle();
  StreamSubscription? _scanSub;
  StreamSubscription? _connectionSub;
  
  DeviceConnectionState connectionState = DeviceConnectionState.disconnected;
  String? _connectedDeviceId;

  // UUID های قرارداد شده (باید با کد ESP32 یکی باشد)
  final serviceUuid = Uuid.parse("4fafc201-1fb5-459e-8fcc-c5c9c331914b");
  final charUuid = Uuid.parse("beb5483e-36e1-4688-b7f5-ea07361b26a8");
  final String targetDeviceName = "ESP32-Coffee-Machine";

  final _connectionController = StreamController<DeviceConnectionState>.broadcast();
  Stream<DeviceConnectionState> get stateStream => _connectionController.stream;

  void init() {
    _checkPermissions();
    _startAutoConnect();
  }

  Future<void> _checkPermissions() async {
    await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();
  }

  void _startAutoConnect() {
    _scanSub?.cancel();
    _scanSub = _ble.scanForDevices(withServices: []).listen((device) {
      if (device.name == targetDeviceName && _connectedDeviceId == null) {
        print("Found device: ${device.name}");
        _connectToDevice(device.id);
      }
    }, onError: (e) {
      print("Scan Error: $e");
      Future.delayed(const Duration(seconds: 5), _startAutoConnect);
    });
  }

  void _connectToDevice(String deviceId) {
    _scanSub?.cancel();
    _connectionSub?.cancel();
    
    _connectionSub = _ble.connectToDevice(
      id: deviceId,
      connectionTimeout: const Duration(seconds: 10),
    ).listen((state) {
      connectionState = state.connectionState;
      _connectionController.add(state.connectionState);
      
      if (state.connectionState == DeviceConnectionState.connected) {
        _connectedDeviceId = deviceId;
        print("Connected to ESP32!");
      } else if (state.connectionState == DeviceConnectionState.disconnected) {
        _connectedDeviceId = null;
        print("Disconnected. Retrying...");
        _startAutoConnect();
      }
    }, onError: (e) {
      _connectedDeviceId = null;
      _startAutoConnect();
    });
  }

  Future<bool> sendOrder(String productId, int quantity) async {
    if (connectionState != DeviceConnectionState.connected || _connectedDeviceId == null) {
      print("Not connected to ESP32");
      return false;
    }

    try {
      final characteristic = QualifiedCharacteristic(
        serviceId: serviceUuid,
        characteristicId: charUuid,
        deviceId: _connectedDeviceId!,
      );

      // فرمت ارسال: "PROD_ID,QTY"
      final data = "$productId,$quantity";
      await _ble.writeCharacteristicWithResponse(characteristic, value: utf8.encode(data));
      print("Sent to ESP32: $data");
      return true;
    } catch (e) {
      print("Error sending data: $e");
      return false;
    }
  }

  void dispose() {
    _scanSub?.cancel();
    _connectionSub?.cancel();
    _connectionController.close();
  }
}
