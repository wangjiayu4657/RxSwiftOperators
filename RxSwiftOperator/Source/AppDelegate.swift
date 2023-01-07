//
//  AppDelegate.swift
//  RxSwiftOperator
//
//  Created by wangjiayu on 2022/12/14.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    gotoMainController()
    
    return true
  }
}


extension AppDelegate {
  private func gotoMainController() {
    window = UIWindow(frame: UIScreen.main.bounds)
    window?.backgroundColor = .white
    window?.rootViewController = BaseTabBarController()
    window?.makeKeyAndVisible()
  }
}
