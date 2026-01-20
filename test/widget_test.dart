// import 'package:flutter/material.dart';
// import 'package:flutter_ekg_detector/widgets/FloatingButtons.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:lucide_icons/lucide_icons.dart';

// void main() {
//   testWidgets(
//     'Floating menu shows ellipsis icon by default and expands on tap',
//     (WidgetTester tester) async {
//       bool scanPressed = false;

//       await tester.pumpWidget(
//         MaterialApp(
//           home: Scaffold(
//             body: Stack(
//               children: [
//                 GlassFloatingMenu(
//                   isOnHome: true,
//                   onScan: () {
//                     scanPressed = true;
//                   },
//                   onHome: () {},
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );

//       // ===== ASSERT DEFAULT ICON =====
//       expect(find.byIcon(LucideIcons.moreVertical), findsOneWidget);

//       // ===== TAP MAIN FAB =====
//       await tester.tap(find.byIcon(LucideIcons.moreVertical));
//       await tester.pumpAndSettle();

//       // ===== ASSERT SCAN MENU APPEARS =====
//       expect(find.text('Scan'), findsOneWidget);
//       expect(find.byIcon(LucideIcons.scan), findsOneWidget);

//       // ===== TAP SCAN MENU =====
//       await tester.tap(find.text('Scan'));
//       await tester.pumpAndSettle();

//       // ===== ASSERT CALLBACK =====
//       expect(scanPressed, isTrue);
//     },
//   );

//   testWidgets('Floating menu shows home icon when not on home screen', (
//     WidgetTester tester,
//   ) async {
//     await tester.pumpWidget(
//       MaterialApp(
//         home: Scaffold(
//           body: Stack(
//             children: [
//               GlassFloatingMenu(isOnHome: false, onScan: () {}, onHome: () {}),
//             ],
//           ),
//         ),
//       ),
//     );

//     // ===== ASSERT HOME ICON =====
//     expect(find.byIcon(LucideIcons.home), findsOneWidget);
//     expect(find.byIcon(LucideIcons.moreVertical), findsNothing);
//   });
// }
