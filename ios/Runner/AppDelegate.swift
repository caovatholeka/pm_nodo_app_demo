import Flutter
import UIKit
import GoogleMaps
import Firebase
import FirebaseCore
import FirebaseMessaging
import UserNotifications
import flutter_local_notifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
                GeneratedPluginRegistrant.register(with: registry)}
      
      FirebaseApp.configure()
      
      if #available(iOS 10.0, *) {
        UNUserNotificationCenter.current().delegate = self
      }
      
      application.registerForRemoteNotifications()
      
   // Google map : thay bang key cua app
      GMSServices.provideAPIKey("AIzaSyA9jScovsC03gN6YN5MRq8T1UtdgTIkfcI")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    override func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
      ) {
        super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
        Messaging.messaging().apnsToken = deviceToken
      }
    
    @available(iOS 10.0, *)
           override func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
               completionHandler([.alert, .sound])
           }
}
