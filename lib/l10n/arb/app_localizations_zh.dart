// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get currentNetworkLabel => '当前网络: ';

  @override
  String get tipConnectToSameNetwork => '请确保手机与电脑处于同一网络，并在手机端保持%s应用打开';

  @override
  String get tipConnectToNetworkFirst => '请先将电脑连接至网络';

  @override
  String get tipConnectToNetworkDesc => '为确保应用正常工作，请确保手机与电脑连接至同一网络';

  @override
  String get tipInstallMobileApp01 => '如手机上尚未安装%s应用，请';

  @override
  String get tipInstallMobileApp02 => '扫描二维码';

  @override
  String get tipInstallMobileApp03 => '下载';

  @override
  String get scanToDownloadApk => '手机扫描下载App';

  @override
  String get connect => '连接';

  @override
  String get pictures => '图片';

  @override
  String get musics => '音乐';

  @override
  String get videos => '视频';

  @override
  String get downloads => '下载';

  @override
  String get files => '全部文件';

  @override
  String get helpAndFeedback => '帮助与反馈';

  @override
  String get batteryLabel => '电量: ';

  @override
  String get storageLabel => '手机存储: ';

  @override
  String get allPictures => '所有图片';

  @override
  String get cameraRoll => '相机相册';

  @override
  String get galleries => '所有相册';

  @override
  String get placeHolderItemCount01 => '共%d项';

  @override
  String get placeHolderItemCount02 => '选中%d项（共%d项)';

  @override
  String get placeHolderItemCount03 => '%d 项';

  @override
  String get open => '打开';

  @override
  String get delete => '删除';

  @override
  String get placeHolderCopyToComputer => '拷贝 %s 到电脑';

  @override
  String get back => '返回';

  @override
  String get cancel => '取消';

  @override
  String get tipDeleteTitle => '确定删除选中 %s 项吗？';

  @override
  String get tipDeleteDesc => '注意：删除的文件将无法恢复！';

  @override
  String get generalLabel => '基本信息：';

  @override
  String get nameLabel => '名称：';

  @override
  String get pathLabel => '路径：';

  @override
  String get kindLabel => '种类：';

  @override
  String get sizeLabel => '大小：';

  @override
  String get dimensionsLabel => '尺寸：';

  @override
  String get createdLabel => '创建时间：';

  @override
  String get modifiedLabel => '修改时间：';

  @override
  String get chooseDir => '选择目录';

  @override
  String get yMdPattern => 'yyyy年M月d日';

  @override
  String get yMPattern => 'yyyy年M月';

  @override
  String get yMdHmPattern => 'yyyy年M月d日 HH:mm';

  @override
  String get placeholderExporting => '正在导出%s，请稍后...';

  @override
  String get preparing => '正在准备中，请稍后...';

  @override
  String get compressing => '正在压缩中，请稍后...';

  @override
  String get exporting => '正在导出，请稍后...';

  @override
  String get copyFileFailure => '拷贝文件失败，请稍后再试！';

  @override
  String get folder => '文件夹';

  @override
  String get name => '名称';

  @override
  String get type => '类型';

  @override
  String get duration => '时长';

  @override
  String get size => '大小';

  @override
  String get dateModified => '修改日期';

  @override
  String get allVideos => '所有视频';

  @override
  String get videoFolders => '视频文件夹';

  @override
  String get loadVideoFoldersFailure => '获取视频文件夹列表数据失败，请稍后再试！';

  @override
  String get rename => '重命名';

  @override
  String get phoneStorage => '手机存储';

  @override
  String get deleteFilesFailure => '删除文件失败，请稍后再试！';

  @override
  String get jpegImage => 'JPEG图像';

  @override
  String get pngImage => 'PNG图像';

  @override
  String get rawImage => 'Panasonic raw图像';

  @override
  String get mp3Audio => 'MP3音频';

  @override
  String get textFile => '文本文件';

  @override
  String get document => '文档';

  @override
  String get placeholderH => '%s 小时';

  @override
  String get placeholderHM => '%s 小时 %s 分';

  @override
  String get placeholderHMS => '%s 小时 %s 分 %s 秒';

  @override
  String get placeholderM => '%s 分';

  @override
  String get placeholderMS => '%s 分 %s 秒';

  @override
  String get placeholderS => '%s 秒';

  @override
  String get wirelessConDisconnected => '无线连接已断开';

  @override
  String get placeholderDisconnectionDesc =>
      '由于网络环境不稳定或手机端%s连接超时等原因，无线连接已断开，请检查。';

  @override
  String get backToHome => '返回主界面';

  @override
  String get ethernet => '以太网';

  @override
  String get wifi => '无线网络';

  @override
  String get defaultType => '默认';

  @override
  String get daily => '按天排列';

  @override
  String get monthly => '按月排列';

  @override
  String get sortByDate => '按时间排列';

  @override
  String get sortByDuration => '按时长排列';

  @override
  String get chooseDownloadDir => '选择下载目录';

  @override
  String get downloadUpdateFailure => '下载更新失败！';

  @override
  String get install => '安装';

  @override
  String get packageHasReady => '安装包已准备就绪';

  @override
  String get iKnow => '我知道了';

  @override
  String get updateDialogTitle => '发现新版本';

  @override
  String get placeholderCurrentVersion => '当前版本: %s';

  @override
  String get checkUpdate => '检查更新';

  @override
  String get failedToCheckForUpdates => '检查更新失败！';

  @override
  String get noUpdatesAvailable => '暂无更新可用！';

  @override
  String get toolbox => '工具箱';

  @override
  String get manageApps => '应用管理';

  @override
  String get manageContacts => '联系人管理';

  @override
  String get app => '应用';

  @override
  String get versionName => '版本';

  @override
  String get operate => '操作';

  @override
  String get phoneNotInstallAnyApp => '你的手机似乎没有安装任何软件！';

  @override
  String get myApps => '我的应用';

  @override
  String get preInstalledApps => '系统应用';

  @override
  String get installApp => '安装应用';

  @override
  String get uninstall => '卸载';

  @override
  String get export => '导出';

  @override
  String get refresh => '刷新';

  @override
  String get sortBy => '排序';

  @override
  String get search => '搜索';

  @override
  String get placeHolderVersionName => '版本 %s';

  @override
  String get pleaseSelectInstallationPackage => '请选择安装包';

  @override
  String get uploadingWait => '正在上传中，请稍后...';

  @override
  String get unknownError => '未知错误';

  @override
  String get installationPackageUploadSuccess => '安装包已上传成功，请前往手机安装！';

  @override
  String get uninstallConfirmTip => '卸载请求已发起，请在手机端确认并完成卸载！';

  @override
  String get newContact => '新建联系人';

  @override
  String get placeHolderAllContacts => '全部联系人（%s）';

  @override
  String get accountLabel => '账号：';

  @override
  String get groupLabel => '分组：';

  @override
  String get selectImage => '选择图片';

  @override
  String get editContact => '编辑联系人';

  @override
  String get addContact => '添加联系人';

  @override
  String get singleAccountLabel => '账户：';

  @override
  String get singleGroupLabel => '分组：';

  @override
  String get phoneLabel => '手机：';

  @override
  String get emailLabel => '邮箱：';

  @override
  String get imLabel => '聊天：';

  @override
  String get addressLabel => '地址：';

  @override
  String get relationLabel => '关系：';

  @override
  String get noteLabel => '备注：';

  @override
  String get sure => '确定';

  @override
  String get addCategory => '添加分类';

  @override
  String get allContacts => '所有联系人';

  @override
  String get loadImageFailure => '图片加载失败!';

  @override
  String get ipAddress => 'IP地址';

  @override
  String get enterIpAddress => '请输入IP地址';

  @override
  String get password => '密码';

  @override
  String get optional => '可选';

  @override
  String get invalidIpAddress => '请输入有效的IP地址';

  @override
  String get connectionFailed => '连接失败！';

  @override
  String get downloadToLocal => '下载到本地';

  @override
  String get webLogoText => '无线连接你的Android手机，远程管理你的手机文件';

  @override
  String get downloadAppGuide => '下载软件，获取最佳体验';

  @override
  String get web => '网页版';

  @override
  String get docs => '文档';

  @override
  String get github => 'GitHub';

  @override
  String get slogan => '开源版本HandShaker，让你在Mac平台上更好地管理你的Android手机';

  @override
  String get appIntro =>
      'AirController是一个跨平台的、连接手机与电脑之间的文件传输与管理工具。目前，AirController已支持在Windows、macOS、Linux操作系统以及浏览器中直接使用。AirController的设计初衷是期望提供一个Mac平台好用的Android手机管理软件，以弥补Mac平台与Android手机同步的缺陷，期望它能成为你的得力助手。';

  @override
  String get operationGuide => '连接WIFI即可无线管理你的手机';

  @override
  String get openSourceDeclaration => '开源软件，放心使用';

  @override
  String get tryWebVersion => '网页版体验';

  @override
  String get joinOurCommunity => '加入我们的社区';

  @override
  String get qqGroup => 'QQ交流群';

  @override
  String get sinaWeibo => '新浪微博';

  @override
  String get wechatOfficial => '微信公众号';

  @override
  String get download => '下载';

  @override
  String get feedback => '问题反馈';
}
