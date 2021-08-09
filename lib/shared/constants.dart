import 'package:flutter/material.dart';

const textInputDecoration = InputDecoration(
  labelStyle: TextStyle(color: Colors.white),
  enabledBorder: OutlineInputBorder(
    borderRadius: const BorderRadius.all(
          const Radius.circular(24.0),),
    borderSide: BorderSide(color: Colors.white, width: 1.0)
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: const BorderRadius.all(
          const Radius.circular(24.0),),
    borderSide: BorderSide(color: Color(0xFFFF0889B6), width: 2.0)
  ),
);