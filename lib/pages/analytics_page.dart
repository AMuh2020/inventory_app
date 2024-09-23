import 'dart:math';

import 'package:flutter/material.dart';
import 'package:inventory_app/components/date_paginator_menu.dart';
import 'package:inventory_app/pages/analysis_sales.dart';
import 'package:inventory_app/pages/analytics_product.dart';
import 'package:inventory_app/utils/graph_utils.dart' as graphUtils;
import 'package:graphic/graphic.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> with SingleTickerProviderStateMixin {

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        // navigation tabs
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Sales'),
            Tab(text: 'Products'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          AnalysisSales(),
          AnalyticsProduct(),
        ]
      
      )
    );
  }
}