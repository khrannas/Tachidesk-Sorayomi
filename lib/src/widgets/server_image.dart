// Copyright (c) 2022 Contributors to the Suwayomi project
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_network_image_platform_interface/cached_network_image_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../constants/app_sizes.dart';
import '../constants/endpoints.dart';
import '../constants/enum.dart';
import '../features/settings/presentation/server/widget/credential_popup/credentials_popup.dart';
import '../features/settings/widgets/server_port_tile/server_port_tile.dart';
import '../features/settings/widgets/server_url_tile/server_url_tile.dart';
import '../global_providers/global_providers.dart';
import '../utils/extensions/custom_extensions.dart';
import '../utils/hooks/hook_primitives_wrapper.dart';
import '../utils/misc/app_utils.dart';

class ServerImage extends HookConsumerWidget {
  const ServerImage({
    super.key,
    required this.imageUrl,
    this.size,
    this.fit,
    this.appendApiToUrl = false,
    this.progressIndicatorBuilder,
    this.wrapper,
    this.showReloadButton = false,
  });

  final String imageUrl;
  final Size? size;
  final BoxFit? fit;
  final bool appendApiToUrl;
  final Widget Function(BuildContext, String, DownloadProgress)?
      progressIndicatorBuilder;
  final Widget Function(Widget child)? wrapper;
  final bool showReloadButton;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (key, setKey) = useStateRecord(UniqueKey());
    // Providers
    final authType = ref.watch(authTypeKeyProvider);
    final basicToken = ref.watch(credentialsProvider);

    final baseApi = "${Endpoints.baseApi(
      baseUrl: ref.watch(serverUrlProvider),
      port: ref.watch(serverPortProvider),
      addPort: ref.watch(serverPortToggleProvider).ifNull(),
      appendApiToUrl: appendApiToUrl,
    )}"
        "$imageUrl";

    final Map<String, String>? httpHeaders =
        (authType == AuthType.basic && basicToken != null)
            ? ({"Authorization": basicToken})
            : null;

    final ImageRenderMethodForWeb renderMethod;
    if (authType == AuthType.basic && basicToken != null) {
      renderMethod = ImageRenderMethodForWeb.HttpGet;
    } else {
      renderMethod = ImageRenderMethodForWeb.HtmlImage;
    }

    final finalProgressIndicatorBuilder = progressIndicatorBuilder != null
        ? (BuildContext context, String url, DownloadProgress progress) =>
            AppUtils.wrapIf(
              wrapper,
              progressIndicatorBuilder!(context, url, progress),
            )
        : null;

    Widget errorWidget(BuildContext context, String error, stackTrace) {
      if (showReloadButton) {
        return AppUtils.wrapIf(
          wrapper,
          Padding(
            padding: KEdgeInsets.a8.size,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.broken_image_rounded,
                    color: Colors.grey,
                  ),
                  KSizedBox.h32.size,
                  TextButton(
                    onPressed: () {
                      setKey(UniqueKey());
                    },
                    child: Text(context.l10n!.reload),
                  ),
                ],
              ),
            ),
          ),
        );
      } else {
        return AppUtils.wrapIf(
          wrapper,
          const Icon(
            Icons.broken_image_rounded,
            color: Colors.grey,
          ),
        );
      }
    }

    return CachedNetworkImage(
      key: key,
      imageUrl: baseApi,
      height: size?.height,
      cacheManager: DefaultCacheManager(),
      httpHeaders: httpHeaders,
      width: size?.width,
      fit: fit ?? BoxFit.cover,
      imageRenderMethodForWeb: renderMethod,
      progressIndicatorBuilder: finalProgressIndicatorBuilder,
      errorWidget: errorWidget,
    );
  }
}

class ServerImageWithCpi extends StatelessWidget {
  const ServerImageWithCpi({
    super.key,
    required this.url,
    required this.outerSize,
    required this.innerSize,
    required this.isLoading,
  });
  final bool isLoading;
  final Size outerSize;
  final Size innerSize;
  final String url;
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox.fromSize(
        size: outerSize,
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            const Padding(
              padding: EdgeInsets.all(4.0),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            ServerImage(
              imageUrl: url,
              size: innerSize,
            )
          ],
        ),
      );
    } else {
      return ServerImage(imageUrl: url, size: outerSize);
    }
  }
}
