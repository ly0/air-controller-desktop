import 'dart:developer';
import 'dart:io';

import 'package:air_controller/all_images/model/all_image_upload_status.dart';
import 'package:air_controller/ext/filex.dart';
import 'package:air_controller/ext/string-ext.dart';
import 'package:air_controller/l10n/l10n.dart';
import 'package:air_controller/util/context_menu_helper.dart';
import 'package:air_controller/util/sound_effect.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../constant.dart';
import '../../enter/view/enter_page.dart';
import '../../home/bloc/home_bloc.dart';
import '../../home_image/bloc/home_image_bloc.dart';
import '../../model/arrangement_mode.dart';
import '../../model/image_item.dart';
import '../../network/device_connection_manager.dart';
import '../../repository/image_repository.dart';
import '../../util/common_util.dart';
import '../../widget/image_flow_widget.dart';
import '../../widget/progress_indictor_dialog.dart';
import '../bloc/all_images_bloc.dart';
import '../model/all_image_copy_status.dart';
import '../model/all_image_delete_status.dart';
import '../model/all_image_menu_arguments.dart';
import '../model/image_detail_arguments.dart';

class AllImagesPage extends StatelessWidget {
  final bool isFromCamera;
  final GlobalKey<NavigatorState> navigatorKey;

  AllImagesPage({required this.navigatorKey, this.isFromCamera = false});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AllImagesBloc>(
      create: (context) => AllImagesBloc(
          imageRepository: context.read<ImageRepository>(),
          isFromCamera: this.isFromCamera)
        ..add(AllImageSubscriptionRequested()),
      child: AllImagesView(
        navigatorKey: navigatorKey,
        isFromCamera: this.isFromCamera,
      ),
    );
  }
}

class AllImagesView extends StatefulWidget {
  final bool isFromCamera;
  final GlobalKey<NavigatorState> navigatorKey;

  AllImagesView({required this.navigatorKey, this.isFromCamera = false});

  @override
  State<AllImagesView> createState() => _AllImagesViewState();
}

class _AllImagesViewState extends State<AllImagesView> {
  bool _isControlPressed = false;
  bool _isShiftPressed = false;
  FocusNode? _rootFocusNode = null;
  ProgressIndicatorDialog? _progressIndicatorDialog;

