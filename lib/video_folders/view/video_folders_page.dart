import 'dart:io';

import 'package:air_controller/ext/filex.dart';
import 'package:air_controller/ext/pointer_down_event_x.dart';
import 'package:air_controller/ext/string-ext.dart';
import 'package:air_controller/l10n/l10n.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../home/bloc/home_bloc.dart';
import '../../model/video_folder_item.dart';
import '../../model/video_item.dart';
import '../../model/video_order_type.dart';
import '../../network/device_connection_manager.dart';
import '../../repository/file_repository.dart';
import '../../repository/video_repository.dart';
import '../../util/common_util.dart';
import '../../util/context_menu_helper.dart';
import '../../util/sound_effect.dart';
import '../../util/system_app_launcher.dart';
import '../../video_home/bloc/video_home_bloc.dart';
import '../../widget/progress_indictor_dialog.dart';
import '../../widget/simple_gesture_detector.dart';
import '../../widget/video_flow_widget.dart';
import '../bloc/video_folders_bloc.dart';

class VideoFoldersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<VideoFoldersBloc>(
      create: (context) => VideoFoldersBloc(
          videoRepository: context.read<VideoRepository>(),
          fileRepository: context.read<FileRepository>())
        ..add(VideoFoldersSubscriptionRequested()),
      child: VideoFoldersView(),
    );
  }
}

class VideoFoldersView extends StatefulWidget {
  @override
  State<VideoFoldersView> createState() => _VideoFoldersViewState();
}

class _VideoFoldersViewState extends State<VideoFoldersView> {
  FocusNode? _rootFocusNode;

  bool _isControlPressed = false;
  bool _isShiftPressed = false;

  ProgressIndicatorDialog? _progressIndicatorDialog;

  final _OUT_PADDING = 20.0;
  final _IMAGE_SPACE = 15.0;

  final _URL_SERVER = DeviceConnectionManager.instance.rootURL;

