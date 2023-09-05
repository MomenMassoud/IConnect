//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <audioplayers_windows/audioplayers_windows_plugin.h>
#include <awesome_notifications/awesome_notifications_plugin_c_api.h>
#include <emoji_picker_flutter/emoji_picker_flutter_plugin_c_api.h>
#include <firebase_core/firebase_core_plugin_c_api.h>
#include <flutter_localization/flutter_localization_plugin_c_api.h>
#include <flutter_webrtc/flutter_web_r_t_c_plugin.h>
#include <modal_progress_hud_nsn/modal_progress_hud_nsn_plugin.h>
#include <permission_handler_windows/permission_handler_windows_plugin.h>
#include <smart_auth/smart_auth_plugin.h>
#include <url_launcher_windows/url_launcher_windows.h>
#include <videosdk/videosdk_plugin_c_api.h>
#include <zego_express_engine/zego_express_engine_plugin.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  AudioplayersWindowsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("AudioplayersWindowsPlugin"));
  AwesomeNotificationsPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("AwesomeNotificationsPluginCApi"));
  EmojiPickerFlutterPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("EmojiPickerFlutterPluginCApi"));
  FirebaseCorePluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FirebaseCorePluginCApi"));
  FlutterLocalizationPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FlutterLocalizationPluginCApi"));
  FlutterWebRTCPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FlutterWebRTCPlugin"));
  ModalProgressHudNsnPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("ModalProgressHudNsnPlugin"));
  PermissionHandlerWindowsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("PermissionHandlerWindowsPlugin"));
  SmartAuthPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("SmartAuthPlugin"));
  UrlLauncherWindowsRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("UrlLauncherWindows"));
  VideosdkPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("VideosdkPluginCApi"));
  ZegoExpressEnginePluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("ZegoExpressEnginePlugin"));
}
