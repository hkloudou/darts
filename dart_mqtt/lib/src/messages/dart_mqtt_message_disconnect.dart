part of '../mqtt.dart';

class MqttMessageDisconnect extends MqttMessage {
  MqttMessageDisconnect() {
    fixedHead = MqttFixedHead().asType(MqttMessageType.disconnect);
  }
}
