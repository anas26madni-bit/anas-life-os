import 'package:anas_life_os/features/more/presentation/pages/more_page.dart';
import 'package:anas_life_os/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final locale in const [Locale('en'), Locale('ur')]) {
    for (final size in const [Size(320, 568), Size(640, 360)]) {
      testWidgets(
        'More screen ${locale.languageCode} ${size.width}x${size.height} at 200% text',
        (tester) async {
          await tester.binding.setSurfaceSize(size);
          addTearDown(() => tester.binding.setSurfaceSize(null));
          await tester.pumpWidget(
            MaterialApp(
              locale: locale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: const TextScaler.linear(2),
                  disableAnimations: true,
                ),
                child: child!,
              ),
              home: const MorePage(),
            ),
          );
          await tester.pumpAndSettle();

          expect(find.byType(MorePage), findsOneWidget);
          expect(tester.takeException(), isNull);
          expect(
            Directionality.of(tester.element(find.byType(MorePage))),
            locale.languageCode == 'ur'
                ? TextDirection.rtl
                : TextDirection.ltr,
          );
          for (final tile in find.byType(ListTile).evaluate()) {
            expect(tester.getSize(find.byWidget(tile.widget)).height, greaterThanOrEqualTo(48));
          }
        },
      );
    }
  }
}
