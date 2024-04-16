// Bu bir temel Flutter widget testidir.
//
// Testinizde bir widget ile etkileşim yapmak için flutter_test paketindeki WidgetTester
// aracını kullanın. Örneğin, dokunma ve kaydırma hareketleri gönderebilirsiniz.
// Ayrıca WidgetTester'ı kullanarak widget ağacındaki alt widget'ları bulabilir,
// metin okuyabilir ve widget özelliklerinin değerlerinin doğru olup olmadığını doğrulayabilirsiniz.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_api/main.dart';

void main() {
  testWidgets('Sayaç artırma testi', (WidgetTester tester) async {
    // Uygulamamızı oluşturalım ve bir çerçeve tetikleyelim.
    await tester.pumpWidget(MyApp());

    // Sayaç değerimizin 0'dan başladığını doğrulayalım.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Artı ikonuna dokunalım ve bir çerçeve tetikleyelim.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Sayaç değerimizin arttığını doğrulayalım.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
