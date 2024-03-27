import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/theme_notifier.dart';

class DefaultScreen extends StatelessWidget {
  final String title;
  final bool appbar;
  final bool leading;
  const DefaultScreen(
      {super.key, this.title = "", this.leading = true, this.appbar = true});

  @override
  Widget build(BuildContext context) {
    var style = context.watch<ThemeNotifier>();
    return Scaffold(
      // appBar: appbar ? appBar(title, leading: leading) : null,
      backgroundColor: style.bgColor,
      body: Center(
          child: Text(
        title,
        style: style.text18,
      )),
    );
  }
}

// Widget loader() => const SizedBox(
//       height: 50,
//       width: 50,
//       child: CircularProgressIndicator(
//         color: blue,
//         strokeWidth: 2,
//       ),
//     );
