import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:get/get.dart';

import '../../../../generated/locales.g.dart';
import '../controllers/search_source_controller.dart';

class SearchTextField extends StatelessWidget {
  const SearchTextField({
    Key? key,
    required this.controller,
    this.width,
  }) : super(key: key);

  final SearchSourceController controller;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final isWebMobile = kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.android);
    return Container(
      padding: EdgeInsets.all(8.0),
      width: width,
      child: TextField(
        controller: controller.textEditingController,
        autofocus: !isWebMobile,
        onEditingComplete: () => controller.pagingController.refresh(),
        decoration: InputDecoration(
          suffixIcon: IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              controller.pagingController;
            },
          ),
          border: OutlineInputBorder(),
          hintText: LocaleKeys.searchManga_searchManga.tr,
          contentPadding: const EdgeInsets.all(8.0),
        ),
      ),
    );
  }
}
