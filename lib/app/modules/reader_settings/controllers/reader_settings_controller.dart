import 'package:get/get.dart';

import '../../../core/values/db_keys.dart';
import '../../../data/enums/reader_mode.dart';
import '../../../data/enums/reader_navigation_layout.dart';
import '../../../data/services/local_storage_service.dart';

class ReaderSettingsController extends GetxController {
  final LocalStorageService localStorageService =
      Get.find<LocalStorageService>();

  final Rx<ReaderMode> readerMode = ReaderMode.webtoon.obs;
  final Rx<ReaderNavigationLayout> readerNavigationLayout =
      ReaderNavigationLayout.disabled.obs;
  final RxBool readerNavigationLayoutInvert = false.obs;
  final RxBool readerPrefetchEntireChapterImage = false.obs;
  final RxBool readerPrefetchNextChapterImage = false.obs;
  @override
  void onInit() {
    readerMode.value = localStorageService.readerMode;
    readerNavigationLayout.value = localStorageService.readerNavigationLayout;
    readerNavigationLayoutInvert.value =
        localStorageService.readerNavigationLayoutInvert;
    readerPrefetchEntireChapterImage.value =
        localStorageService.readerPrefetchEntireChapterImage;
    readerPrefetchNextChapterImage.value =
        localStorageService.readerPrefetchNextChapterImage;
    localStorageService.box.listenKey(
      readerModeKey,
      (value) => readerMode.value = readerModeFromString(value),
    );
    localStorageService.box.listenKey(
      readerNavigationLayoutKey,
      (value) => readerNavigationLayout.value =
          readerNavigationLayoutFromString(value),
    );
    localStorageService.box.listenKey(
      readerNavigationLayoutInvertKey,
      (value) => readerNavigationLayoutInvert.value = value,
    );
    localStorageService.box.listenKey(
      readerPrefetchEntireChapterImageKey,
      (value) => readerPrefetchEntireChapterImage.value = value,
    );
    localStorageService.box.listenKey(
      readerPrefetchNextChapterImageKey,
      (value) => readerPrefetchNextChapterImage.value = value,
    );
    super.onInit();
  }

  // @override
  // void onReady() {
  //   super.onReady();
  // }

  // @override
  // void onClose() {}
}
