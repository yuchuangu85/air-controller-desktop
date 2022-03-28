import 'package:cached_network_image/cached_network_image.dart';
import 'package:mobile_assistant_client/l10n/l10n.dart';
import 'package:mobile_assistant_client/model/ImageItem.dart';
import 'package:flutter/material.dart';
import 'dart:collection';
import 'package:intl/intl.dart';
import 'package:mobile_assistant_client/widget/simple_gesture_detector.dart';
import 'package:sticky_headers/sticky_headers.dart';

import '../model/arrangement_mode.dart';

/**
 * 图片瀑布流，用于首页不同类型排列图片列表展示.
 *
 * @author Scott Smith 2021/11/23 22:52
 */
class ImageFlowWidget extends StatelessWidget {
  ArrangementMode arrangeMode = ArrangementMode.grid;
  List<ImageItem> images = [];
  Function(ImageItem imageItem) onImageDoubleTap;
  Function(ImageItem imageItem) onImageSelected;
  Function() onOutsideTap;
  String rootUrl;
  Color backgroundColor;

  final _OUT_PADDING = 20.0;
  final _IMAGE_SPACE = 10.0;

  List<ImageItem> checkedImages = [];

  final _IMAGE_GRID_RADIUS_CHECKED = 5.0;
  final _IMAGE_GRID_BORDER_WIDTH_CHECKED = 3.4;

  final _IMAGE_GRID_RADIUS = 1.0;
  final _IMAGE_GRID_BORDER_WIDTH = 1.0;

  final _CHECKED_BORDER_COLOR = Color(0xff5d86ec);
  final _BORDER_COLOR = Color(0xffdedede);

  Function(PointerDownEvent event, ImageItem imageItem)? onPointerDown;

  ImageFlowWidget(
      {required this.arrangeMode,
      required this.images,
      required this.checkedImages,
      required this.onImageDoubleTap,
      required this.onImageSelected,
      required this.onOutsideTap,
      this.onPointerDown,
      required this.rootUrl,
      this.backgroundColor = Colors.white});

  Widget _createContent(BuildContext context, ArrangementMode arrangeMode) {
    if (arrangeMode == ArrangementMode.groupByDay) {
      return _createDailyContent(context);
    }

    if (arrangeMode == ArrangementMode.groupByMonth) {
      return _createMonthlyContent(context);
    }

    return _createGridContent();
  }

