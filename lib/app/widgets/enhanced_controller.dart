import 'dart:io';
import 'dart:math';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class EnhancedScrollController extends ScrollController {
  ScrollController() {
    if (Platform.isWindows) {
      addListener(() {
        ScrollDirection scrollDirection = position.userScrollDirection;
        if (scrollDirection != ScrollDirection.idle) {
          double scrollEnd =
              offset + (scrollDirection == ScrollDirection.reverse ? 80 : -80);
          scrollEnd = min(position.maxScrollExtent,
              max(position.minScrollExtent, scrollEnd));
          jumpTo(scrollEnd);
        }
      });
    }
  }
}
