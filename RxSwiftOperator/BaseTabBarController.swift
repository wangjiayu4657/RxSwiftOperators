//
//  BaseTabBarController.swift
//  RxSwiftOperator
//
//  Created by wangjiayu on 2023/1/7.
//

import UIKit

class BaseTabBarController: UITabBarController {

  override func viewDidLoad() {
    super.viewDidLoad()
    
    initCtrl()
    initTabBar()
    view.backgroundColor = .orange
  }
  
  private func initCtrl() {
    let refreshCtrl = RefreshViewController()
    let refreshCtrlNav = BaseNavigationController(rootViewController: refreshCtrl)
    
    let imagePickerCtrl = ImageViewController()
    let imagePickerCtrlNav = BaseNavigationController(rootViewController: imagePickerCtrl)
    
    viewControllers = [imagePickerCtrlNav,refreshCtrlNav]
  }
  
  private func initTabBar() {
    let normalImgs = ["tabbar_home_normal","tabbar_news_normal"]//,"tabbar_find_normal","tabbar_find_normal","tabbar_me_normal"]
    let selectImgs = ["tabbar_home_select","tabbar_news_select"]//,"tabbar_find_select","tabbar_find_select","tabbar_me_select"]
    let itemTitles = ["首页","消息"]//,"理财","发现","我的"]
    
    for (i,text) in itemTitles.enumerated() {
        let item = tabBar.items?[i]
        item?.tag = i
        item?.title = text
        item?.image = UIImage(named: normalImgs[i])?.withRenderingMode(.alwaysOriginal)
        item?.selectedImage = UIImage(named: selectImgs[i])?.withRenderingMode(.alwaysOriginal)
    }
    
    tabBar.tintColor = UIColor(hex: "#108DE9")
    tabBar.backgroundColor = UIColor(hex: "#F7F7F7")
  }
  
//  override var tabBar: UITabBar {
//    let homeItem = UITabBarItem(title: "首页", image: UIImage(named: "home"), selectedImage: UIImage(named: "homeSelected"))
//    let otherItem = UITabBarItem(title: "其他", image: UIImage(named: "home"), selectedImage: UIImage(named: "homeSelected"))
//    self.tabBar.items = [homeItem, otherItem]
//    return self.tabBar
//  }
  
  
}
