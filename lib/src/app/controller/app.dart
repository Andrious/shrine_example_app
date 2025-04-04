///
/// Copyright (C) 2019 Andrious Solutions
///
/// This program is free software; you can redistribute it and/or
/// modify it under the terms of the GNU General Public License
/// as published by the Free Software Foundation; either version 3
/// of the License, or any later version.
///
/// You may obtain a copy of the License at
///
///  http://www.apache.org/licenses/LICENSE-2.0
///
///
/// Unless required by applicable law or agreed to in writing, software
/// distributed under the License is distributed on an "AS IS" BASIS,
/// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
/// See the License for the specific language governing permissions and
/// limitations under the License.
///
///          Created  09 Oct 2019
///
///

import '/src/controller.dart' show AppStateXController, ThemeController;

import '/src/view.dart'
    show
        App,
        AppStateExtension,
        BuildContext,
        DialogBox,
        L10n,
        L10nTranslate,
        Locale,
        MsgBox,
        SpinnerCupertino,
        Text,
        TextStyle,
        ThemeData,
        UniversalPlatform,
        kIsWeb,
        showAboutDialog;

///
class ShrineApp extends AppStateXController {
  ///
  factory ShrineApp() => _this ??= ShrineApp._();
  ShrineApp._() {
    _themeCon = ThemeController();
  }
  static ShrineApp? _this;

  // Theme Controller
  ThemeController? _themeCon;

  @override
  Future<bool> initAsync() async {
    _appTheme ??= App.themeData;
    App.themeData = _themeCon?.setIfDarkMode();
    return true;
  }

  // Original App Theme
  ThemeData? _appTheme;

  /// Toggle the App's Dark Mode
  void darkMode() {
    var darkMode = _themeCon?.isDarkMode;
    if (darkMode != null) {
      darkMode = !darkMode;
      _themeCon?.isDarkMode = darkMode;
      if (darkMode) {
        App.themeData = ThemeData.dark();
      } else {
        App.themeData = _appTheme;
      }
      App.setState(() {});
    }
  }

  ///
  Future<void> changeLocale() async {
    ///
    final app = appState!;

    if (!app.allowChangeLocale) {
      await MsgBox(
        context: app.lastContext!,
        title: 'Current Language'.tr,
        msg: 'Setting, allowChangeLocale, is set to false.',
      ).show();
      return;
    }

    final locale = app.locale!;

    final locales = app.supportedLocales;

    // record selected locale
    Locale? appLocale;

    final spinner = SpinnerCupertino<Locale>(
      initValue: locale,
      values: locales,
      itemBuilder: (BuildContext context, int index) => Text(
        locales[index].countryCode == null
            ? locales[index].languageCode
            : '${locales[index].languageCode}-${locales[index].countryCode}',
        style: const TextStyle(fontSize: 20),
      ),
      onSelectedItemChanged: (int index) async {
        appLocale = L10n.getLocale(index);
      },
      mouseUse: kIsWeb || UniversalPlatform.isWindows,
    );

    await DialogBox(
      context: app.lastContext!,
      title: 'Current Language'.tr,
      body: [spinner],
      press01: () {},
      press02: () => App.changeLocale(appLocale),
    ).show();
  }

  ///
  void aboutApp() => showAboutDialog(
        context: App.context!,
        applicationName: App.appState?.title ?? '',
        applicationVersion: 'version: ${App.version} build: ${App.buildNumber}',
      );

  @override
  void dispose() {
    _themeCon = null;
    _appTheme = null;
    super.dispose();
  }
}
