import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jetpack/models/agency.dart';
import 'package:jetpack/models/client.dart';
import 'package:jetpack/models/sector.dart';
import 'package:jetpack/services/util/language.dart';

class AgencyService {
  static CollectionReference<Map<String, dynamic>> agencyCollection =
      FirebaseFirestore.instance.collection('agency');

  static Future<String> addAgency(Agency agency) async {
    try {
      await agencyCollection.doc(agency.id).set(agency.toMap());
    } on Exception {
      return txt('An error has occurred, please try again later');
    }
    return "true";
  }
  static Future<Agency?> getAgency(String city) async {
    try {
      final docs =
          await agencyCollection.where('citys', arrayContains: city).get();
      return docs.docs.isEmpty
          ? null
          : Agency.fromMap(docs.docs.first.data());
    } on Exception {
      return null;
    }
  }
}

class SectorService {
  static CollectionReference<Map<String, dynamic>> sectorCollection =
      FirebaseFirestore.instance.collection('sector');

  static Future<String> addSector(Sector sector) async {
    try {
      await sectorCollection.doc(sector.id).set(sector.toMap());
    } on Exception {
      return txt('An error has occurred, please try again later');
    }
    return "true";
  }

  static Future<Sector?> getSector(String region) async {
    try {
      final sectorDocs =
          await sectorCollection.where('regions', arrayContains: region).get();
      // log(sectorDocs.docs.first.data().toString());
      return sectorDocs.docs.isEmpty
          ? null
          : Sector.fromMap(sectorDocs.docs.first.data());
    } on Exception {
      return null;
    }
  }
}

class ClientService {
  static CollectionReference<Map<String, dynamic>> clientCollection =
      FirebaseFirestore.instance.collection('client');

  static Future<String> addClient(Client client) async {
    try {
      await clientCollection.doc(client.id).set(client.toMap());
    } on Exception {
      return txt('An error has occurred, please try again later');
    }
    return "true";
  }
}
