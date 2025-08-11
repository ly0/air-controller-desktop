import 'dart:convert';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';

import '../bootstrap.dart';
import '../model/device.dart';
import 'dart:io';
import 'dart:typed_data';
import '../constant.dart';

abstract class DeviceDiscoverManager {
  static final DeviceDiscoverManager _instance = DeviceDiscoverManagerImpl();

  static DeviceDiscoverManager get instance {
    return _instance;
  }

  void startDiscover();

  void stopDiscover();

  void onDeviceFind(void callback(Device device));

  bool isDiscovering();
}

class DeviceDiscoverManagerImpl implements DeviceDiscoverManager {
  RawDatagramSocket? udpSocket;
  var _isDiscovering = false;
  Function(Device device)? _onDeviceFind;

  @override
  void startDiscover() {
    if (_isDiscovering) {
      _log("It's discovering, start discover is invalid!");
      return;
    }

    RawDatagramSocket.bind(InternetAddress.anyIPv4, Constant.PORT_SEARCH)
        .then((udpSocket) {
      this.udpSocket = udpSocket;

      udpSocket.listen((event) {
        Datagram? datagram = udpSocket.receive();

        // 打印接收到的UDP事件
        print("[UDP] 收到广播事件: $event");
        
        if (datagram != null) {
          // 打印发送方信息
          print("[UDP] 广播来源: ${datagram.address.address}:${datagram.port}");
          print("[UDP] 数据包大小: ${datagram.data.length} bytes");
        }

        Uint8List? data = datagram?.data;

        if (null != data) {
          String str = String.fromCharCodes(data);
          
          // 打印接收到的原始数据
          print("[UDP] 接收到的原始数据: $str");
          print("[UDP] 本机IP: ${udpSocket.address.address}");
          
          _log(str + ", ip: ${udpSocket.address.address}");

          if (_isValidData(str)) {
            print("[UDP] ✅ 数据验证通过，开始解析设备信息...");
            Device device = _convertToDevice(str);
            print("[UDP] 解析到设备: 平台=${device.platform}, 名称=${device.name}, IP=${device.ip}");
            
            _onDeviceFind?.call(device);

            print("[UDP] 正在向设备 ${device.ip} 发送响应...");
            _responseToDesktop(device.ip);

            _log("Device: $device");
            print("[UDP] ✅ 设备发现流程完成: $device");
          } else {
            print("[UDP] ❌ 数据验证失败，非有效的搜索消息");
            print("[UDP] 期望前缀: ${Constant.CMD_SEARCH_PREFIX}${Constant.RANDOM_STR_SEARCH}#");
            _log("It's not valid, str: ${str}");
          }
        } else {
          print("[UDP] ⚠️ 接收到空数据包");
        }

        _log("ip: ${udpSocket.address.address}");
      });

      _log("Udp listen started, port: ${Constant.PORT_SEARCH}");
      print("[UDP] ========================================");
      print("[UDP] UDP 设备发现服务已启动");
      print("[UDP] 监听端口: ${Constant.PORT_SEARCH}");
      print("[UDP] 监听地址: ${udpSocket.address.address}");
      print("[UDP] 等待接收来自手机的广播包...");
      print("[UDP] 期望的消息前缀: ${Constant.CMD_SEARCH_PREFIX}${Constant.RANDOM_STR_SEARCH}#");
      print("[UDP] ========================================");
    }).catchError((error) {
      _log("startDiscover error: $error");
    });
  }

  void _responseToDesktop(String address) async {
    DeviceInfoPlugin deviceInfo = new DeviceInfoPlugin();
    String deviceName = "";
    String? ip = "";

    if (Platform.isMacOS) {
      MacOsDeviceInfo macOsDeviceInfo = await deviceInfo.macOsInfo;
      deviceName = macOsDeviceInfo.computerName;

      NetworkInfo networkInfo = NetworkInfo();
      ip = await networkInfo.getWifiIP();
    }

    String data =
        "${Constant.CMD_SEARCH_RES_PREFIX}${Constant.RADNOM_STR_RES_SEARCH}#${Constant.PLATFORM_MACOS}#$deviceName#$ip";
    
    print("[UDP] 发送响应数据: $data");
    print("[UDP] 发送到地址: $address:${Constant.PORT_SEARCH}");

    this.udpSocket?.send(
        utf8.encode(data),
        InternetAddress(address, type: InternetAddressType.IPv4),
        Constant.PORT_SEARCH);
    
    print("[UDP] ✅ 响应已发送");
  }

  bool _isValidData(String data) {
    return data.startsWith(
        "${Constant.CMD_SEARCH_PREFIX}${Constant.RANDOM_STR_SEARCH}#");
  }

  Device _convertToDevice(String searchStr) {
    _log("Search str: ${searchStr}");
    int start =
        "${Constant.CMD_SEARCH_PREFIX}${Constant.RANDOM_STR_SEARCH}#".length;
    String deviceStr = searchStr.substring(start);

    _log(deviceStr);

    List<String> strList = deviceStr.split("#");
    int platform = Device.PLATFORM_UNKNOWN;
    if (strList.isNotEmpty) {
      platform = int.parse(strList[0]);
    }

    String name = "";
    if (strList.length > 1) {
      name = strList[1];
    }

    String ip = "";
    if (strList.length > 2) {
      ip = strList[2];
    }

    Device device = Device(platform, name, ip);
    return device;
  }

  void _log(String msg) {
    if (Constant.ENABLE_UDP_DISCOVER_LOG) {
      logger.d("DeviceDiscover: $msg");
      print("[DeviceDiscover] $msg");
    }
  }

  @override
  void stopDiscover() {
    udpSocket?.close();
    _isDiscovering = false;
  }

  @override
  void onDeviceFind(void Function(Device device) callback) {
    _onDeviceFind = callback;
  }

  @override
  bool isDiscovering() {
    return _isDiscovering;
  }
}