  @override
  Widget build(BuildContext context) {
    final contentView = _buildContentView(context);

    return Scaffold(
      body: MultiBlocListener(
        listeners: [
          BlocListener<AllImagesBloc, AllImagesState>(
              listener: (context, state) {
                if (state.showLoading) {
                  BotToast.showLoading();
                } else {
                  BotToast.closeAllLoading();
                }

                if (state.showError) {
                  BotToast.showText(
                      text: state.errorMessage ?? context.l10n.unknownError);
                }
              },
              listenWhen: (previous, current) =>
                  previous.showLoading != current.showLoading ||
                  current.showError != current.showError),
          BlocListener<AllImagesBloc, AllImagesState>(
            listener: (context, state) {
              log("HomeImageCountChanged, checkedCount: ${state.checkedImages.length}, totalCount: ${state.images.length}");
              HomeImageCountChanged event = HomeImageCountChanged(
                  HomeImageCount(
                      checkedCount: state.checkedImages.length,
                      totalCount: state.images.length));
              context.read<HomeImageBloc>().add(event);

              context.read<HomeImageBloc>().add(HomeImageDeleteStatusChanged(
                  isDeleteEnabled: state.checkedImages.length > 0));
            },
            listenWhen: (previous, current) =>
                previous.images.length != current.images.length ||
                previous.checkedImages.length != current.checkedImages.length,
          ),
          BlocListener<AllImagesBloc, AllImagesState>(
            listener: (context, state) {
              _openMenu(context, state.contextMenuArguments!.targetImage,
                  state.contextMenuArguments!.position);
            },
            listenWhen: (previous, current) =>
                previous.contextMenuArguments != current.contextMenuArguments &&
                current.contextMenuArguments != null,
          ),
          BlocListener<AllImagesBloc, AllImagesState>(
            listener: (context, state) {
              if (state.deleteStatus.status ==
                  AllImageDeleteImagesStatus.failure) {
                SmartDialog.dismiss();

                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(
                      content: Text(state.deleteStatus.failureReason ??
                          "Delete image fail")));
              }

              if (state.deleteStatus.status ==
                  AllImageDeleteImagesStatus.loading) {
                SmartDialog.showLoading();
              }

              if (state.deleteStatus.status ==
                  AllImageDeleteImagesStatus.success) {
                SmartDialog.dismiss();
              }
            },
            listenWhen: (previous, current) =>
                previous.deleteStatus != current.deleteStatus &&
                current.deleteStatus.status !=
                    AllImageDeleteImagesStatus.initial,
          ),
          BlocListener<AllImagesBloc, AllImagesState>(
            listener: (context, state) {
              if (state.copyStatus?.status == AllImageCopyStatus.start) {
                _showDownloadProgressDialog(context, state.checkedImages);
              }

              if (state.copyStatus?.status == AllImageCopyStatus.copying) {
                if (_progressIndicatorDialog?.isShowing == true) {
                  int current = state.copyStatus!.current;
                  int total = state.copyStatus!.total;

                  if (current > 0) {
                    String title = context.l10n.exporting;

                    if (state.checkedImages.length == 1) {
                      String name = "";

                      int index =
                          state.checkedImages.single.path.lastIndexOf("/");
                      if (index != -1) {
                        name = state.checkedImages.single.path
                            .substring(index + 1);
                      }

                      title = context.l10n.placeholderExporting
                          .replaceFirst("%s", name);
                    }

                    if (state.checkedImages.length > 1) {
                      String itemStr = context.l10n.placeHolderItemCount03
                          .replaceFirst("%d", "${state.checkedImages.length}");
                      title = context.l10n.placeholderExporting
                          .replaceFirst("%s", itemStr);
                    }

                    _progressIndicatorDialog?.title = title;
                  }

                  _progressIndicatorDialog?.subtitle =
                      "${CommonUtil.convertToReadableSize(current)}/${CommonUtil.convertToReadableSize(total)}";
                  _progressIndicatorDialog?.updateProgress(current / total);
                }
              }

              if (state.copyStatus?.status == AllImageCopyStatus.failure) {
                _progressIndicatorDialog?.dismiss();

                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(
                      content: Text(
                          state.copyStatus!.error ?? "Copy images failure.")));
              }

              if (state.copyStatus?.status == AllImageCopyStatus.success) {
                _progressIndicatorDialog?.dismiss();
              }
            },
            listenWhen: (previous, current) =>
                previous.copyStatus != current.copyStatus &&
                current.copyStatus != null &&
                current.copyStatus?.status != AllImageCopyStatus.initial,
          ),
          BlocListener<HomeImageBloc, HomeImageState>(
            listener: (context, state) {
              if ((state.tab == HomeImageTab.allImages &&
                      !widget.isFromCamera) ||
                  (state.tab == HomeImageTab.cameraImages &&
                      widget.isFromCamera)) {
                _deleteImage(
                    context, context.read<AllImagesBloc>().state.checkedImages);
              }
            },
            listenWhen: (previous, current) =>
                previous.deleteTapStatus != current.deleteTapStatus &&
                (current.deleteTapStatus.tab == HomeImageTab.allImages ||
                    current.deleteTapStatus.tab == HomeImageTab.cameraImages) &&
                current.deleteTapStatus.status == HomeImageDeleteTapStatus.tap,
          ),
          BlocListener<HomeImageBloc, HomeImageState>(
              listener: (context, state) {
                if ((state.tab == HomeImageTab.allImages &&
                        !widget.isFromCamera) ||
                    (state.tab == HomeImageTab.cameraImages &&
                        widget.isFromCamera)) {
                  List<ImageItem> images =
                      context.read<AllImagesBloc>().state.images;
                  List<ImageItem> checkedImages =
                      context.read<AllImagesBloc>().state.checkedImages;

                  context.read<HomeImageBloc>().add(HomeImageCountChanged(
                      HomeImageCount(
                          checkedCount: checkedImages.length,
                          totalCount: images.length)));

                  context.read<HomeImageBloc>().add(
                      HomeImageDeleteStatusChanged(
                          isDeleteEnabled: checkedImages.length > 0));

                  context
                      .read<HomeImageBloc>()
                      .add(HomeImageArrangementVisibilityChanged(true));

                  context
                      .read<HomeImageBloc>()
                      .add(HomeImageBackVisibilityChanged(false));

                  _rootFocusNode?.requestFocus();
                }
              },
              listenWhen: (previous, current) => previous.tab != current.tab),
          BlocListener<AllImagesBloc, AllImagesState>(
            listener: (context, state) {
              if (state.uploadStatus.status == AllImageUploadStatus.start) {
                context.read<HomeBloc>().add(HomeProgressIndicatorStatusChanged(
                    HomeLinearProgressIndicatorStatus(visible: true)));
              }

              if (state.uploadStatus.status == AllImageUploadStatus.uploading) {
                context.read<HomeBloc>().add(HomeProgressIndicatorStatusChanged(
                        HomeLinearProgressIndicatorStatus(
                      visible: true,
                      current: state.uploadStatus.current,
                      total: state.uploadStatus.total,
                    )));
              }

              if (state.uploadStatus.status == AllImageUploadStatus.failure) {
                context.read<HomeBloc>().add(HomeProgressIndicatorStatusChanged(
                    HomeLinearProgressIndicatorStatus(visible: false)));

                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(
                      content: Text(state.uploadStatus.failureReason ??
                          context.l10n.unknownError)));
              }

              if (state.uploadStatus.status == AllImageUploadStatus.success) {
                context.read<HomeBloc>().add(HomeProgressIndicatorStatusChanged(
                    HomeLinearProgressIndicatorStatus(visible: false)));
                SoundEffect.play(SoundType.done);
              }
            },
            listenWhen: (previous, current) =>
                previous.uploadStatus != current.uploadStatus &&
                current.uploadStatus.status != AllImageUploadStatus.initial,
          )
        ],
        child: DropTarget(
          enable: _isShowing(context),
          onDragDone: (details) {
            if (!_isShowing(context)) return;

            final photos = details.files
                .map((xFile) => File(xFile.path))
                .where((file) => file.isImage)
                .toList();

            if (photos.isEmpty) return;

            int pos = widget.isFromCamera
                ? Constant.posCameraPictures
                : Constant.posAllPictures;
            context
                .read<AllImagesBloc>()
                .add(AllImagesUploadPhotos(pos: pos, photos: photos));
          },
          onDragEntered: (details) {
            SoundEffect.play(SoundType.bubble);
          },
          onDragExited: (details) {},
          onDragUpdated: (details) {},
          child: contentView,
        ),
      ),
    );
  }

  bool _isShowing(BuildContext context) {
    final homeTab = context.read<HomeBloc>().state.tab;
    final tab = context.read<HomeImageBloc>().state.tab;

    if (homeTab == HomeTab.image &&
        widget.isFromCamera &&
        tab == HomeImageTab.cameraImages) return true;
    if (homeTab == HomeTab.image &&
        !widget.isFromCamera &&
        tab == HomeImageTab.allImages) return true;
    return false;
  }

  Widget _buildContentView(BuildContext context) {
    const color = Color(0xff85a8d0);
    const spinKit = SpinKitCircle(color: color, size: 60.0);

    ArrangementMode arrangement =
        context.select((HomeImageBloc bloc) => bloc.state.arrangement);
    List<ImageItem> images =
        context.select((AllImagesBloc bloc) => bloc.state.images);
    List<ImageItem> checkedImages =
        context.select((AllImagesBloc bloc) => bloc.state.checkedImages);
    bool isLoadingComplete = context.select(
        (AllImagesBloc bloc) => bloc.state.status == AllImagesStatus.success);
    final homeTab = context.select((HomeBloc bloc) => bloc.state.tab);

    HomeImageTab currentTab =
        context.select((HomeImageBloc bloc) => bloc.state.tab);

    _rootFocusNode = FocusNode();
    _rootFocusNode?.canRequestFocus = true;

    if (homeTab == HomeTab.image &&
        ((currentTab == HomeImageTab.allImages && !widget.isFromCamera) ||
            currentTab == HomeImageTab.cameraImages && widget.isFromCamera)) {
      _rootFocusNode?.requestFocus();
    }

    final enterContext = EnterPage.enterKey.currentContext;
    String languageCode = "en";

    if (null != enterContext) {
      languageCode = Localizations.localeOf(enterContext).languageCode;
    }
    return Stack(
      children: [
        Focus(
            autofocus: true,
            focusNode: _rootFocusNode,
            child: ImageFlowWidget(
              languageCode: languageCode,
              rootUrl: DeviceConnectionManager.instance.rootURL,
              arrangeMode: arrangement,
              images: images,
              checkedImages: checkedImages,
              onRightMouseClick: (position, image) {
                if (!checkedImages.contains(image)) {
                  context
                      .read<AllImagesBloc>()
                      .add(AllImagesCheckedImagesChanged(image));
                }

                context.read<AllImagesBloc>().add(AllImagesOpenMenu(
                    AllImageMenuArguments(
                        position: position, targetImage: image)));
              },
              onImageDoubleTap: (image) {
                _openImageDetailPage(images.indexOf(image), images,
                    context.read<AllImagesBloc>());
              },
              onImageSelected: (image) {
                AllImagesCheckedImagesChanged event =
                    AllImagesCheckedImagesChanged(image);
                context.read<AllImagesBloc>().add(event);
                // _closeMenu(context);
              },
              onOutsideTap: () {
                context.read<AllImagesBloc>().add(AllImagesClearChecked());
              },
            ),
            onKey: (node, event) {
              _isControlPressed = !kIsWeb && Platform.isMacOS
                  ? event.isMetaPressed
                  : event.isControlPressed;
              _isShiftPressed = event.isShiftPressed;

              AllImagesBoardKeyStatus status = AllImagesBoardKeyStatus.none;

              if (_isControlPressed) {
                status = AllImagesBoardKeyStatus.ctrlDown;
              } else if (_isShiftPressed) {
                status = AllImagesBoardKeyStatus.shiftDown;
              }

              context
                  .read<AllImagesBloc>()
                  .add(AllImageKeyStatusChanged(status));

              if (!kIsWeb && Platform.isMacOS) {
                if (event.isMetaPressed &&
                    event.isKeyPressed(LogicalKeyboardKey.keyA)) {
                  context
                      .read<AllImagesBloc>()
                      .add(AllImagesShortcutKeyTriggered(ShortcutKey.ctrlAndA));
                  return KeyEventResult.handled;
                }
              } else {
                if (event.isControlPressed &&
                    event.isKeyPressed(LogicalKeyboardKey.keyA)) {
                  context
                      .read<AllImagesBloc>()
                      .add(AllImagesShortcutKeyTriggered(ShortcutKey.ctrlAndA));
                  return KeyEventResult.handled;
                }
              }

              return KeyEventResult.ignored;
            }),
        Visibility(
          child: Container(child: spinKit, color: Colors.white),
          maintainSize: false,
          visible: !isLoadingComplete,
        )
      ],
    );
  }

  void _showDownloadProgressDialog(
      BuildContext context, List<ImageItem> images) {
    if (null == _progressIndicatorDialog) {
      _progressIndicatorDialog = ProgressIndicatorDialog(context: context);
      _progressIndicatorDialog?.onCancelClick(() {
        _progressIndicatorDialog?.dismiss();
        context.read<AllImagesBloc>().add(AllImagesCancelCopySubmitted());
      });
    }

    String title = context.l10n.preparing;

    if (images.length > 1) {
      title = context.l10n.compressing;
    }

    _progressIndicatorDialog?.title = title;

    if (!_progressIndicatorDialog!.isShowing) {
      _progressIndicatorDialog!.show();
    }
  }

  void _deleteImage(BuildContext pageContext, List<ImageItem> checkedImages) {
    CommonUtil.showConfirmDialog(
        pageContext,
        "${pageContext.l10n.tipDeleteTitle.replaceFirst("%s", "${checkedImages.length}")}",
        pageContext.l10n.tipDeleteDesc,
        pageContext.l10n.cancel,
        pageContext.l10n.delete, (context) {
      Navigator.of(context, rootNavigator: true).pop();

      pageContext
          .read<AllImagesBloc>()
          .add(AllImagesDeleteSubmitted(checkedImages));
    }, (context) {
      Navigator.of(context, rootNavigator: true).pop();
    });
  }

  void _openImageDetailPage(
      int index, List<ImageItem> images, AllImagesBloc bloc) {
    final arguments = ImageDetailArguments(
        index: index, images: images, source: Source.allImages, extra: bloc);
    widget.navigatorKey.currentState
        ?.pushNamed(ImagePageRoute.IMAGE_DETAIL, arguments: arguments);
  }

  void _openMenu(BuildContext context, ImageItem current, Offset position) {
    final images = context.read<AllImagesBloc>().state.images;
    List<ImageItem> checkedImages =
        context.read<AllImagesBloc>().state.checkedImages;

    if (!checkedImages.contains(current)) {
      context.read<AllImagesBloc>().add(AllImagesCheckedImagesChanged(current));
    }

    String copyTitle = "";

    if (checkedImages.length == 1) {
      ImageItem imageItem = checkedImages.single;

      String name = "";

      int index = imageItem.path.lastIndexOf("/");
      if (index != -1) {
        name = imageItem.path.substring(index + 1);
      }

      copyTitle = context.l10n.placeHolderCopyToComputer
          .replaceFirst("%s", name)
          .adaptForOverflow();
    } else {
      String itemStr = context.l10n.placeHolderItemCount03
          .replaceFirst("%d", "${checkedImages.length}");
      copyTitle = context.l10n.placeHolderCopyToComputer
          .replaceFirst("%s", itemStr)
          .adaptForOverflow();
    }

    if (kIsWeb) {
      copyTitle = context.l10n.downloadToLocal;
    }

    ContextMenuHelper()
        .showContextMenu(context: context, globalOffset: position, items: [
      ContextMenuItem(
        title: context.l10n.open,
        onTap: () {
          ContextMenuHelper().hideContextMenu();
          _openImageDetailPage(
              images.indexOf(current), images, context.read<AllImagesBloc>());
        },
      ),
      ContextMenuItem(
        title: copyTitle,
        onTap: () {
          ContextMenuHelper().hideContextMenu();

          if (!kIsWeb) {
            CommonUtil.openFilePicker(context.l10n.chooseDir, (dir) {
              _startCopy(context, checkedImages, dir);
            }, (error) {
              debugPrint("_openFilePicker, error: $error");
            });
          } else {
            context
                .read<AllImagesBloc>()
                .add(AllImagesDownloadToLocal(checkedImages));
          }
        },
      ),
      // Disabled to prevent accidental deletion
      // ContextMenuItem(
      //   title: context.l10n.delete,
      //   onTap: () {
      //     ContextMenuHelper().hideContextMenu();
      //
      //     _deleteImage(context, checkedImages);
      //   },
      // )
    ]);
  }

  void _startCopy(BuildContext context, List<ImageItem> images, String dir) {
    context
        .read<AllImagesBloc>()
        .add(AllImagesCopyImagesSubmitted(images, dir));
  }
}
