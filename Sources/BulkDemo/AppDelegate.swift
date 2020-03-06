//
//  AppDelegate.swift
//  BulkDemo
//
//  Created by muukii on 2020/02/03.
//

import UIKit

import Bulk
import BulkLogger

let logger = Logger(context: "", sinks: [
  BulkSink<LogData>(
    buffer: MemoryBuffer.init(size: 10).asAny(),
    targets: [
      TargetUmbrella.init(
        transform: LogBasicFormatter().format,
        targets: [
          LogConsoleTarget.init().asAny()
        ]
      ).asAny(),
      OSLogTarget(subsystem: "BulkDemo", category: "Demo").asAny()
    ]
  )
    .asAny()
])

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {    
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
            
    for i in 0..<20 {
      logger.info("Hello \(i)")
    }

    
    return true
  }

  // MARK: UISceneSession Lifecycle

  func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
  }

  func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
  }


}

