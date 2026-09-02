import 'package:flutter/foundation.dart';

enum CommunityRole { member, pastor }

class CommunityState extends ChangeNotifier {
  CommunityRole role = CommunityRole.member;
  bool readToday = false;
  int prayers = 8;
  final Set<String> rsvps = {};
  final List<String> careRequests = [
    'Estou precisando de oração pela minha família.',
  ];
  final List<String> notices = ['Encontro de famílias — sábado, 19h'];

  void switchRole(CommunityRole next) {
    role = next;
    notifyListeners();
  }

  void markReading() {
    readToday = true;
    notifyListeners();
  }

  void pray() {
    prayers++;
    notifyListeners();
  }

  void rsvp(String title, String response) {
    rsvps.removeWhere((e) => e.startsWith('$title|'));
    rsvps.add('$title|$response');
    notifyListeners();
  }

  void addCare(String text) {
    careRequests.insert(0, text);
    notifyListeners();
  }

  void addNotice(String text) {
    notices.insert(0, text);
    notifyListeners();
  }
}
