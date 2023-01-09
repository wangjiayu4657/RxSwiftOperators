//
//  BaseNavigationController.swift
//  RxSwiftDemo
//
//  Created by wangjiayu on 2022/6/29.
//

import UIKit

class BaseNavigationController: UINavigationController {

  override func viewDidLoad() {
    super.viewDidLoad()

    if #available(iOS 13.0, *) {
      let appearance = UINavigationBarAppearance()
      appearance.shadowImage = UIImage()
      appearance.backgroundImage = UIImage(named: "nav_bg")!
      appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]

      navigationBar.isTranslucent = false
      navigationBar.standardAppearance = appearance
      navigationBar.scrollEdgeAppearance = appearance
    } else {
      navigationBar.shadowImage = UIImage()
      navigationBar.isTranslucent = false
      navigationBar.setBackgroundImage(UIImage(named: "nav_bg"), for: UIBarMetrics.default)
      navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
    }
  }
}


extension BaseNavigationController {
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return UIStatusBarStyle.lightContent
  }
}
