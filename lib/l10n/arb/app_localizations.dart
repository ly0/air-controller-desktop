import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'arb/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('zh')
  ];

  /// No description provided for @currentNetworkLabel.
  ///
  /// In en, this message translates to:
  /// **'Current network: '**
  String get currentNetworkLabel;

  /// No description provided for @tipConnectToSameNetwork.
  ///
  /// In en, this message translates to:
  /// **'Connect your phone and computer to the same network, and launch %s on your phone'**
  String get tipConnectToSameNetwork;

  /// No description provided for @tipConnectToNetworkFirst.
  ///
  /// In en, this message translates to:
  /// **'Connect to network first'**
  String get tipConnectToNetworkFirst;

  /// No description provided for @tipConnectToNetworkDesc.
  ///
  /// In en, this message translates to:
  /// **'Please connect your computer and phone to the same network to initialize a connection.'**
  String get tipConnectToNetworkDesc;

  /// No description provided for @tipInstallMobileApp01.
  ///
  /// In en, this message translates to:
  /// **'If %s is not installed yet, please'**
  String get tipInstallMobileApp01;

  /// No description provided for @tipInstallMobileApp02.
  ///
  /// In en, this message translates to:
  /// **' click here '**
  String get tipInstallMobileApp02;

  /// No description provided for @tipInstallMobileApp03.
  ///
  /// In en, this message translates to:
  /// **'to scan barcode to download'**
  String get tipInstallMobileApp03;

  /// No description provided for @scanToDownloadApk.
  ///
  /// In en, this message translates to:
  /// **'Scan to download apk'**
  String get scanToDownloadApk;

  /// No description provided for @connect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connect;

  /// No description provided for @pictures.
  ///
  /// In en, this message translates to:
  /// **'Pictures'**
  String get pictures;

  /// No description provided for @musics.
  ///
  /// In en, this message translates to:
  /// **'Musics'**
  String get musics;

  /// No description provided for @videos.
  ///
  /// In en, this message translates to:
  /// **'Videos'**
  String get videos;

  /// No description provided for @downloads.
  ///
  /// In en, this message translates to:
  /// **'Downloads'**
  String get downloads;

  /// No description provided for @files.
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get files;

  /// No description provided for @helpAndFeedback.
  ///
  /// In en, this message translates to:
  /// **'Help and feedback'**
  String get helpAndFeedback;

  /// No description provided for @batteryLabel.
  ///
  /// In en, this message translates to:
  /// **'Battery: '**
  String get batteryLabel;

  /// No description provided for @storageLabel.
  ///
  /// In en, this message translates to:
  /// **'Storage: '**
  String get storageLabel;

  /// No description provided for @allPictures.
  ///
  /// In en, this message translates to:
  /// **'All Pictures'**
  String get allPictures;

  /// No description provided for @cameraRoll.
  ///
  /// In en, this message translates to:
  /// **'Camera Roll'**
  String get cameraRoll;

  /// No description provided for @galleries.
  ///
  /// In en, this message translates to:
  /// **'Galleries'**
  String get galleries;

  /// No description provided for @placeHolderItemCount01.
  ///
  /// In en, this message translates to:
  /// **'%d items'**
  String get placeHolderItemCount01;

  /// No description provided for @placeHolderItemCount02.
  ///
  /// In en, this message translates to:
  /// **'Selected %d item (Total %d items)'**
  String get placeHolderItemCount02;

  /// No description provided for @placeHolderItemCount03.
  ///
  /// In en, this message translates to:
  /// **'%d items'**
  String get placeHolderItemCount03;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @placeHolderCopyToComputer.
  ///
  /// In en, this message translates to:
  /// **'Copy %s to computer'**
  String get placeHolderCopyToComputer;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @tipDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Are you sure to delete the %s items?'**
  String get tipDeleteTitle;

  /// No description provided for @tipDeleteDesc.
  ///
  /// In en, this message translates to:
  /// **'Attention: the deleted files can\'t be restored!'**
  String get tipDeleteDesc;

  /// No description provided for @generalLabel.
  ///
  /// In en, this message translates to:
  /// **'General: '**
  String get generalLabel;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name: '**
  String get nameLabel;

  /// No description provided for @pathLabel.
  ///
  /// In en, this message translates to:
  /// **'Path: '**
  String get pathLabel;

  /// No description provided for @kindLabel.
  ///
  /// In en, this message translates to:
  /// **'Kind: '**
  String get kindLabel;

  /// No description provided for @sizeLabel.
  ///
  /// In en, this message translates to:
  /// **'Size: '**
  String get sizeLabel;

  /// No description provided for @dimensionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Dimensions: '**
  String get dimensionsLabel;

  /// No description provided for @createdLabel.
  ///
  /// In en, this message translates to:
  /// **'Created: '**
  String get createdLabel;

  /// No description provided for @modifiedLabel.
  ///
  /// In en, this message translates to:
  /// **'Modified: '**
  String get modifiedLabel;

  /// No description provided for @chooseDir.
  ///
  /// In en, this message translates to:
  /// **'Choose directory'**
  String get chooseDir;

  /// No description provided for @yMdPattern.
  ///
  /// In en, this message translates to:
  /// **'MM-dd yyyy'**
  String get yMdPattern;

  /// No description provided for @yMPattern.
  ///
  /// In en, this message translates to:
  /// **'MM-yyyy'**
  String get yMPattern;

  /// No description provided for @yMdHmPattern.
  ///
  /// In en, this message translates to:
  /// **'MM-dd-yyyy HH:mm'**
  String get yMdHmPattern;

  /// No description provided for @placeholderExporting.
  ///
  /// In en, this message translates to:
  /// **'Exporting %s, please wait...'**
  String get placeholderExporting;

  /// No description provided for @preparing.
  ///
  /// In en, this message translates to:
  /// **'In preparation, please wait...'**
  String get preparing;

  /// No description provided for @compressing.
  ///
  /// In en, this message translates to:
  /// **'Compressing, please wait...'**
  String get compressing;

  /// No description provided for @exporting.
  ///
  /// In en, this message translates to:
  /// **'Exporting, please wait...'**
  String get exporting;

  /// No description provided for @copyFileFailure.
  ///
  /// In en, this message translates to:
  /// **'Copy files failure, try again later!'**
  String get copyFileFailure;

  /// No description provided for @folder.
  ///
  /// In en, this message translates to:
  /// **'Folder'**
  String get folder;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @size.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get size;

  /// No description provided for @dateModified.
  ///
  /// In en, this message translates to:
  /// **'Date Modified'**
  String get dateModified;

  /// No description provided for @allVideos.
  ///
  /// In en, this message translates to:
  /// **'All Videos'**
  String get allVideos;

  /// No description provided for @videoFolders.
  ///
  /// In en, this message translates to:
  /// **'Video Folder'**
  String get videoFolders;

  /// No description provided for @loadVideoFoldersFailure.
  ///
  /// In en, this message translates to:
  /// **'Load video folders failure, try it again later!'**
  String get loadVideoFoldersFailure;

  /// No description provided for @rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// No description provided for @phoneStorage.
  ///
  /// In en, this message translates to:
  /// **'Phone Storage'**
  String get phoneStorage;

  /// No description provided for @deleteFilesFailure.
  ///
  /// In en, this message translates to:
  /// **'Delete files failure, try it again later!'**
  String get deleteFilesFailure;

  /// No description provided for @jpegImage.
  ///
  /// In en, this message translates to:
  /// **'JPEG image'**
  String get jpegImage;

  /// No description provided for @pngImage.
  ///
  /// In en, this message translates to:
  /// **'PNG image'**
  String get pngImage;

  /// No description provided for @rawImage.
  ///
  /// In en, this message translates to:
  /// **'RAW image'**
  String get rawImage;

  /// No description provided for @mp3Audio.
  ///
  /// In en, this message translates to:
  /// **'MP3 audio'**
  String get mp3Audio;

  /// No description provided for @textFile.
  ///
  /// In en, this message translates to:
  /// **'TEXT file'**
  String get textFile;

  /// No description provided for @document.
  ///
  /// In en, this message translates to:
  /// **'Document'**
  String get document;

  /// No description provided for @placeholderH.
  ///
  /// In en, this message translates to:
  /// **'%s h'**
  String get placeholderH;

  /// No description provided for @placeholderHM.
  ///
  /// In en, this message translates to:
  /// **'%s h %s m'**
  String get placeholderHM;

  /// No description provided for @placeholderHMS.
  ///
  /// In en, this message translates to:
  /// **'%s h %s minutes %s s'**
  String get placeholderHMS;

  /// No description provided for @placeholderM.
  ///
  /// In en, this message translates to:
  /// **'%s m'**
  String get placeholderM;

  /// No description provided for @placeholderMS.
  ///
  /// In en, this message translates to:
  /// **'%s m %s s'**
  String get placeholderMS;

  /// No description provided for @placeholderS.
  ///
  /// In en, this message translates to:
  /// **'%s s'**
  String get placeholderS;

  /// No description provided for @wirelessConDisconnected.
  ///
  /// In en, this message translates to:
  /// **'Wireless connection disconnected'**
  String get wirelessConDisconnected;

  /// No description provided for @placeholderDisconnectionDesc.
  ///
  /// In en, this message translates to:
  /// **'The wireless connection has been disconnected due to unstable network environment or %s connection timeout on the mobile phone, please check.'**
  String get placeholderDisconnectionDesc;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHome;

  /// No description provided for @ethernet.
  ///
  /// In en, this message translates to:
  /// **'Ethernet'**
  String get ethernet;

  /// No description provided for @wifi.
  ///
  /// In en, this message translates to:
  /// **'WLAN'**
  String get wifi;

  /// No description provided for @defaultType.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultType;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @sortByDate.
  ///
  /// In en, this message translates to:
  /// **'Sort by date'**
  String get sortByDate;

  /// No description provided for @sortByDuration.
  ///
  /// In en, this message translates to:
  /// **'Sort by duration'**
  String get sortByDuration;

  /// No description provided for @chooseDownloadDir.
  ///
  /// In en, this message translates to:
  /// **'Choose download directory'**
  String get chooseDownloadDir;

  /// No description provided for @downloadUpdateFailure.
  ///
  /// In en, this message translates to:
  /// **'Download update failure!'**
  String get downloadUpdateFailure;

  /// No description provided for @install.
  ///
  /// In en, this message translates to:
  /// **'Install'**
  String get install;

  /// No description provided for @packageHasReady.
  ///
  /// In en, this message translates to:
  /// **'The install package is ready.'**
  String get packageHasReady;

  /// No description provided for @iKnow.
  ///
  /// In en, this message translates to:
  /// **'Ok'**
  String get iKnow;

  /// No description provided for @updateDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Update ready to download'**
  String get updateDialogTitle;

  /// No description provided for @placeholderCurrentVersion.
  ///
  /// In en, this message translates to:
  /// **'Current version: %s'**
  String get placeholderCurrentVersion;

  /// No description provided for @checkUpdate.
  ///
  /// In en, this message translates to:
  /// **'Check for updates'**
  String get checkUpdate;

  /// No description provided for @failedToCheckForUpdates.
  ///
  /// In en, this message translates to:
  /// **'Failed to check for updates!'**
  String get failedToCheckForUpdates;

  /// No description provided for @noUpdatesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No updates available.'**
  String get noUpdatesAvailable;

  /// No description provided for @toolbox.
  ///
  /// In en, this message translates to:
  /// **'Toolbox'**
  String get toolbox;

  /// No description provided for @manageApps.
  ///
  /// In en, this message translates to:
  /// **'Manage apps'**
  String get manageApps;

  /// No description provided for @manageContacts.
  ///
  /// In en, this message translates to:
  /// **'Manage contacts'**
  String get manageContacts;

  /// No description provided for @app.
  ///
  /// In en, this message translates to:
  /// **'Application'**
  String get app;

  /// No description provided for @versionName.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get versionName;

  /// No description provided for @operate.
  ///
  /// In en, this message translates to:
  /// **'Action'**
  String get operate;

  /// No description provided for @phoneNotInstallAnyApp.
  ///
  /// In en, this message translates to:
  /// **'Your phone doesn\'t seem to have any app installed!'**
  String get phoneNotInstallAnyApp;

  /// No description provided for @myApps.
  ///
  /// In en, this message translates to:
  /// **'My Apps'**
  String get myApps;

  /// No description provided for @preInstalledApps.
  ///
  /// In en, this message translates to:
  /// **'System Apps'**
  String get preInstalledApps;

  /// No description provided for @installApp.
  ///
  /// In en, this message translates to:
  /// **'Install apk'**
  String get installApp;

  /// No description provided for @uninstall.
  ///
  /// In en, this message translates to:
  /// **'Uninstall'**
  String get uninstall;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @placeHolderVersionName.
  ///
  /// In en, this message translates to:
  /// **'Version %s'**
  String get placeHolderVersionName;

  /// No description provided for @pleaseSelectInstallationPackage.
  ///
  /// In en, this message translates to:
  /// **'Please select an installation package'**
  String get pleaseSelectInstallationPackage;

  /// No description provided for @uploadingWait.
  ///
  /// In en, this message translates to:
  /// **'Uploading...'**
  String get uploadingWait;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'Unknown error!'**
  String get unknownError;

  /// No description provided for @installationPackageUploadSuccess.
  ///
  /// In en, this message translates to:
  /// **'The installation package is uploaded successfully, please go to the mobile phone to install'**
  String get installationPackageUploadSuccess;

  /// No description provided for @uninstallConfirmTip.
  ///
  /// In en, this message translates to:
  /// **'The uninstall request has been sent, please confirm on the mobile phone and complete the uninstall!'**
  String get uninstallConfirmTip;

  /// No description provided for @newContact.
  ///
  /// In en, this message translates to:
  /// **'New contact'**
  String get newContact;

  /// No description provided for @placeHolderAllContacts.
  ///
  /// In en, this message translates to:
  /// **'All contacts(%s)'**
  String get placeHolderAllContacts;

  /// No description provided for @accountLabel.
  ///
  /// In en, this message translates to:
  /// **'Accounts: '**
  String get accountLabel;

  /// No description provided for @groupLabel.
  ///
  /// In en, this message translates to:
  /// **'Groups: '**
  String get groupLabel;

  /// No description provided for @selectImage.
  ///
  /// In en, this message translates to:
  /// **'Please select an image'**
  String get selectImage;

  /// No description provided for @editContact.
  ///
  /// In en, this message translates to:
  /// **'Edit contact'**
  String get editContact;

  /// No description provided for @addContact.
  ///
  /// In en, this message translates to:
  /// **'Add contact'**
  String get addContact;

  /// No description provided for @singleAccountLabel.
  ///
  /// In en, this message translates to:
  /// **'Account: '**
  String get singleAccountLabel;

  /// No description provided for @singleGroupLabel.
  ///
  /// In en, this message translates to:
  /// **'Group: '**
  String get singleGroupLabel;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone: '**
  String get phoneLabel;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email: '**
  String get emailLabel;

  /// No description provided for @imLabel.
  ///
  /// In en, this message translates to:
  /// **'IM: '**
  String get imLabel;

  /// No description provided for @addressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address: '**
  String get addressLabel;

  /// No description provided for @relationLabel.
  ///
  /// In en, this message translates to:
  /// **'Relation: '**
  String get relationLabel;

  /// No description provided for @noteLabel.
  ///
  /// In en, this message translates to:
  /// **'Note: '**
  String get noteLabel;

  /// No description provided for @sure.
  ///
  /// In en, this message translates to:
  /// **'Ok'**
  String get sure;

  /// No description provided for @addCategory.
  ///
  /// In en, this message translates to:
  /// **'Add category'**
  String get addCategory;

  /// No description provided for @allContacts.
  ///
  /// In en, this message translates to:
  /// **'All contacts'**
  String get allContacts;

  /// No description provided for @loadImageFailure.
  ///
  /// In en, this message translates to:
  /// **'Load image failure!'**
  String get loadImageFailure;

  /// No description provided for @ipAddress.
  ///
  /// In en, this message translates to:
  /// **'IP address'**
  String get ipAddress;

  /// No description provided for @enterIpAddress.
  ///
  /// In en, this message translates to:
  /// **'Please enter the IP address'**
  String get enterIpAddress;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'optional'**
  String get optional;

  /// No description provided for @invalidIpAddress.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid IP address!'**
  String get invalidIpAddress;

  /// No description provided for @connectionFailed.
  ///
  /// In en, this message translates to:
  /// **'Connection failed!'**
  String get connectionFailed;

  /// No description provided for @downloadToLocal.
  ///
  /// In en, this message translates to:
  /// **'Download to local'**
  String get downloadToLocal;

  /// No description provided for @webLogoText.
  ///
  /// In en, this message translates to:
  /// **'Connect your Android phone wirelessly and manage your phone files remotely'**
  String get webLogoText;

  /// No description provided for @downloadAppGuide.
  ///
  /// In en, this message translates to:
  /// **'Download the software for the best experience'**
  String get downloadAppGuide;

  /// No description provided for @web.
  ///
  /// In en, this message translates to:
  /// **'Web'**
  String get web;

  /// No description provided for @docs.
  ///
  /// In en, this message translates to:
  /// **'Docs'**
  String get docs;

  /// No description provided for @github.
  ///
  /// In en, this message translates to:
  /// **'GitHub'**
  String get github;

  /// No description provided for @slogan.
  ///
  /// In en, this message translates to:
  /// **'The open source version of HandShaker allows you to better manage your Android phones on the Mac platform'**
  String get slogan;

  /// No description provided for @appIntro.
  ///
  /// In en, this message translates to:
  /// **'AirController is a cross-platform file transfer and management tool that connects mobile phones and computers. Currently, AirController supports direct use in Windows, macOS, Linux operating systems and browsers. The original intention of AirController is It is expected to provide an easy-to-use Android phone management software for the Mac platform to make up for the shortcomings of the synchronization between the Mac platform and the Android phone, expect it to be your right-hand man.'**
  String get appIntro;

  /// No description provided for @operationGuide.
  ///
  /// In en, this message translates to:
  /// **'Connect to WIFI to manage your mobile phone wirelessly'**
  String get operationGuide;

  /// No description provided for @openSourceDeclaration.
  ///
  /// In en, this message translates to:
  /// **'Open source software, feel free to use'**
  String get openSourceDeclaration;

  /// No description provided for @tryWebVersion.
  ///
  /// In en, this message translates to:
  /// **'Try the web version'**
  String get tryWebVersion;

  /// No description provided for @joinOurCommunity.
  ///
  /// In en, this message translates to:
  /// **'Join Our Community'**
  String get joinOurCommunity;

  /// No description provided for @qqGroup.
  ///
  /// In en, this message translates to:
  /// **'QQ communication group'**
  String get qqGroup;

  /// No description provided for @sinaWeibo.
  ///
  /// In en, this message translates to:
  /// **'Sina Weibo'**
  String get sinaWeibo;

  /// No description provided for @wechatOfficial.
  ///
  /// In en, this message translates to:
  /// **'Wechat Official Account'**
  String get wechatOfficial;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @feedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedback;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
