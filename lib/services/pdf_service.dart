import 'dart:developer';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:jetpack/constants/constants.dart';
import 'package:jetpack/models/colis.dart';
import 'package:jetpack/models/expeditor_payment.dart';
import 'package:jetpack/models/manifest.dart';
import 'package:jetpack/models/return_colis.dart';
import 'package:jetpack/models/runsheet.dart';
import 'package:jetpack/models/user.dart';
import 'package:jetpack/services/colis_service.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/services/util/logic_service.dart';
import 'package:jetpack/services/util/navigation_service.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
// import 'package:flutter/material.dart' as mt;
// import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/widgets.dart';

class PdfService {
  static Future<void> generateMagnifest(
      Manifest invoice, List<Colis> colis) async {
    await requestPermission();
    final pdf = Document();
    final image = (await rootBundle.load(logo)).buffer.asUint8List();
    pdf.addPage(MultiPage(
      pageFormat: PdfPageFormat.a4.landscape,
      build: (context) => [
        Align(
            alignment: Alignment.centerLeft,
            child: Image(MemoryImage(image), width: 100)),
        Center(
          child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 5),
              decoration: BoxDecoration(
                  border: Border.all(), borderRadius: BorderRadius.circular(4)),
              child: Text('MANIFEST ${invoice.expeditorName}'.toUpperCase(),
                  style: const TextStyle(fontSize: 20))),
        ),
        SizedBox(height: 2 * PdfPageFormat.cm),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                rowTxt("Nom:", invoice.expeditorName),
                SizedBox(height: 10),
                rowTxt("Contact:", ''),
              ]),
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                rowTxt("Adresse:", invoice.adress),
                SizedBox(height: 10),
                rowTxt("Telephone:", invoice.phoneNumber),
              ]),
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                rowTxt("Code TVA:", ''),
                SizedBox(height: 10),
                rowTxt("Date:", getDate(invoice.dateCreated)),
              ]),
        ]),
        SizedBox(height: 1 * PdfPageFormat.cm),
        rowTxt("Nombre total des colis:", invoice.colis.length.toString()),
        rowTxt("Total:",
            '${colis.map((c) => c.price).reduce((b, a) => a + b).toStringAsFixed(3)} TND'),
        SizedBox(height: 1 * PdfPageFormat.cm),
        TableHelper.fromTextArray(
          headers: ['Code', 'Prix', 'Dispatch', 'Gouvernorat', 'Designation'],
          data: colis.map((colis) {
            return [
              colis.id,
              colis.price.toStringAsFixed(3),
              "${invoice.region} => ${colis.agenceName}",
              [colis.governorate, colis.city, colis.region, colis.address]
                  .join(', '),
              "${colis.name}\n${colis.phone1}\n${colis.phone2}",
              colis.exchange ? "Echange" : "Livraison"
            ];
          }).toList(),
          columnWidths: {
            0: const IntrinsicColumnWidth(flex: 1.4),
            1: const IntrinsicColumnWidth(flex: .8),
            2: const IntrinsicColumnWidth(flex: 2),
            3: const IntrinsicColumnWidth(flex: 3),
            4: const IntrinsicColumnWidth(flex: 1),
            5: const IntrinsicColumnWidth(flex: 1),
          },
          headerStyle: TextStyle(fontWeight: FontWeight.bold),
          headerDecoration: const BoxDecoration(color: PdfColors.grey300),
          cellAlignments: {
            0: Alignment.center,
            1: Alignment.centerLeft,
            2: Alignment.centerLeft,
            3: Alignment.centerLeft,
            4: Alignment.centerLeft,
          },
        )
      ],
    ));
    final file = await saveDocument(
        name: "Manifest ${getDate(invoice.dateCreated)}", pdf: pdf);
    openFile(file);
  }

  static Future<void> generateRunsheet(RunsheetPdf invoice) async {
    await requestPermission();
    final pdf = Document();
    final image = (await rootBundle.load(logo)).buffer.asUint8List();
    pdf.addPage(MultiPage(
      pageFormat: PdfPageFormat
          .a4.landscape, //const PdfPageFormat(29.7, 21, marginAll: 15),
      // orientation: PageOrientation.landscape,
      build: (context) => [
        Align(
            alignment: Alignment.centerLeft,
            child: Image(MemoryImage(image), width: 100)),
        Center(
          child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 5),
              decoration: BoxDecoration(
                  border: Border.all(), borderRadius: BorderRadius.circular(4)),
              child: Text(
                  'Ordre de mission / bon de livraison n ${invoice.id}'
                      .toUpperCase(),
                  style: const TextStyle(fontSize: 20))),
        ),
        SizedBox(height: 2 * PdfPageFormat.cm),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                rowTxt("Agence:", invoice.agenceName),
                SizedBox(height: 10),
                rowTxt("Nom Livreur:", invoice.deliveryName),
              ]),
          rowTxt("Voiture:", invoice.matricule),
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                rowTxt("Date:", invoice.date),
                SizedBox(height: 10),
                rowTxt("CIN:", invoice.deliveryCin),
              ]),
        ]),
        SizedBox(height: 1 * PdfPageFormat.cm),
        rowTxt("Nombre total des colis:", invoice.colis.length.toString()),
        rowTxt("Nombre des colis echange:",
            invoice.colis.where((c) => c.exchange).length.toString()),
        SizedBox(height: 1 * PdfPageFormat.cm),
        TableHelper.fromTextArray(
          headers: [
            'T',
            'N Borderau',
            'Expediteur',
            'Date enlevement',
            'Montant',
            'Client',
            'Adresse',
            "Message"
          ],
          data: invoice.colis.map((colis) {
            return [
              colis.tentative,
              colis.id,
              colis.expeditorName,
              getDate(colis.pickupDate),
              '${colis.price}',
              "${colis.name}\n${colis.phone1}\n${colis.phone2}",
              colis.address,
              colis.comment
            ];
          }).toList(),
          headerStyle: TextStyle(fontWeight: FontWeight.bold),
          headerDecoration: const BoxDecoration(color: PdfColors.grey300),
          cellAlignments: {
            0: Alignment.center,
            1: Alignment.centerLeft,
            2: Alignment.centerLeft,
            3: Alignment.center,
            4: Alignment.center,
            5: Alignment.centerLeft,
            6: Alignment.centerLeft,
            7: Alignment.centerLeft,
          },
        )
      ],
    ));
    final file = await saveDocument(name: "Runsheet ${invoice.date}", pdf: pdf);
    openFile(file);
  }

  static Future<void> generateExpeditorPayment(
      ExpeditorPayment invoice, List<Colis> colis) async {
    await requestPermission();
    final pdf = Document();
    final image = (await rootBundle.load(logo)).buffer.asUint8List();
    pdf.addPage(MultiPage(
      pageFormat: PdfPageFormat.a4.landscape,
      build: (context) => [
        Align(
            alignment: Alignment.centerLeft,
            child: Image(MemoryImage(image), width: 100)),
        Center(
          child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 5),
              decoration: BoxDecoration(
                  border: Border.all(), borderRadius: BorderRadius.circular(4)),
              child: Column(children: [
                Text('Detail recette'.toUpperCase(),
                    style: const TextStyle(fontSize: 20)),
                Text('Date: ${getDate(DateTime.now())}'.toUpperCase(),
                    style: const TextStyle(fontSize: 20))
              ])),
        ),
        SizedBox(height: 1 * PdfPageFormat.cm),
        Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                rowTxt("Expeditor:", invoice.expeditorName),
                SizedBox(height: 10),
                rowTxt("Adress:", invoice.region),
                SizedBox(height: 10),
                rowTxt("Phone number:", invoice.expeditorPhoneNumber),
              ]),
        ]),
        SizedBox(height: 1 * PdfPageFormat.cm),
        TableHelper.fromTextArray(
          headers: [
            'Code',
            'Client',
            'Designation',
            'Etat',
            'Prix',
            'Date',
          ],
          data: [
            ...colis,
          ].map((colis) {
            return [
              colis.id,
              '${colis.name} / ${colis.phone1}',
              !colis.exchange ? "Livraison" : "Echange",
              [ColisStatus.delivered.name, ColisStatus.closed.name]
                      .contains(colis.status)
                  ? "Livré"
                  : "Retour",
              '${colis.price}',
              getDate(colis.pickupDate),
            ];
          }).toList(),
          headerStyle: TextStyle(fontWeight: FontWeight.bold),
          headerDecoration: const BoxDecoration(color: PdfColors.grey300),
          cellAlignments: {
            0: Alignment.center,
            1: Alignment.centerLeft,
            2: Alignment.centerLeft,
            3: Alignment.centerLeft,
            4: Alignment.centerLeft,
            5: Alignment.centerLeft,
          },
        ),
        SizedBox(height: 1 * PdfPageFormat.cm),
        TableHelper.fromTextArray(
          tableWidth: TableWidth.min,
          data: [
            ["Tatal recette", "${invoice.totalprice} TND"],
            ["Frais de livraison", "${invoice.deliveryPrice} TND"],
            ["Net a payer", "${invoice.price} TND"],
          ],
          cellAlignments: {
            0: Alignment.centerLeft,
            1: Alignment.centerLeft,
          },
        )
      ],
    ));
    final file =
        await saveDocument(name: "Expeditor payment ${invoice.id}", pdf: pdf);
    openFile(file);
  }

  static Future<void> generateDayReport(RunsheetPdf invoice) async {
    await requestPermission();
    final pdf = Document();
    final image = (await rootBundle.load(logo)).buffer.asUint8List();
    pdf.addPage(MultiPage(
      pageFormat: PdfPageFormat.a4.landscape,
      build: (context) => [
        Align(
            alignment: Alignment.centerLeft,
            child: Image(MemoryImage(image), width: 100)),
        Center(
          child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 5),
              decoration: BoxDecoration(
                  border: Border.all(), borderRadius: BorderRadius.circular(4)),
              child: Text('Rapport de fin de journée'.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20))),
        ),
        SizedBox(height: 2 * PdfPageFormat.cm),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                rowTxt("Agence:", invoice.agenceName),
                SizedBox(height: 10),
                rowTxt("Nom Livreur:", invoice.deliveryName),
              ]),
          rowTxt("Voiture:", invoice.matricule),
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                rowTxt("Date:", invoice.date),
                SizedBox(height: 10),
                rowTxt("CIN:", invoice.deliveryCin),
              ]),
        ]),
        SizedBox(height: 1 * PdfPageFormat.cm),
        rowTxt(
            "Nombre total des colis livrés:",
            invoice.colis
                .where((c) => [ColisStatus.delivered.name].contains(c.status))
                .length
                .toString()),
        rowTxt(
            "Nombre des colis retour:",
            invoice.colis
                .where((c) => [
                      ColisStatus.returnDepot.name,
                      ColisStatus.depot.name,
                      ColisStatus.canceled,
                      ColisStatus.appointment.name
                    ].contains(c.status))
                .length
                .toString()),
        rowTxt("Nombre des colis echange:",
            invoice.colis.where((c) => c.exchange).length.toString()),
        SizedBox(height: .5 * PdfPageFormat.cm),
        TableHelper.fromTextArray(
          tableWidth: TableWidth.min,
          data: [
            [
              "Tatal recette",
              "${invoice.colis.where((c) => c.status == ColisStatus.delivered.name).map((e) => e.price).reduce((a, b) => a + b).toStringAsFixed(3)} TND"
            ],
          ],
          cellAlignments: {
            0: Alignment.centerLeft,
            1: Alignment.centerLeft,
          },
        ),
        SizedBox(height: .5 * PdfPageFormat.cm),
        TableHelper.fromTextArray(
          headers: [
            'T',
            'N Borderau',
            'Expediteur',
            'Date enlevement',
            'Montant',
            'Client',
            'Adresse',
            "Statut"
          ],
          data: invoice.colis.map((colis) {
            return [
              colis.tentative,
              colis.id,
              colis.expeditorName,
              getDate(colis.pickupDate),
              '${colis.price}',
              "${colis.name}\n${colis.phone1}\n${colis.phone2}",
              colis.address,
              [
                ColisStatus.returnDepot.name,
                ColisStatus.depot.name,
                ColisStatus.canceled,
                ColisStatus.appointment.name
              ].contains(colis.status)
                  ? "Retour"
                  : "Livré"
            ];
          }).toList(),
          headerStyle: TextStyle(fontWeight: FontWeight.bold),
          headerDecoration: const BoxDecoration(color: PdfColors.grey300),
          cellAlignments: {
            0: Alignment.center,
            1: Alignment.centerLeft,
            2: Alignment.centerLeft,
            3: Alignment.center,
            4: Alignment.center,
            5: Alignment.centerLeft,
            6: Alignment.centerLeft,
            7: Alignment.centerLeft,
          },
        ),
      ],
    ));
    final file =
        await saveDocument(name: "Day report ${invoice.date}", pdf: pdf);
    openFile(file);
  }

  static Future<void> generateColis(List<Colis> lst) async {
    await requestPermission();
    final pdf = Document();
    final image = (await rootBundle.load(logo)).buffer.asUint8List();
    final fragileImage =
        (await rootBundle.load(fragileIcon)).buffer.asUint8List();
    final ctx = NavigationService.navigatorKey.currentContext!;
    pdf.addPage(MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (context) => [
        for (var colis in lst) ...[
          SizedBox(height: 2 * PdfPageFormat.cm),
          TableHelper.fromTextArray(
            data: [
              [
                SizedBox(
                  height: 50,
                  width: 100,
                  child:
                      BarcodeWidget(data: colis.id, barcode: Barcode.codabar()),
                ),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      rowTxt("Expeditor:",
                          ctx.userprovider.currentUser!.getFullName()),
                      rowTxt("Adresse:", ctx.userprovider.currentUser!.adress),
                      rowTxt('Telephone:',
                          ctx.userprovider.currentUser!.phoneNumber),
                      Divider(),
                      rowTxt('Date:', getDate(colis.creationDate)),
                      rowTxt('Destination:', colis.agenceName)
                    ]),
              ],
            ],
          ),
          Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
              width: double.maxFinite,
              decoration: BoxDecoration(
                border: Border.all(),
              ),
              child: Row(children: [
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      rowTxt("Destinataire:", colis.name),
                      rowTxt("Adresse:", colis.address),
                      rowTxt('Telephone 1:', colis.phone1),
                      rowTxt('Telephone 2:', colis.phone2),
                    ]),
                Spacer(),
                if (colis.isFragile)
                  Image(MemoryImage(fragileImage), height: 50),
                SizedBox(width: 20)
              ])),
          Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
              decoration: BoxDecoration(
                border: Border.all(),
              ),
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (colis.exchange) rowTxt("Echange", ''),
                        ]),
                    Spacer(),
                    rowTxt("A payer:", '${colis.price.toStringAsFixed(3)} TND'),
                  ])),
          Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
              decoration: BoxDecoration(
                border: Border.all(),
              ),
              child: Row(
                  // crossAxisAlignment: Cross,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Image(MemoryImage(image), width: 100)])),
          SizedBox(height: 2 * PdfPageFormat.cm),
        ]
      ],
    ));
    final file =
        await saveDocument(name: "Colis ${getDate(DateTime.now())}", pdf: pdf);
    openFile(file);
  }

  static Future<void> generateReturnColis(ReturnColis invoice) async {
    // await ColisService.colisCollection
    //     .doc(colis.id)
    //     .update({'status': ColisStatus.returnExpeditor.name});
    await requestPermission();
    final pdf = Document();
    final image = (await rootBundle.load(logo)).buffer.asUint8List();
    pdf.addPage(MultiPage(
      pageFormat: PdfPageFormat.a4.landscape,
      build: (context) => [
        Align(
            alignment: Alignment.centerLeft,
            child: Image(MemoryImage(image), width: 100)),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 5),
            decoration: BoxDecoration(
                border: Border.all(), borderRadius: BorderRadius.circular(4)),
            child: Text('Retour Expediteur'.toUpperCase(),
                style: const TextStyle(fontSize: 20)),
          ),
        ),
        SizedBox(height: 1 * PdfPageFormat.cm),
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    rowTxt("Agence:", invoice.agencyName),
                    SizedBox(height: 10),
                    rowTxt("Expeditor:", invoice.expeditorName),
                    SizedBox(height: 10),
                    rowTxt("Phone number:", invoice.expeditorPhoneNumber),
                  ]),
              rowTxt("Date:", getDate(invoice.date)),
            ]),
        SizedBox(height: 1 * PdfPageFormat.cm),
        TableHelper.fromTextArray(
          headers: [
            'Code',
            'Date enlèvement',
            'Montant',
            'Client',
            'Adresse',
          ],
          data: [
            ...invoice.colis,
          ].map((colis) {
            return [
              colis.id,
              getDate(colis.pickupDate),
              '${colis.price}',
              '${colis.name} / ${colis.phone1}',
              "${invoice.region}, ${invoice.address}"
            ];
          }).toList(),
          headerStyle: TextStyle(fontWeight: FontWeight.bold),
          headerDecoration: const BoxDecoration(color: PdfColors.grey300),
          cellAlignments: {
            0: Alignment.center,
            1: Alignment.centerLeft,
            2: Alignment.centerLeft,
            3: Alignment.centerLeft,
            4: Alignment.centerLeft,
          },
        )
      ],
    ));
    final file =
        await saveDocument(name: "Expeditor retour ${invoice.id}", pdf: pdf);
    openFile(file);
  }

  static Future<File> saveDocument({
    required String name,
    required Document pdf,
  }) async {
    final bytes = await pdf.save();

    Directory? directory = await getExternalStorageDirectory();
    String newPath = "";

    List paths = directory!.path.split("/");
    for (int x = 1; x < paths.length; x++) {
      String folder = paths[x];
      if (folder != "Android") {
        newPath += "/$folder";
      } else {
        break;
      }
    }

    newPath += "/Download";
    directory = Directory(newPath);
    File file = File('${directory.path}/$name.pdf');

    await file.writeAsBytes(bytes);

    return file;
  }

  static Future openFile(File file) async {
    final url = file.path;
    log(url);

    final data = await OpenFile.open(url);
    log(data.message);
    log('message');
  }

  static Widget rowTxt(String text1, String text2, {double? size}) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Text(text1,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: size)),
        SizedBox(width: 5),
        Text(text2, style: TextStyle(fontSize: size)),
      ]);

  static generatePdf(
      {required List<Widget> header,
      required List<Widget> body,
      required List<Widget> footer,
      required String name}) async {
    final pdf = Document(version: PdfVersion.pdf_1_5);

    pdf.addPage(MultiPage(
      pageFormat: PdfPageFormat.a4.landscape,
      build: (context) => [...header, ...body, ...footer],
    ));
    final file = await saveDocument(name: name, pdf: pdf);
    openFile(file);
  }

  double calculateHeight(List<Widget> widgets) {
    // Calculate total height of widgets
    double totalHeight = 0;
    for (var widget in widgets) {
      totalHeight += widget.box?.height ?? 0;
    }
    return totalHeight;
  }
}
