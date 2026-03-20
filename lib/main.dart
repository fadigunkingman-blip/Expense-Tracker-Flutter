import 'package:expense_app/widgets/expenses.dart';
import 'package:flutter/material.dart';

const kIncomeColor = Color(0xFF52B788);
const kExpenseColor = Color(0xFFE76F51);
const kPrimaryGreen = Color(0xFF2D6A4F);
const kDarkGreen = Color(0xFF1B4332);
const kLightMint = Color(0xFFF0F7F4);

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          primary: kPrimaryGreen,
          onPrimary: Colors.white,
          secondary: kIncomeColor,
          onSecondary: Colors.white,
          surface: Colors.white,
          onSurface: Color(0xFF1A2E1A),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: kDarkGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.08),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryGreen,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: kPrimaryGreen),
        ),
        scaffoldBackgroundColor: kLightMint,
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: kDarkGreen,
          ),
        ),
      ),
      themeMode: ThemeMode.light,
      home: const Expenses(),
    ),
  );
}
