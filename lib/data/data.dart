import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

List<Map<String, dynamic>> myTransactionData = [
  { 
    'icon':  CupertinoIcons.shopping_cart,
    'color': Colors.blue,
    'name':  "Shopping",
    'totalAmount': '9999',
    'date': 'Today',
  },
  { 
    'icon':  CupertinoIcons.tree,
    'color': Colors.green,
    'name':  "Groceries",
    'totalAmount': '8888',
    'date': 'Today',
  },
  { 
    'icon':  CupertinoIcons.money_dollar_circle_fill,
    'color': Colors.yellowAccent,
    'name':  "Income",
    'totalAmount': '1111',
    'date': 'Today',
  }
];