  @override
  Widget build(BuildContext context) {
    const color = Color(0xff85a8d0);
    const spinKit = SpinKitCircle(color: color, size: 60.0);

    List<VideoFolderItem> videoFolders =
        context.select((VideoFoldersBloc bloc) => bloc.state.videoFolders);
    List<VideoFolderItem> checkedVideoFolders = context
        .select((VideoFoldersBloc bloc) => bloc.state.checkedVideoFolders);

    VideoFoldersStatus status =
        context.select((VideoFoldersBloc bloc) => bloc.state.status);
    LoadVideosInFolderStatusUnit loadVideosInFolderStatus = context
        .select((VideoFoldersBloc bloc) => bloc.state.loadVideosInFolderStatus);
    VideoFolderOpenStatus videoFolderOpenStatus = context
        .select((VideoFoldersBloc bloc) => bloc.state.videoFolderOpenStatus);
    VideoOrderType orderType =
        context.select((VideoHomeBloc bloc) => bloc.state.orderType);

    final homeTab = context.select((HomeBloc bloc) => bloc.state.tab);
    final currentTab = context.select((VideoHomeBloc bloc) => bloc.state.tab);

    _rootFocusNode = FocusNode();
    _rootFocusNode?.canRequestFocus = true;

    if (homeTab == HomeTab.video && currentTab == VideoHomeTab.videoFolders) {
      _rootFocusNode?.requestFocus();
    }

    Widget content = _createGridContent(videoFolders, checkedVideoFolders);

    Widget videosInFolderWidget = _createVideosWidget(
        context,
        loadVideosInFolderStatus.videos,
        loadVideosInFolderStatus.checkedVideos,
        orderType);

    return Scaffold(
      body: MultiBlocListener(
        listeners: [
          BlocListener<VideoFoldersBloc, VideoFoldersState>(
              listener: (context, state) {
                dynamic target = state.openMenuStatus.target;

                if (target is VideoFolderItem) {
                  _openMenuForFolders(
                      pageContext: context,
                      position: state.openMenuStatus.position!,
                      folders: state.videoFolders,
                      checkedFolders: state.checkedVideoFolders,
                      current: state.openMenuStatus.target!);
                } else {
                  _openMenuForVideos(
                      pageContext: context,
                      position: state.openMenuStatus.position!,
                      videos: state.loadVideosInFolderStatus.videos,
                      checkedVideos:
                          state.loadVideosInFolderStatus.checkedVideos,
                      current: state.openMenuStatus.target!);
                }
              },
              listenWhen: (previous, current) =>
                  previous.openMenuStatus != current.openMenuStatus &&
                  current.openMenuStatus.isOpened),
          BlocListener<VideoFoldersBloc, VideoFoldersState>(
              listener: (context, state) {
                if (state.deleteStatus == VideoFoldersDeleteStatus.loading) {
                  SmartDialog.showLoading();
                }

                if (state.deleteStatus == VideoFoldersDeleteStatus.failure) {
                  SmartDialog.dismiss();

                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(SnackBar(
                        content: Text(state.failureReason ??
                            context.l10n.deleteFilesFailure)));
                }

                if (state.deleteStatus == VideoFoldersDeleteStatus.success) {
                  SmartDialog.dismiss();
                }
              },
              listenWhen: (previous, current) =>
                  previous.deleteStatus != current.deleteStatus),
          BlocListener<VideoFoldersBloc, VideoFoldersState>(
            listener: (context, state) {
              if (state.copyStatus.status == VideoFoldersCopyStatus.start) {
                _showDownloadProgressDialog(context, state.copyStatus.fileType);
              }

              if (state.copyStatus.status == VideoFoldersCopyStatus.copying) {
                if (_progressIndicatorDialog?.isShowing == true) {
                  int current = state.copyStatus.current;
                  int total = state.copyStatus.total;

                  if (current > 0) {
                    String title = context.l10n.exporting;

                    if (state.copyStatus.fileType ==
                        VideoFoldersFileType.folder) {
                      List<VideoFolderItem> checkedVideoFolders =
                          state.checkedVideoFolders;

                      if (checkedVideoFolders.length == 1) {
                        String name = checkedVideoFolders.single.name;

                        title = context.l10n.placeholderExporting
                            .replaceFirst("%s", name);
                      }

                      if (checkedVideoFolders.length > 1) {
                        String itemStr = context.l10n.placeHolderItemCount03
                            .replaceFirst(
                                "%d", "${checkedVideoFolders.length}");
                        title = context.l10n.placeholderExporting
                            .replaceFirst("%s", itemStr);
                      }
                    } else {
                      List<VideoItem> checkedVideos =
                          state.loadVideosInFolderStatus.checkedVideos;

                      if (checkedVideos.length == 1) {
                        String name = checkedVideos.single.name;

                        title = context.l10n.placeholderExporting
                            .replaceFirst("%s", name);
                      }

                      if (checkedVideos.length > 1) {
                        String itemStr = context.l10n.placeHolderItemCount03
                            .replaceFirst("%d", "${checkedVideos.length}");
                        title = context.l10n.placeholderExporting
                            .replaceFirst("%s", itemStr);
                      }
                    }

                    _progressIndicatorDialog?.title = title;
                  }

                  _progressIndicatorDialog?.subtitle =
                      "${CommonUtil.convertToReadableSize(current)}/${CommonUtil.convertToReadableSize(total)}";
                  _progressIndicatorDialog?.updateProgress(current / total);
                }
              }

              if (state.copyStatus.status == VideoFoldersCopyStatus.failure) {
                _progressIndicatorDialog?.dismiss();

                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(
                      content: Text(state.copyStatus.error ??
                          context.l10n.copyFileFailure)));
              }

              if (state.copyStatus.status == VideoFoldersCopyStatus.success) {
                _progressIndicatorDialog?.dismiss();
              }
            },
            listenWhen: (previous, current) =>
                previous.copyStatus != current.copyStatus &&
                current.copyStatus.status != VideoFoldersCopyStatus.initial,
          ),
          BlocListener<VideoFoldersBloc, VideoFoldersState>(
            listener: (context, state) {
              context.read<VideoHomeBloc>().add(VideoHomeBackVisibilityChanged(
                  state.videoFolderOpenStatus.isOpened));
              context.read<VideoHomeBloc>().add(
                  VideoHomeOderTypeVisibilityChanged(
                      state.videoFolderOpenStatus.isOpened));

              if (state.videoFolderOpenStatus.isOpened) {
                List<VideoItem> videos = state.loadVideosInFolderStatus.videos;
                List<VideoItem> checkedVideos =
                    state.loadVideosInFolderStatus.checkedVideos;

                context.read<VideoHomeBloc>().add(VideoHomeItemCountChanged(
                    VideoHomeItemCount(videos.length, checkedVideos.length)));
                context.read<VideoHomeBloc>().add(
                    VideoHomeDeleteStatusChanged(checkedVideos.length > 0));
              } else {
                List<VideoFolderItem> videoFolders = state.videoFolders;
                List<VideoFolderItem> checkedVideoFolders =
                    state.checkedVideoFolders;

                context.read<VideoHomeBloc>().add(VideoHomeItemCountChanged(
                    VideoHomeItemCount(
                        videoFolders.length, checkedVideoFolders.length)));
                context.read<VideoHomeBloc>().add(VideoHomeDeleteStatusChanged(
                    checkedVideoFolders.length > 0));
              }
            },
            listenWhen: (previous, current) =>
                previous.videoFolderOpenStatus.isOpened !=
                current.videoFolderOpenStatus.isOpened,
          ),
          BlocListener<VideoHomeBloc, VideoHomeState>(
            listener: (context, state) {
              context.read<VideoFoldersBloc>().add(
                  VideoFoldersOpenStatusChanged(
                      VideoFolderOpenStatus(isOpened: false)));
              context.read<VideoHomeBloc>().add(
                  VideoHomeBackTapStatusChanged(VideoHomeBackTapStatus.none));
            },
            listenWhen: (previous, current) =>
                previous.backTapStatus != current.backTapStatus &&
                current.backTapStatus == VideoHomeBackTapStatus.tap,
          ),
          BlocListener<VideoHomeBloc, VideoHomeState>(
              listener: (context, state) {
                bool isFolderOpened = context
                    .read<VideoFoldersBloc>()
                    .state
                    .videoFolderOpenStatus
                    .isOpened;
                context
                    .read<VideoHomeBloc>()
                    .add(VideoHomeOderTypeVisibilityChanged(isFolderOpened));
                context
                    .read<VideoHomeBloc>()
                    .add(VideoHomeBackVisibilityChanged(isFolderOpened));

                if (isFolderOpened) {
                  List<VideoItem> videos = context
                      .read<VideoFoldersBloc>()
                      .state
                      .loadVideosInFolderStatus
                      .videos;
                  List<VideoItem> checkedVideos = context
                      .read<VideoFoldersBloc>()
                      .state
                      .loadVideosInFolderStatus
                      .checkedVideos;

                  context.read<VideoHomeBloc>().add(VideoHomeItemCountChanged(
                      VideoHomeItemCount(videos.length, checkedVideos.length)));

                  context.read<VideoHomeBloc>().add(
                      VideoHomeDeleteStatusChanged(checkedVideos.length > 0));
                } else {
                  List<VideoFolderItem> videoFolders =
                      context.read<VideoFoldersBloc>().state.videoFolders;
                  List<VideoFolderItem> checkedVideoFolders = context
                      .read<VideoFoldersBloc>()
                      .state
                      .checkedVideoFolders;

                  context.read<VideoHomeBloc>().add(VideoHomeItemCountChanged(
                      VideoHomeItemCount(
                          videoFolders.length, checkedVideoFolders.length)));

                  context.read<VideoHomeBloc>().add(
                      VideoHomeDeleteStatusChanged(
                          checkedVideoFolders.length > 0));
                }
              },
              listenWhen: (previous, current) =>
                  previous.tab != current.tab &&
                  current.tab == VideoHomeTab.videoFolders),
          BlocListener<VideoFoldersBloc, VideoFoldersState>(
              listener: (context, state) {
                VideoHomeTab currentTab =
                    context.read<VideoHomeBloc>().state.tab;

                if (currentTab == VideoHomeTab.videoFolders) {
                  if (state.videoFolderOpenStatus.isOpened) {
                    List<VideoItem> videos =
                        state.loadVideosInFolderStatus.videos;
                    List<VideoItem> checkedVideos =
                        state.loadVideosInFolderStatus.checkedVideos;

                    context.read<VideoHomeBloc>().add(VideoHomeItemCountChanged(
                        VideoHomeItemCount(
                            videos.length, checkedVideos.length)));

                    context.read<VideoHomeBloc>().add(
                        VideoHomeDeleteStatusChanged(checkedVideos.length > 0));
                  } else {
                    List<VideoFolderItem> videoFolders = state.videoFolders;
                    List<VideoFolderItem> checkedVideoFolders =
                        state.checkedVideoFolders;

                    context.read<VideoHomeBloc>().add(VideoHomeItemCountChanged(
                        VideoHomeItemCount(
                            videoFolders.length, checkedVideoFolders.length)));

                    context.read<VideoHomeBloc>().add(
                        VideoHomeDeleteStatusChanged(
                            checkedVideoFolders.length > 0));
                  }
                }
              },
              listenWhen: (previous, current) =>
                  _needListenItemCountChange(previous, current)),
          BlocListener<VideoHomeBloc, VideoHomeState>(
              listener: (context, state) {
                if (state.tab == VideoHomeTab.videoFolders) {
                  bool isFolderOpened = context
                      .read<VideoFoldersBloc>()
                      .state
                      .videoFolderOpenStatus
                      .isOpened;

                  if (isFolderOpened) {
                    _tryToDeleteVideos(
                        context,
                        context
                            .read<VideoFoldersBloc>()
                            .state
                            .loadVideosInFolderStatus
                            .checkedVideos);
                  } else {
                    _tryToDeleteVideoFolders(
                        context,
                        context
                            .read<VideoFoldersBloc>()
                            .state
                            .checkedVideoFolders);
                  }
                }
              },
              listenWhen: (previous, current) =>
                  previous.deleteTapStatus != current.deleteTapStatus &&
                  current.deleteTapStatus == VideoHomeDeleteTapStatus.tap),
          BlocListener<VideoFoldersBloc, VideoFoldersState>(
              listener: (context, state) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(
                      content: Text(state.copyStatus.error ??
                          context.l10n.loadVideoFoldersFailure)));
              },
              listenWhen: (previous, current) =>
                  previous.status != current.status &&
                  current.status == VideoFoldersStatus.failure),
          BlocListener<VideoFoldersBloc, VideoFoldersState>(
            listener: (context, state) {
              if (state.uploadStatus.status == VideoFoldersUploadStatus.start) {
                context.read<HomeBloc>().add(HomeProgressIndicatorStatusChanged(
                    HomeLinearProgressIndicatorStatus(visible: true)));
              }

              if (state.uploadStatus.status ==
                  VideoFoldersUploadStatus.uploading) {
                context.read<HomeBloc>().add(HomeProgressIndicatorStatusChanged(
                        HomeLinearProgressIndicatorStatus(
                      visible: true,
                      current: state.uploadStatus.current,
                      total: state.uploadStatus.total,
                    )));
              }

              if (state.uploadStatus.status ==
                  VideoFoldersUploadStatus.failure) {
                context.read<HomeBloc>().add(HomeProgressIndicatorStatusChanged(
                    HomeLinearProgressIndicatorStatus(visible: false)));

                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(
                      content: Text(state.uploadStatus.failureReason ??
                          context.l10n.unknownError)));
              }

              if (state.uploadStatus.status ==
                  VideoFoldersUploadStatus.success) {
                context.read<HomeBloc>().add(HomeProgressIndicatorStatusChanged(
                    HomeLinearProgressIndicatorStatus(visible: false)));
                SoundEffect.play(SoundType.done);
              }
            },
            listenWhen: (previous, current) =>
                previous.uploadStatus != current.uploadStatus &&
                current.uploadStatus.status != VideoFoldersUploadStatus.initial,
          ),
          BlocListener<VideoFoldersBloc, VideoFoldersState>(
              listener: (context, state) {
                if (state.showLoading) {
                  BotToast.showLoading();
                } else {
                  BotToast.closeAllLoading();
                }

                if (state.showError) {
                  BotToast.showText(
                      text: state.failureReason ?? context.l10n.unknownError);
                }
              },
              listenWhen: (previous, current) =>
                  previous.showLoading != current.showLoading ||
                  current.showError != previous.showError),
        ],
        child: Stack(
          children: [
            // 视频文件夹页面
            Focus(
              autofocus: true,
              focusNode: _rootFocusNode,
              child: GestureDetector(
                child: Visibility(
                  child: Stack(
                    children: [
                      content,
                      Visibility(
                        child: Container(child: spinKit, color: Colors.white),
                        maintainSize: false,
                        visible: status == VideoFoldersStatus.loading,
                      )
                    ],
                    fit: StackFit.expand,
                  ),
                  visible: !videoFolderOpenStatus.isOpened,
                ),
                onTap: () {
                  _clearCheckedAll(context);
                },
              ),
              onFocusChange: (value) {},
              onKey: (node, event) {
                _isControlPressed = !kIsWeb && Platform.isMacOS
                    ? event.isMetaPressed
                    : event.isControlPressed;
                _isShiftPressed = event.isShiftPressed;

                VideoFoldersBoardKeyStatus status =
                    VideoFoldersBoardKeyStatus.none;

                if (_isControlPressed) {
                  status = VideoFoldersBoardKeyStatus.ctrlDown;
                } else if (_isShiftPressed) {
                  status = VideoFoldersBoardKeyStatus.shiftDown;
                }

                context
                    .read<VideoFoldersBloc>()
                    .add(VideoFoldersKeyStatusChanged(status));

                if (!kIsWeb && Platform.isMacOS) {
                  if (event.isMetaPressed &&
                      event.isKeyPressed(LogicalKeyboardKey.keyA)) {
                    _checkAll(context);
                    return KeyEventResult.handled;
                  }
                } else {
                  if (event.isControlPressed &&
                      event.isKeyPressed(LogicalKeyboardKey.keyA)) {
                    _checkAll(context);
                    return KeyEventResult.handled;
                  }
                }

                return KeyEventResult.ignored;
              },
            ),
            // 文件夹内视频页面
            Visibility(
              child: DropTarget(
                enable: _isVideoFolderOpenedAndShowing(context),
                onDragEntered: (details) {
                  SoundEffect.play(SoundType.bubble);
                },
                onDragDone: (details) {
                  final homeTab = context.read<HomeBloc>().state.tab;

                  if (homeTab != HomeTab.video) {
                    return;
                  }

                  final videoTab = context.read<VideoHomeBloc>().state.tab;
                  if (videoTab != VideoHomeTab.videoFolders) {
                    return;
                  }

                  final isFolderOpened = context
                      .read<VideoFoldersBloc>()
                      .state
                      .videoFolderOpenStatus
                      .isOpened;

                  if (!isFolderOpened) {
                    return;
                  }

                  final videos = details.files
                      .map((file) => File(file.path))
                      .where((element) => element.isVideo)
                      .toList();
                  if (videos.isEmpty) return;

                  final folder = context
                      .read<VideoFoldersBloc>()
                      .state
                      .videoFolderOpenStatus
                      .current;

                  context.read<VideoFoldersBloc>().add(
                      VideoFoldersUploadVideos(videos: videos, folder: folder));
                },
                child: Column(
                  children: [
                    Container(
                      child: Row(
                        children: [
                          GestureDetector(
                            child: Container(
                              child: Text(context.l10n.videoFolders,
                                  style: TextStyle(
                                      color: Color(0xff5b5c62), fontSize: 14)),
                              padding: EdgeInsets.only(left: 10),
                            ),
                            onTap: () {
                              context.read<VideoFoldersBloc>().add(
                                  VideoFoldersOpenStatusChanged(
                                      VideoFolderOpenStatus(isOpened: false)));
                            },
                          ),
                          Image.asset("assets/icons/ic_right_arrow.png",
                              height: 20),
                          Text(videoFolderOpenStatus.current?.name ?? "",
                              style: TextStyle(
                                  color: Color(0xff5b5c62), fontSize: 14))
                        ],
                      ),
                      color: Color(0xfffafafa),
                      height: 30,
                    ),
                    Divider(
                        color: Color(0xffe0e0e0), height: 1.0, thickness: 1.0),
                    Expanded(
                        child: Stack(
                      children: [
                        videosInFolderWidget,
                        Visibility(
                          child: Container(child: spinKit, color: Colors.white),
                          maintainSize: false,
                          visible: videoFolderOpenStatus.isOpened &&
                              loadVideosInFolderStatus.status ==
                                  VideoFoldersStatus.loading,
                        )
                      ],
                      fit: StackFit.expand,
                    ))
                  ],
                ),
              ),
              visible: videoFolderOpenStatus.isOpened,
            )
          ],
        ),
      ),
    );
  }

  bool _isVideoFolderListShowing(BuildContext context) {
    final homeTab = context.read<HomeBloc>().state.tab;

    if (homeTab != HomeTab.video) {
      return false;
    }

    final videoTab = context.read<VideoHomeBloc>().state.tab;
    if (videoTab != VideoHomeTab.videoFolders) {
      return false;
    }

    final isFolderOpened =
        context.read<VideoFoldersBloc>().state.videoFolderOpenStatus.isOpened;

    if (isFolderOpened) {
      return false;
    }

    return true;
  }

  bool _isVideoFolderOpenedAndShowing(BuildContext context) {
    final homeTab = context.read<HomeBloc>().state.tab;

    if (homeTab != HomeTab.video) {
      return false;
    }

    final videoTab = context.read<VideoHomeBloc>().state.tab;
    if (videoTab != VideoHomeTab.videoFolders) {
      return false;
    }

    final isFolderOpened =
        context.read<VideoFoldersBloc>().state.videoFolderOpenStatus.isOpened;

    if (!isFolderOpened) {
      return false;
    }

    return true;
  }

  bool _needListenItemCountChange(
      VideoFoldersState previous, VideoFoldersState current) {
    if (previous.videoFolders.length != current.videoFolders.length)
      return true;

    if (previous.checkedVideoFolders.length !=
        current.checkedVideoFolders.length) return true;

    if (previous.loadVideosInFolderStatus.videos.length !=
        current.loadVideosInFolderStatus.videos.length) return true;

    if (previous.loadVideosInFolderStatus.checkedVideos.length !=
        current.loadVideosInFolderStatus.checkedVideos.length) return true;

    return false;
  }

  void _showDownloadProgressDialog(
      BuildContext context, VideoFoldersFileType fileType) {
    if (null == _progressIndicatorDialog) {
      _progressIndicatorDialog = ProgressIndicatorDialog(context: context);
      _progressIndicatorDialog?.onCancelClick(() {
        _progressIndicatorDialog?.dismiss();
        context.read<VideoFoldersBloc>().add(VideoFoldersCancelCopy());
      });
    }

    String title = context.l10n.compressing;

    if (fileType == VideoFoldersFileType.video) {
      title = context.l10n.preparing;
    }

    _progressIndicatorDialog?.title = title;

    if (!_progressIndicatorDialog!.isShowing) {
      _progressIndicatorDialog!.show();
    }
  }

  void _checkAll(BuildContext context) {
    context.read<VideoFoldersBloc>().add(VideoFoldersCheckAll());
  }

  void _clearCheckedAll(BuildContext context) {
    context.read<VideoFoldersBloc>().add(VideoFoldersClearAll());
  }

  Widget _createGridContent(
      List<VideoFolderItem> videoFolders, List<VideoFolderItem> checkedVideos) {
    return Container(
      child: GridView.builder(
        scrollDirection: Axis.vertical,
        physics: ScrollPhysics(),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 260,
            crossAxisSpacing: _IMAGE_SPACE,
            childAspectRatio: 1.0,
            mainAxisSpacing: _IMAGE_SPACE),
        controller: ScrollController(keepScrollOffset: true),
        itemBuilder: (BuildContext context, int index) {
          VideoFolderItem videoFolder = videoFolders[index];

          final checkedVideos =
              context.read<VideoFoldersBloc>().state.checkedVideoFolders;
          return _VideoFolderListItem(
            enableDrag: _isVideoFolderListShowing(context),
            folder: videoFolder,
            isChecked: checkedVideos.contains(videoFolder),
            onTap: (videoFolder) {
              context
                  .read<VideoFoldersBloc>()
                  .add(VideoFoldersCheckedChanged(videoFolder));
            },
            onDoubleTap: (videoFolder) {
              context
                  .read<VideoFoldersBloc>()
                  .add(VideoFoldersCheckedChanged(videoFolder));

              context.read<VideoFoldersBloc>().add(
                  VideoFoldersOpenStatusChanged(VideoFolderOpenStatus(
                      isOpened: true, current: videoFolder)));
            },
            onMouseRightTap: (position, videoFolder) {
              List<VideoFolderItem> checkedVideoFolders =
                  context.read<VideoFoldersBloc>().state.checkedVideoFolders;

              if (!checkedVideoFolders.contains(videoFolder)) {
                context
                    .read<VideoFoldersBloc>()
                    .add(VideoFoldersCheckedChanged(videoFolder));
              }

              context.read<VideoFoldersBloc>().add(
                  VideoFoldersMenuStatusChanged(VideoFoldersOpenMenuStatus(
                      isOpened: true,
                      position: position,
                      target: videoFolder)));
            },
            onVideosDragDone: (folder, videos) {
              context.read<VideoFoldersBloc>().add(
                  VideoFoldersUploadVideos(folder: folder, videos: videos));
            },
          );
        },
        itemCount: videoFolders.length,
        shrinkWrap: true,
        primary: false,
      ),
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(_OUT_PADDING, _OUT_PADDING, _OUT_PADDING, 0),
    );
  }

  void _openMenuForFolders(
      {required BuildContext pageContext,
      required Offset position,
      required List<VideoFolderItem> folders,
      required List<VideoFolderItem> checkedFolders,
      required VideoFolderItem current}) {
    String copyTitle = "";

    if (checkedFolders.length == 1) {
      VideoFolderItem folder = checkedFolders.single;

      String name = folder.name;

      copyTitle = pageContext.l10n.placeHolderCopyToComputer
          .replaceFirst("%s", name)
          .adaptForOverflow();
    } else {
      String itemStr = pageContext.l10n.placeHolderItemCount03
          .replaceFirst("%d", "${checkedFolders.length}");
      copyTitle = pageContext.l10n.placeHolderCopyToComputer
          .replaceFirst("%s", itemStr)
          .adaptForOverflow();
    }

    if (kIsWeb) {
      copyTitle = pageContext.l10n.downloadToLocal;
    }

    ContextMenuHelper()
        .showContextMenu(context: pageContext, globalOffset: position, items: [
      ContextMenuItem(
        title: pageContext.l10n.open,
        onTap: () {
          ContextMenuHelper().hideContextMenu();
          pageContext.read<VideoFoldersBloc>().add(
              VideoFoldersOpenStatusChanged(
                  VideoFolderOpenStatus(isOpened: true, current: current)));
        },
      ),
      ContextMenuItem(
        title: copyTitle,
        onTap: () {
          ContextMenuHelper().hideContextMenu();

          if (!kIsWeb) {
            CommonUtil.openFilePicker(pageContext.l10n.chooseDir, (dir) {
              _startCopy(pageContext, checkedFolders, dir);
            }, (error) {
              debugPrint("_openFilePicker, error: $error");
            });
          } else {
            pageContext
                .read<VideoFoldersBloc>()
                .add(VideoFoldersDownloadVideoFoldersToLocal(checkedFolders));
          }
        },
      ),
      // Disabled to prevent accidental deletion
      // ContextMenuItem(
      //   title: pageContext.l10n.delete,
      //   onTap: () {
      //     ContextMenuHelper().hideContextMenu();
      //     _tryToDeleteVideoFolders(pageContext, checkedFolders);
      //   },
      // )
    ]);
  }

  void _startCopy(
      BuildContext context, List<VideoFolderItem> folders, String dir) {
    context
        .read<VideoFoldersBloc>()
        .add(VideoFoldersCopySubmitted(folders, dir));
  }

  void _tryToDeleteVideoFolders(
      BuildContext pageContext, List<VideoFolderItem> checkedFolders) {
    CommonUtil.showConfirmDialog(
        pageContext,
        "${pageContext.l10n.tipDeleteTitle.replaceFirst("%s", "${checkedFolders.length}")}",
        pageContext.l10n.tipDeleteDesc,
        pageContext.l10n.cancel,
        pageContext.l10n.delete, (context) {
      Navigator.of(context, rootNavigator: true).pop();

      pageContext
          .read<VideoFoldersBloc>()
          .add(VideoFoldersDeleteSubmitted(checkedFolders));
    }, (context) {
      Navigator.of(context, rootNavigator: true).pop();
    });
  }

  void _openMenuForVideos(
      {required BuildContext pageContext,
      required Offset position,
      required List<VideoItem> videos,
      required List<VideoItem> checkedVideos,
      required VideoItem current}) {
    String copyTitle = "";

    if (checkedVideos.length == 1) {
      VideoItem videoItem = checkedVideos.single;

      String name = videoItem.name;
      copyTitle = pageContext.l10n.placeHolderCopyToComputer
          .replaceFirst("%s", name)
          .adaptForOverflow();
    } else {
      String itemStr = pageContext.l10n.placeHolderItemCount03
          .replaceFirst("%d", "${checkedVideos.length}");
      copyTitle = pageContext.l10n.placeHolderCopyToComputer
          .replaceFirst("%s", itemStr)
          .adaptForOverflow();
    }

    if (kIsWeb) {
      copyTitle = pageContext.l10n.downloadToLocal;
    }

    ContextMenuHelper()
        .showContextMenu(context: pageContext, globalOffset: position, items: [
      ContextMenuItem(
        title: pageContext.l10n.open,
        onTap: () {
          ContextMenuHelper().hideContextMenu();
          SystemAppLauncher.openVideo(current);
        },
      ),
      ContextMenuItem(
        title: copyTitle,
        onTap: () {
          ContextMenuHelper().hideContextMenu();

          if (!kIsWeb) {
            CommonUtil.openFilePicker(pageContext.l10n.chooseDir, (dir) {
              _startCopyVideos(pageContext, checkedVideos, dir);
            }, (error) {
              debugPrint("_openFilePicker, error: $error");
            });
          } else {
            pageContext
                .read<VideoFoldersBloc>()
                .add(VideoFoldersDownloadVideosToLocal(checkedVideos));
          }
        },
      ),
      // Disabled to prevent accidental deletion
      // ContextMenuItem(
      //   title: pageContext.l10n.delete,
      //   onTap: () {
      //     ContextMenuHelper().hideContextMenu();
      //     _tryToDeleteVideos(pageContext, checkedVideos);
      //   },
      // )
    ]);
  }

  void _tryToDeleteVideos(
      BuildContext pageContext, List<VideoItem> checkedVideos) {
    CommonUtil.showConfirmDialog(
        pageContext,
        "${pageContext.l10n.tipDeleteTitle.replaceFirst("%s", "${checkedVideos.length}")}",
        pageContext.l10n.tipDeleteDesc,
        pageContext.l10n.cancel,
        pageContext.l10n.delete, (context) {
      Navigator.of(context, rootNavigator: true).pop();

      pageContext
          .read<VideoFoldersBloc>()
          .add(VideoFoldersDeleteVideosSubmitted(checkedVideos));
    }, (context) {
      Navigator.of(context, rootNavigator: true).pop();
    });
  }

  void _startCopyVideos(
      BuildContext context, List<VideoItem> videos, String dir) {
    context
        .read<VideoFoldersBloc>()
        .add(VideoFoldersVideosCopySubmitted(videos, dir));
  }

  Widget _createVideosWidget(BuildContext context, List<VideoItem> videos,
      List<VideoItem> checkedVideos, VideoOrderType orderType) {
    return VideoFlowWidget(
      rootUrl: _URL_SERVER,
      videos: videos,
      selectedVideos: checkedVideos,
      sortOrder: orderType,
      onVideoTap: (video) {
        context
            .read<VideoFoldersBloc>()
            .add(VideoFoldersVideosCheckedChanged(video));
      },
      onOutsideTap: () {
        _clearCheckedAll(context);
      },
      onVisibleChange: (totalVisible, partOfVisible) {},
      onVideoDoubleTap: (video) {
        context
            .read<VideoFoldersBloc>()
            .add(VideoFoldersVideosCheckedChanged(video));

        SystemAppLauncher.openVideo(video);
      },
      onPointerDown: (event, video) {
        if (event.isRightMouseClick()) {
          List<VideoItem> checkedVideos = context
              .read<VideoFoldersBloc>()
              .state
              .loadVideosInFolderStatus
              .checkedVideos;

          if (!checkedVideos.contains(video)) {
            context
                .read<VideoFoldersBloc>()
                .add(VideoFoldersVideosCheckedChanged(video));
          }

          context.read<VideoFoldersBloc>().add(VideoFoldersMenuStatusChanged(
              VideoFoldersOpenMenuStatus(
                  isOpened: true, position: event.position, target: video)));
        }
      },
    );
  }
}

