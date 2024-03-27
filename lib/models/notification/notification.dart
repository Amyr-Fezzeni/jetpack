// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Notif {
  String id;
  String notificationType;
  String title;
  String body;
  String to;
  bool seen;
  DateTime createdAt;

  Notif({
    required this.id,
    required this.notificationType,
    required this.title,
    required this.body,
    required this.to,
    required this.seen,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'notificationType': notificationType,
      'title': title,
      'body': body,
      'to': to,
      'seen': seen,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Notif.fromMap(Map<String, dynamic> map) {
    return Notif(
      id: map['id'] as String,
      notificationType: map['notificationType'] as String,
      title: map['title'] as String,
      body: map['body'] as String,
      to: map['to'] as String,
      seen: map['seen'] as bool,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory Notif.fromJson(String source) =>
      Notif.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Notif(id: $id, notificationType: $notificationType, title: $title, body: $body, to: $to, seen: $seen, createdAt: $createdAt)';
  }
}

enum NotificationOption { post, message, proposals }

class NotificationSetting {
  NotificationOption title;
  String description;
  bool isActivated;
  NotificationSetting({
    required this.title,
    required this.description,
    required this.isActivated,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'title': title.name,
      'description': description,
      'isActivated': isActivated,
    };
  }

  static NotificationOption getNotificationOptionFromString(String value) =>
      {
        "message": NotificationOption.message,
        "post": NotificationOption.post,
        "proposals": NotificationOption.proposals
      }[value] ??
      NotificationOption.message;

  factory NotificationSetting.fromMap(Map<String, dynamic> map) {
    return NotificationSetting(
      title: getNotificationOptionFromString(map['title']),
      description: map['description'] as String,
      isActivated: map['isActivated'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory NotificationSetting.fromJson(String source) =>
      NotificationSetting.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'NotificationSetting(title: $title, description: $description, isActivated: $isActivated)';
}

final List<NotificationSetting> allNotifications = [
  NotificationSetting(
      title: NotificationOption.message,
      description: 'Somoene sends me a new message.',
      isActivated: true),
  NotificationSetting(
      title: NotificationOption.proposals,
      description: 'A proposal is recived or accepted.',
      isActivated: false),
  NotificationSetting(
      title: NotificationOption.post,
      description:
          'A job posting that matches my skills, a job i applied to has been canceled or closed.',
      isActivated: false)
];
