import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';

class BleManager {
  static final BleManager _instance = BleManager._internal();

  factory BleManager() => _instance;

  BleManager._internal();

  final FlutterReactiveBle _ble = FlutterReactiveBle();

  StreamSubscription? _scanSub;
  StreamSubscription? _connectionSub;
  StreamSubscription? _statusSub;
  StreamSubscription? _notifySub;
  String? _lastResponse;

  DeviceConnectionState connectionState =
      DeviceConnectionState.disconnected;

  String? _connectedDeviceId;

  final serviceUuid =
  Uuid.parse("4fafc201-1fb5-459e-8fcc-c5c9c331914b");

  final charUuid =
  Uuid.parse("beb5483e-36e1-4688-b7f5-ea07361b26a8");

  final String targetDeviceName =
      "ESP32-Coffee-Machine";

  final _connectionController =
  StreamController<DeviceConnectionState>.broadcast();

  Stream<DeviceConnectionState> get stateStream =>
      _connectionController.stream;

  // پاسخ دریافتی از ESP32
  final _responseController =
  StreamController<String>.broadcast();

  Stream<String> get responseStream =>
      _responseController.stream;

  Future<bool> requestPermissions() async {
    final statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    return statuses[Permission.bluetoothScan] ==
        PermissionStatus.granted &&
        statuses[Permission.bluetoothConnect] ==
            PermissionStatus.granted &&
        statuses[Permission.location] ==
            PermissionStatus.granted;
  }

  void init() {
    _statusSub?.cancel();

    _statusSub = _ble.statusStream.listen((status) {
      debugPrint("BLE Status: $status");

      if (status == BleStatus.ready) {
        _startAutoConnect();
      } else {
        _handleDisconnect();
      }
    });
  }

  void _startAutoConnect() {
    _scanSub?.cancel();

    debugPrint("Scanning for device...");

    _scanSub = _ble.scanForDevices(
      withServices: [],
    ).listen(
          (device) {
        if (device.name == targetDeviceName &&
            _connectedDeviceId == null) {
          debugPrint("Found: ${device.name}");

          _connectToDevice(device.id);
        }
      },
      onError: (e) {
        debugPrint("Scan Error: $e");
      },
    );
  }

  void _connectToDevice(String deviceId) {
    _scanSub?.cancel();
    _connectionSub?.cancel();

    debugPrint("Connecting...");

    _connectionSub = _ble
        .connectToDevice(
      id: deviceId,
      connectionTimeout:
      const Duration(seconds: 10),
    )
        .listen(
          (state) {
        connectionState = state.connectionState;

        _connectionController.add(
          state.connectionState,
        );

        if (state.connectionState ==
            DeviceConnectionState.connected) {
          _connectedDeviceId = deviceId;

          debugPrint("Connected");

          _startListening();
        }

        if (state.connectionState ==
            DeviceConnectionState.disconnected) {
          _handleDisconnect();
        }
      },
      onError: (e) {
        debugPrint("Connection Error: $e");

        _handleDisconnect();
      },
    );
  }

  // گوش دادن به notification های ESP32
  void _startListening() {
    if (_connectedDeviceId == null) return;

    final characteristic =
    QualifiedCharacteristic(
      serviceId: serviceUuid,
      characteristicId: charUuid,
      deviceId: _connectedDeviceId!,
    );

    _notifySub?.cancel();

    _notifySub = _ble
        .subscribeToCharacteristic(characteristic)
        .listen(
          (data) {
            final response = utf8.decode(data).trim();
            _lastResponse = response;
            _responseController.add(response);

        debugPrint("ESP32 Response: $response");

        _responseController.add(response);
      },
      onError: (e) {
        debugPrint("Notification Error: $e");
      },
    );
  }

  Future<String> waitForResponse({
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final start = DateTime.now();

    while (DateTime.now().difference(start) < timeout) {
      if (_lastResponse == "1" || _lastResponse == "0") {
        final result = _lastResponse!;
        _lastResponse = null; // reset
        return result;
      }

      await Future.delayed(const Duration(milliseconds: 50));
    }

    return "0";
  }


  // ورودی wantsCup به این متد اضافه شد
  Future<bool> sendOrder(String productId, int quantity, bool wantsCup) async {
    if (connectionState != DeviceConnectionState.connected || _connectedDeviceId == null) {
      debugPrint("Not connected");
      return false;
    }

    try {
      final characteristic = QualifiedCharacteristic(
        serviceId: serviceUuid,
        characteristicId: charUuid,
        deviceId: _connectedDeviceId!,
      );

      // تبدیل بولین به رشته دلخواه شما (TRUE/FALSE)
      final cupStr = wantsCup ? "TRUE" : "FALSE";

      // ساخت رشته نهایی: "cappuccino,1,TRUE"
      final data = "$productId,$quantity,$cupStr";

      await _ble.writeCharacteristicWithResponse(
        characteristic,
        value: utf8.encode(data),
      );

      debugPrint("Sent: $data");

      return true;
    } catch (e) {
      debugPrint("Send Error: $e");
      return false;
    }
  }

  void _handleDisconnect() {
    _connectedDeviceId = null;

    connectionState =
        DeviceConnectionState.disconnected;

    _connectionController.add(
      DeviceConnectionState.disconnected,
    );

    _notifySub?.cancel();

    _startAutoConnect();
  }

  void dispose() {
    _scanSub?.cancel();
    _connectionSub?.cancel();
    _statusSub?.cancel();
    _notifySub?.cancel();

    _connectionController.close();
    _responseController.close();
  }
}