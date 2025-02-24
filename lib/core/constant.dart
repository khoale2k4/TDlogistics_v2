import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

const Color mainColor = Color.fromARGB(255,238,1,51);
const Color secondColor = Color.fromARGB(255,120,188,68);

const double titleSize = 20;
const double contentSize = 18;

var ggApiKey = "";

var host = "";
var baseUrll = "";

Future<void> updateEnv() async {
  await dotenv.load(fileName: ".env");
  ggApiKey = dotenv.env['GG_API_KEY']!;
  host = dotenv.env['HOST']!;
  baseUrll = "${host}/v3";
}

const token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6ImM4MGZiYTNlLTJlNGItNDg1Yy1iMGYxLTFkYmJjYzg5ODFkNyIsInJvbGVzIjpbIkNVU1RPTUVSIl0sImlhdCI6MTczMjUyNDMwOCwiZXhwIjoxNzM2MTI0MzA4fQ.URFejsni08Fj5F96NlyNVIk5UY9Ye-7YlR52-rbl5Kc";