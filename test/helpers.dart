import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:expenzia/controllers/credit_controller.dart';
import 'package:expenzia/controllers/expense_controller.dart';
import 'package:expenzia/controllers/profile_controller.dart';
import 'package:expenzia/database/app_database.dart';
import 'package:expenzia/database/credit_database.dart';
import 'package:expenzia/database/expense_database.dart';
import 'package:expenzia/database/settings_database.dart';
import 'package:expenzia/main.dart';
import 'package:expenzia/repositories/credit_repository.dart';
import 'package:expenzia/repositories/expense_repository.dart';
import 'package:expenzia/repositories/profile_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Uses the real SQLite engine (through FFI) inside `flutter test`.
void useFfiDatabase() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfiNoIsolate;
}

/// Loads the fonts declared in pubspec.yaml so text renders with Inter
/// instead of the test font.
Future<void> loadAppFonts() async {
  final manifest =
      jsonDecode(await rootBundle.loadString('FontManifest.json'))
          as List<dynamic>;
  for (final entry in manifest) {
    final family = entry['family'] as String;
    final loader = FontLoader(family);
    for (final font in entry['fonts'] as List<dynamic>) {
      loader.addFont(rootBundle.load(font['asset'] as String));
    }
    await loader.load();
  }
}

/// iPhone 11 Pro Max size used by the Figma frames (414 x 896, 44 px status bar).
void usePhoneSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(414, 896);
  tester.view.devicePixelRatio = 1;
  tester.view.padding = const FakeViewPadding(top: 44);
  tester.view.viewPadding = const FakeViewPadding(top: 44);
  addTearDown(tester.view.reset);
}

class TestApp {
  TestApp(this.database)
    : expenses = ExpenseController(
        ExpenseRepository(ExpenseDatabase(database)),
      ),
      credits = CreditController(CreditRepository(CreditDatabase(database))),
      profile = ProfileController(
        ProfileRepository(SettingsDatabase(database)),
      );

  final AppDatabase database;
  final ExpenseController expenses;
  final CreditController credits;
  final ProfileController profile;

  final GlobalKey boundaryKey = GlobalKey();

  Future<void> loadAll() async {
    await expenses.loadExpenses();
    await credits.loadCredits();
    await profile.loadProfile();
  }

  Widget build(Widget home) {
    return RepaintBoundary(
      key: boundaryKey,
      child: ExpenziaApp(
        expenses: expenses,
        credits: credits,
        profile: profile,
        home: home,
      ),
    );
  }
}

/// Lets real async work (SQLite, image and SVG decoding) finish.
Future<void> settle(WidgetTester tester, {int rounds = 6}) async {
  for (var i = 0; i < rounds; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 60)),
    );
    await tester.pump(const Duration(milliseconds: 300));
  }
}

/// Makes sure every Image on screen is decoded before a screenshot.
Future<void> precacheImages(WidgetTester tester) async {
  await tester.runAsync(() async {
    for (final element in find.byType(Image).evaluate()) {
      final image = element.widget as Image;
      await precacheImage(image.image, element);
    }
  });
  await settle(tester);
}

/// Screenshots are only written when the tests are run with
/// `flutter test --dart-define=UPDATE_SCREENSHOTS=true`, so a normal
/// `flutter test` never overwrites the committed images.
const bool updateScreenshots = bool.fromEnvironment('UPDATE_SCREENSHOTS');

/// Renders the screen fully (images and SVGs decoded) and, when
/// [updateScreenshots] is true, saves it as a PNG at [path].
Future<void> saveScreenshot(
  WidgetTester tester,
  TestApp app,
  String path,
) async {
  await precacheImages(tester);
  if (!updateScreenshots) return;
  await tester.runAsync(() async {
    final boundary =
        app.boundaryKey.currentContext!.findRenderObject()
            as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 1);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final file = File(path);
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes!.buffer.asUint8List());
  });
}
