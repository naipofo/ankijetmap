import 'dart:convert';
import 'dart:io';

import 'package:html/parser.dart';
import 'package:http/http.dart' as http;

Future<void> dumpFlashcards(String url) async {
  var docstring = (await http.get(Uri.parse(url))).body;

  var doc = parse(docstring);

  var scriptSrc = doc.querySelector('script:not([src])')!.innerHtml;
  var jsonSrc = scriptSrc.substring(16, scriptSrc.length - 9);
  var json = jsonDecode(jsonSrc)['data'];
  var quizId = json['quizId'];
  var anwsers = json['quiz']['answers'];

  var svgSrc = doc.querySelector('svg[id^=svg]')!;

  var backgroundFn = 'jm$quizId-mask.svg';
  File(backgroundFn).writeAsString(
    '<?xml version="1.0" encoding="UTF-8"?>${svgSrc.outerHtml}',
  );

  var fullCsv = '';

  for (var el in anwsers) {
    var id = el['path'] as String;
    var name = el['display'] as String;
    var svgTemplate = svgSrc.clone(false);
    var anwserElement = svgSrc.querySelector('#$id')!;
    anwserElement.attributes['fill'] = '#0a0';
    anwserElement.attributes['xmlns'] = 'http://www.w3.org/2000/svg';
    svgTemplate.nodes.add(anwserElement);

    var fn = 'jm$quizId-$id.svg';
    File(fn).writeAsString(
      '<?xml version="1.0" encoding="UTF-8"?>${svgTemplate.outerHtml}',
    );
    fullCsv +=
        '"${name.replaceAll('"', '""')}","<img alt="""" src=""$fn""/>","<img alt="""" src=""$backgroundFn""/>"\n';
  }

  File('jmflashcards-$quizId.csv').writeAsString(fullCsv);
}
