import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jetpack/models/colis.dart';
import 'package:jetpack/models/runsheet.dart';
import 'package:jetpack/models/user.dart';
import 'package:jetpack/services/util/language.dart';

class DayReportService {
  static CollectionReference<Map<String, dynamic>> dayReportCollection =
      FirebaseFirestore.instance.collection('day report');

  static Future<String> createDayReport(EndOfDayReport dayReport) async {
    try {
      await dayReportCollection.doc(dayReport.id).set(dayReport.toMap());
    } on Exception {
      return txt('An error has occurred, please try again later');
    }
    return "true";
  }

  static Future<EndOfDayReport> getDayReport(
      RunSheet runsheet, UserModel user, List<Colis> colis) async {
    final data = await dayReportCollection.doc(runsheet.id).get();
    if (data.exists) {
      return EndOfDayReport.fromMap(data.data()!);
    } else {
      return EndOfDayReport(
          id: runsheet.id,
          agenceId: user.agency?['id'],
          agenceName: user.agency?['name'],
          sectorId: user.sector['id'],
          sectorName: user.sector['name'],
          deliveryId: user.id,
          dateCreated: runsheet.dateCreated!,
          date: runsheet.date,
          collectionDate: DateTime.now(),
          colis: colis
              .map((e) => <String, dynamic>{
                    'id': e.id,
                    'status': e.status == ColisStatus.delivered.name
                        ? 'delivered'
                        : "canceled"
                  })
              .toList());
    }
  }
}
