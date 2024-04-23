import 'dart:developer';
import 'dart:io';
import 'package:jetpack/constants/style.dart';
import 'package:jetpack/models/runsheet.dart';
import 'package:jetpack/services/util/logic_service.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/widgets.dart';

class PdfService {
  static Future<void> generateMagnifest() async {}
  static Future<void> generateRunsheet(RunsheetPdf invoice) async {
    await requestPermission();
    final pdf = Document();

    pdf.addPage(Page(
        pageFormat: PdfPageFormat
            .a4.landscape, //const PdfPageFormat(29.7, 21, marginAll: 15),
        // orientation: PageOrientation.landscape,
        build: (context) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 1 * PdfPageFormat.cm),
                Center(
                  child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 5),
                      decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(4)),
                      child: Text(
                          'Ordre de mission / bon de livraison n ${invoice.id}'
                              .toUpperCase(),
                          style: const TextStyle(fontSize: 20))),
                ),
                SizedBox(height: 2 * PdfPageFormat.cm),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
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
                    "Nombre total des colis:", invoice.colis.length.toString()),
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
                  headerDecoration:
                      const BoxDecoration(color: PdfColors.grey300),
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
            )
        ));
    final file = await saveDocument(name: "Runsheet ${invoice.date}", pdf: pdf);
    openFile(file);
  }

  static Future<void> generateDayReport() async {}
  static Future<void> generateWeekReport() async {}
  static Future<void> generateReturnColis() async {}

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
}
