import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart'; // برای استفاده از debugPrint
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';

class BleManager {
  static final BleManager _instance = BleManager._internal();
  factory BleManager() => _instance;
  BleManager._internal();

  final _ble = FlutterReactiveBle();

  StreamSubscription? _scanSub;
  StreamSubscription? _connectionSub;
  StreamSubscription? _statusSub;

  DeviceConnectionState connectionState = DeviceConnectionState.disconnected;
  String? _connectedDeviceId;

  // UUIDهای قرارداد شده با ESP32
  final serviceUuid = Uuid.parse("4fafc201-1fb5-459e-8fcc-c5c9c331914b");
  final charUuid = Uuid.parse("beb5483e-36e1-4688-b7f5-ea07361b26a8");
  final String targetDeviceName = "ESP32-Coffee-Machine";

  final _connectionController = StreamController<DeviceConnectionState>.broadcast();
  Stream<DeviceConnectionState> get stateStream => _connectionController.stream;

  // درخواست دسترسی‌ها به صورت استاندارد
  Future<bool> requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    return statuses[Permission.bluetoothScan] == PermissionStatus.granted &&
        statuses[Permission.bluetoothConnect] == PermissionStatus.granted &&
        statuses[Permission.location] == PermissionStatus.granted;
  }

  // متد ران شدن اصلی بلوتوث بعد از تایید دسترسی‌ها در اسپلش اسکرین
  void init() {
    // ابتدا وضعیت سخت‌افزاری بلوتوث را مانیتور می‌کنیم
    _statusSub?.cancel();
    _statusSub = _ble.statusStream.listen((status) {
      debugPrint("BLE Hardware Status: $status");
      if (status == BleStatus.ready) {
        // فقط زمانی اسکن را شروع کن که بلوتوث دستگاه واقعا روشن و آماده باشد
        _startAutoConnect();
      } else if (status == BleStatus.poweredOff) {
        debugPrint("بلوتوث کاربر خاموش است.");
        _handleDisconnect();
      }
    });
  }

  void _startAutoConnect() {
    // جلوگیری از تداخل اسکن‌های همزمان
    _scanSub?.cancel();

    debugPrint("Scanning for $targetDeviceName...");

    // می‌توانید به جای لیسن خالی، UUID سرویس را فیلتر کنید تا باتری کمتری مصرف شود
    _scanSub = _ble.scanForDevices(withServices: []).listen((device) {
      if (device.name == targetDeviceName && _connectedDeviceId == null) {
        debugPrint("Found device: ${device.name} [${device.id}]");
        _connectToDevice(device.id);
      }
    }, onError: (e) {
      debugPrint("Scan Error: $e. Retrying in 5 seconds...");
      Future.delayed(const Duration(seconds: 5), () {
        if (_connectedDeviceId == null) _startAutoConnect();
      });
    });
  }

  void _connectToDevice(String deviceId) {
    _scanSub?.cancel();
    _connectionSub?.cancel();

    debugPrint("Connecting to $deviceId...");

    _connectionSub = _ble.connectToDevice(
      id: deviceId,
      connectionTimeout: const Duration(seconds: 10),
    ).listen((state) {
      connectionState = state.connectionState;
      _connectionController.add(state.connectionState);

      if (state.connectionState == DeviceConnectionState.connected) {
        _connectedDeviceId = deviceId;
        debugPrint("Successfully connected to ESP32 Coffee Machine!");
      } else if (state.connectionState == DeviceConnectionState.disconnected) {
        debugPrint("Connection lost.");
        _handleDisconnect();
      }
    }, onError: (e) {
      debugPrint("Connection Error: $e");
      _handleDisconnect();
    });
  }

  void _handleDisconnect() {
    _connectedDeviceId = null;
    connectionState = DeviceConnectionState.disconnected;
    _connectionController.add(DeviceConnectionState.disconnected);
    _startAutoConnect();
  }

  Future<bool> sendOrder(String productId, int quantity) async {
    if (connectionState != DeviceConnectionState.connected || _connectedDeviceId == null) {
      debugPrint("Cannot send order: Not connected to ESP32");
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
      debugPrint("Sent to ESP32: $data");
      return true;
    } catch (e) {
      debugPrint("Error sending data: $e");
      return false;
    }
  }

  void dispose() {
    _scanSub?.cancel();
    _connectionSub?.cancel();
    _statusSub?.cancel();
    _connectionController.close();
  }
}