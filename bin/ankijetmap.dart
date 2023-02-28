import 'package:ankijetmap/ankijetmap.dart' as ankijetmap;

Future<void> main(List<String> arguments) async {
  if (arguments.length == 2 && arguments[0] == 'dump') {
    print('started generating');
    await ankijetmap.dumpFlashcards(arguments[1]);
    print('finished generating!');
  } else {
    print('usage: ankijetmaps dump <url>');
  }
}
