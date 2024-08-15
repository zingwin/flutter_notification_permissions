import {
  FlutterPlugin,
  FlutterPluginBinding,
  MethodCall,
  MethodCallHandler,
  MethodChannel,
  MethodResult,
} from '@ohos/flutter_ohos';
import { notificationManager } from '@kit.NotificationKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { common } from '@kit.AbilityKit';
import {
  AbilityPluginBinding
} from '@ohos/flutter_ohos/src/main/ets/embedding/engine/plugins/ability/AbilityPluginBinding';

/** NotificationPermissionsPlugin **/
export default class NotificationPermissionsPlugin implements FlutterPlugin, MethodCallHandler {
  private channel: MethodChannel | null = null;

  private context: common.UIAbilityContext | null = null;

  constructor() {
  }

  getUniqueClassName(): string {
    return "NotificationPermissionsPlugin"
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.channel = new MethodChannel(binding.getBinaryMessenger(), "notification_permissions");
    this.channel.setMethodCallHandler(this)
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    if (this.channel != null) {
      this.channel.setMethodCallHandler(null)
    }
  }

  onAttachedToAbility(binding: AbilityPluginBinding): void {
    this.context = binding.getAbility().context;
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    if (call.method == "getNotificationPermissionStatus") {
      // let sound = call.argument("sound") as boolean ?? false;
      // let alert = call.argument("alert") as boolean ?? false;
      // let badge = call.argument("badge") as boolean ?? false;
      notificationManager.requestEnableNotification(this.context, (err: BusinessError): void => {
        if (err) {
          console.error(`requestEnableNotification failed, code is ${err.code}, message is ${err.message}`);
          this.getNotificationStatus(result);
        } else {
          console.info("requestEnableNotification success");
          this.getNotificationStatus(result);
        }
      });

    } else if (call.method == "requestNotificationPermissions") {
      this.getNotificationStatus(result);
    } else {
      result.notImplemented()
    }
  }

  getNotificationStatus( result: MethodResult): void {
    let enabled = notificationManager.isNotificationEnabledSync();
    console.info(`isNotificationEnabledSync success, data is : ${JSON.stringify(enabled)}`);
    if(enabled){
      result.success("granted");
    }else{
      result.success("denied");
    }
  }
}