class _VideoFolderListItem extends StatefulWidget {
  final VideoFolderItem folder;
  final bool isChecked;
  final bool enableDrag;
  final Function(VideoFolderItem)? onTap;
  final Function(VideoFolderItem)? onDoubleTap;
  final Function(Offset, VideoFolderItem)? onMouseRightTap;
  final Function(VideoFolderItem, List<File>)? onVideosDragDone;

  _VideoFolderListItem(
      {Key? key,
      required this.folder,
      required this.isChecked,
      required this.enableDrag,
      this.onTap,
      this.onDoubleTap,
      this.onMouseRightTap,
      this.onVideosDragDone})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _VideoFolderListItemState();
  }
}

class _VideoFolderListItemState extends State<_VideoFolderListItem> {
  bool _isDragEntered = false;

  @override
  Widget build(BuildContext context) {
    final imageWidth = 140.0;
    final imageHeight = 140.0;
    final imagePadding = 3.0;
    final selectedBackgroundColor = Color(0xffe6e6e6);
    final normalBackgroundColor = Colors.white;

    final normalTextColor = Color(0xff515151);
    final normalNumTextColor = Color(0xff929292);

    final selectedNameTextColor = Colors.white;
    final selectedNumTextColor = Colors.white;

    final normalNameBackgroundColor = Colors.white;
    final selectedNameBackgroundColor = Color(0xff5d87ed);

    return DropTarget(
        enable: widget.enableDrag,
        child: Listener(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SimpleGestureDetector(
                child: Container(
                  child: Stack(
                    children: [
                      Visibility(
                        child: RotationTransition(
                            turns: AlwaysStoppedAnimation(5 / 360),
                            child: Container(
                              width: imageWidth,
                              height: imageHeight,
                              padding: EdgeInsets.all(imagePadding),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                      color: Color(0xffdddddd), width: 1.0),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(3.0))),
                            )),
                        visible: widget.folder.videoCount > 1 ? true : false,
                      ),
                      Visibility(
                        child: RotationTransition(
                            turns: AlwaysStoppedAnimation(-5 / 360),
                            child: Container(
                              width: imageWidth,
                              height: imageHeight,
                              padding: EdgeInsets.all(imagePadding),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                      color: Color(0xffdddddd), width: 1.0),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(3.0))),
                            )),
                        visible: widget.folder.videoCount > 2 ? true : false,
                      ),
                      Container(
                        child: CachedNetworkImage(
                            imageUrl:
                                "${DeviceConnectionManager.instance.rootURL}/stream/video/thumbnail/${widget.folder.coverVideoId}/400/400",
                            fit: BoxFit.cover,
                            width: imageWidth,
                            height: imageWidth,
                            memCacheWidth: 400,
                            fadeOutDuration: Duration.zero,
                            fadeInDuration: Duration.zero),
                        padding: EdgeInsets.all(imagePadding),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                                color: Color(0xffdddddd), width: 1.0),
                            borderRadius:
                                BorderRadius.all(Radius.circular(3.0))),
                      )
                    ],
                  ),
                  decoration: BoxDecoration(
                      color: widget.isChecked || _isDragEntered
                          ? selectedBackgroundColor
                          : normalBackgroundColor,
                      borderRadius: BorderRadius.all(Radius.circular(4.0))),
                  padding: EdgeInsets.all(8),
                ),
                onTap: () {
                  widget.onTap?.call(widget.folder);
                },
                onDoubleTap: () {
                  widget.onDoubleTap?.call(widget.folder);
                },
              ),
              GestureDetector(
                child: Container(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.folder.name,
                        style: TextStyle(
                            color: widget.isChecked || _isDragEntered
                                ? selectedNameTextColor
                                : normalTextColor),
                      ),
                      Container(
                        child: Text(
                          "(${widget.folder.videoCount})",
                          style: TextStyle(
                              color: widget.isChecked || _isDragEntered
                                  ? selectedNumTextColor
                                  : normalNumTextColor),
                        ),
                        margin: EdgeInsets.only(left: 3),
                      )
                    ],
                  ),
                  margin: EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(3)),
                      color: widget.isChecked || _isDragEntered
                          ? selectedNameBackgroundColor
                          : normalNameBackgroundColor),
                  padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                ),
                onTap: () {
                  // setState(() {
                  // _setAlbumSelected(album);
                  // });
                },
              )
            ],
          ),
          onPointerDown: (event) {
            if (event.isRightMouseClick()) {
              widget.onMouseRightTap?.call(event.position, widget.folder);
            }
          },
        ),
        onDragEntered: (details) {
          SoundEffect.play(SoundType.bubble);

          setState(() {
            _isDragEntered = true;
          });
        },
        onDragDone: (details) {
          final homeTab = context.read<HomeBloc>().state.tab;

          if (homeTab != HomeTab.video) {
            return;
          }

          final videoTab = context.read<VideoHomeBloc>().state.tab;
          if (videoTab != VideoHomeTab.videoFolders) {
            return;
          }

          final isFolderOpened = context
              .read<VideoFoldersBloc>()
              .state
              .videoFolderOpenStatus
              .isOpened;

          if (isFolderOpened) {
            return;
          }

          final videos = details.files
              .map((file) => File(file.path))
              .where((element) => element.isVideo)
              .toList();
          if (videos.isNotEmpty) {
            widget.onVideosDragDone?.call(widget.folder, videos);
          }
        },
        onDragExited: (details) {
          setState(() {
            _isDragEntered = false;
          });
        });
  }
}
