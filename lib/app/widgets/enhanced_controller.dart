import 'dart:io';
import 'dart:math';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class EnhancedScrollController extends ScrollController {
  EnhancedScrollController([int extraScrollSpeed = 80]) {
    if (Platform.isWindows) {
      addListener(() {
        ScrollDirection scrollDirection = position.userScrollDirection;
        if (scrollDirection != ScrollDirection.idle) {
          double scrollEnd = offset +
              (scrollDirection == ScrollDirection.reverse
                  ? extraScrollSpeed
                  : -extraScrollSpeed);
          scrollEnd = min(position.maxScrollExtent,
              max(position.minScrollExtent, scrollEnd));
          jumpTo(scrollEnd);
        }
      });
    }
  }
}