  Widget _createDailyContent(BuildContext context) {
    final map = LinkedHashMap<String, List<ImageItem>>();

    final timeFormat = context.l10n.yMdPattern;

    for (ImageItem imageItem in images) {
      int createTime = imageItem.createTime;

      final df = DateFormat(timeFormat);
      String createTimeStr =
          df.format(new DateTime.fromMillisecondsSinceEpoch(createTime));

      List<ImageItem>? images = map[createTimeStr];
      if (null == images) {
        images = <ImageItem>[];
        images.add(imageItem);
        map[createTimeStr] = images;
      } else {
        images.add(imageItem);
        map[createTimeStr] = images;
      }
    }

    List<String> keys = map.keys.toList();
    keys.sort((String a, String b) {
      final df = DateFormat(timeFormat);
      DateTime dateTimeA = df.parse(a);
      DateTime dateTimeB = df.parse(b);

      return dateTimeB.millisecondsSinceEpoch -
          dateTimeA.millisecondsSinceEpoch;
    });

    Map<String, List<ImageItem>> sortedMap = LinkedHashMap();

    keys.forEach((key) {
      sortedMap[key] = map[key]!;
    });

    return Container(
      color: backgroundColor,
      width: double.infinity,
      height: double.infinity,
      child: ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          final entry = sortedMap.entries.toList()[index];
          String dateTime = entry.key;
          List<ImageItem> images = entry.value;

          return Container(
              child: StickyHeader(
                  header: Container(
                    child: Text(dateTime,
                        style:
                            TextStyle(fontSize: 14, color: Color(0xff515151))),
                    color: Colors.white,
                  ),
                  content: Container(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 100,
                          crossAxisSpacing: _IMAGE_SPACE,
                          childAspectRatio: 1.0,
                          mainAxisSpacing: _IMAGE_SPACE),
                      itemBuilder: (BuildContext context, int index) {
                        ImageItem image = images[index];
                        return Listener(
                          child: Container(
                            child: SimpleGestureDetector(
                              child: Container(
                                  child: CachedNetworkImage(
                                    imageUrl: "$rootUrl/stream/image/thumbnail/${image.id}/200/200",
                                    fit: BoxFit.cover,
                                    width: 100,
                                    height: 100,
                                    memCacheWidth: 200,
                                    fadeOutDuration: Duration.zero,
                                    fadeInDuration: Duration.zero,
                                  ),
                                  decoration: BoxDecoration(
                                      border: new Border.all(
                                          color: _isChecked(image)
                                              ? _CHECKED_BORDER_COLOR
                                              : _BORDER_COLOR,
                                          width: _IMAGE_GRID_BORDER_WIDTH),
                                      borderRadius: new BorderRadius.all(
                                          Radius.circular(
                                              _IMAGE_GRID_RADIUS)))),
                              onTap: () {
                                onImageSelected.call(image);
                              },
                              onDoubleTap: () {
                                onImageDoubleTap.call(image);
                              },
                            ),
                            decoration: BoxDecoration(
                                border: new Border.all(
                                    color: _isChecked(image)
                                        ? _CHECKED_BORDER_COLOR
                                        : Colors.transparent,
                                    width: _IMAGE_GRID_BORDER_WIDTH_CHECKED - 1.5),
                                borderRadius: new BorderRadius.all(
                                    Radius.circular(
                                        _IMAGE_GRID_RADIUS_CHECKED / 2))),
                          ),
                          onPointerDown: (event) {
                            onPointerDown?.call(event, image);
                          },
                        );
                      },
                      itemCount: images.length,
                      shrinkWrap: true,
                      primary: false,
                    ),
                    color: Colors.white,
                    margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                  )),
              color: Colors.white,
              padding: EdgeInsets.fromLTRB(20, 15, 20, 0));
        },
        itemCount: map.length,
        primary: false,
      ),
    );
  }

  Widget _createMonthlyContent(BuildContext context) {
    final map = LinkedHashMap<String, List<ImageItem>>();

    final timeFormat = context.l10n.yMPattern;

    for (ImageItem imageItem in images) {
      int createTime = imageItem.createTime;

      final df = DateFormat(timeFormat);
      String createTimeStr =
          df.format(new DateTime.fromMillisecondsSinceEpoch(createTime));

      List<ImageItem>? images = map[createTimeStr];
      if (null == images) {
        images = <ImageItem>[];
        images.add(imageItem);
        map[createTimeStr] = images;
      } else {
        images.add(imageItem);
        map[createTimeStr] = images;
      }
    }

    List<String> keys = map.keys.toList();
    keys.sort((String a, String b) {
      final df = DateFormat(timeFormat);
      DateTime dateTimeA = df.parse(a);
      DateTime dateTimeB = df.parse(b);

      return dateTimeB.millisecondsSinceEpoch -
          dateTimeA.millisecondsSinceEpoch;
    });

    Map<String, List<ImageItem>> sortedMap = LinkedHashMap();

    keys.forEach((key) {
      sortedMap[key] = map[key]!;
    });

    return Container(
      child: ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          final entry = sortedMap.entries.toList()[index];
          String dateTime = entry.key;
          List<ImageItem> images = entry.value;

          return Container(
              child: StickyHeader(
                  header: Container(
                    child: Text(dateTime,
                        style:
                            TextStyle(fontSize: 14, color: Color(0xff515151))),
                    color: Colors.white,
                  ),
                  content: Container(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 80,
                          crossAxisSpacing: _IMAGE_SPACE,
                          childAspectRatio: 1.0,
                          mainAxisSpacing: _IMAGE_SPACE),
                      itemBuilder: (BuildContext context, int index) {
                        ImageItem image = images[index];
                        return Listener(
                          child: Container(
                            child: SimpleGestureDetector(
                              child: Container(
                                  child: CachedNetworkImage(
                                    imageUrl:
                                        "$rootUrl/stream/image/thumbnail/${image.id}/200/200"
                                            .replaceAll(
                                                "storage/emulated/0/", ""),
                                    fit: BoxFit.cover,
                                    width: 80,
                                    height: 80,
                                    memCacheWidth: 200,
                                    fadeOutDuration: Duration.zero,
                                    fadeInDuration: Duration.zero,
                                  ),
                                  decoration: BoxDecoration(
                                      border: new Border.all(
                                          color: _isChecked(image)
                                              ? _CHECKED_BORDER_COLOR
                                              : _BORDER_COLOR,
                                          width: _IMAGE_GRID_BORDER_WIDTH),
                                      borderRadius: new BorderRadius.all(
                                          Radius.circular(
                                              _IMAGE_GRID_RADIUS)))),
                              onTap: () {
                                onImageSelected.call(image);
                              },
                              onDoubleTap: () {
                                onImageDoubleTap.call(image);
                              },
                            ),
                            decoration: BoxDecoration(
                                border: new Border.all(
                                    color: _isChecked(image)
                                        ? Color(0xff5d86ec)
                                        : Colors.transparent,
                                    width: _IMAGE_GRID_BORDER_WIDTH_CHECKED - 2.0),
                                borderRadius: new BorderRadius.all(
                                    Radius.circular(
                                        _IMAGE_GRID_RADIUS_CHECKED / 3))),
                          ),
                          onPointerDown: (event) {
                            onPointerDown?.call(event, image);
                          },
                        );
                      },
                      itemCount: images.length,
                      shrinkWrap: true,
                      primary: false,
                    ),
                    color: Colors.white,
                    margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                  )),
              color: Colors.white,
              padding: EdgeInsets.fromLTRB(20, 15, 20, 0));
        },
        itemCount: map.length,
        primary: false,
      ),
      width: double.infinity,
      height: double.infinity,
      color: backgroundColor,
    );
  }

  Widget _createGridContent() {
    return Container(
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 160,
            crossAxisSpacing: _IMAGE_SPACE,
            childAspectRatio: 1.0,
            mainAxisSpacing: _IMAGE_SPACE),
        itemBuilder: (BuildContext context, int index) {
          ImageItem image = images[index];
          return Listener(
            child: Container(
              child: SimpleGestureDetector(
                child: Container(
                    child: CachedNetworkImage(
                      imageUrl:
                          "$rootUrl/stream/image/thumbnail/${image.id}/400/400"
                              .replaceAll("storage/emulated/0/", ""),
                      fit: BoxFit.cover,
                      width: 160,
                      height: 160,
                      memCacheWidth: 400,
                      fadeOutDuration: Duration.zero,
                      fadeInDuration: Duration.zero,
                    ),
                    decoration: BoxDecoration(
                        border: new Border.all(
                            color: _isChecked(image)
                                ? _CHECKED_BORDER_COLOR
                                : _BORDER_COLOR,
                            width: _IMAGE_GRID_BORDER_WIDTH),
                        borderRadius: new BorderRadius.all(
                            Radius.circular(_IMAGE_GRID_RADIUS)))),
                onTap: () {
                  onImageSelected.call(image);
                },
                onDoubleTap: () {
                  onImageDoubleTap.call(image);
                },
              ),
              decoration: BoxDecoration(
                  border: new Border.all(
                      color: _isChecked(image)
                          ? _CHECKED_BORDER_COLOR
                          : Colors.transparent,
                      width: _IMAGE_GRID_BORDER_WIDTH_CHECKED),
                  borderRadius: new BorderRadius.all(
                      Radius.circular(_IMAGE_GRID_RADIUS_CHECKED))),
            ),
            onPointerDown: (event) {
              onPointerDown?.call(event, image);
            },
          );
        },
        itemCount: images.length,
        shrinkWrap: true,
        primary: false,
      ),
      color: backgroundColor,
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.fromLTRB(_OUT_PADDING, _OUT_PADDING, _OUT_PADDING, 0),
    );
  }

  bool _isChecked(ImageItem image) {
    return checkedImages.contains(image);
  }

  @override
  Widget build(BuildContext context) {
    Widget widget = _createContent(context, arrangeMode);
    return Listener(
      child: GestureDetector(
        child: widget,
        onTap: () {
          onOutsideTap.call();
        },
      ),
      onPointerDown: (event) {
        // onOutsideTap.call();
      },
    );
  }
}
