import 'package:flutter/material.dart';
import 'ui/dashboard.dart';

void main() => runApp(const UmarTownPlannerApp());

class UmarTownPlannerApp extends StatelessWidget {
  const UmarTownPlannerApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'UMAR Town Planner',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: kGreen, secondary: kGold),
          scaffoldBackgroundColor: const Color(0xFFF4F6F3),
        ),
        home: const Shell(),
      );
}
