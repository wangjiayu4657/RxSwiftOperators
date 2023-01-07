//
//  RxImagePickerDelegateProxy.swift
//  RxSwiftOperator
//
//  Created by wangjiayu on 2023/1/7.
//

import UIKit
import RxCocoa
import RxSwift

class RxImagePickerDelegateProxy :
  DelegateProxy<UIImagePickerController,UIImagePickerControllerDelegate & UINavigationControllerDelegate>,
  DelegateProxyType,
  UIImagePickerControllerDelegate,
  UINavigationControllerDelegate {
  
  init(imagePicker:UIImagePickerController) {
    super.init(parentObject: imagePicker, delegateProxy: RxImagePickerDelegateProxy.self)
  }
  
  static func registerKnownImplementations() {
    register {RxImagePickerDelegateProxy(imagePicker: $0)}
  }
  
  static func currentDelegate(for object: UIImagePickerController) -> (UIImagePickerControllerDelegate & UINavigationControllerDelegate)? {
    return object.delegate
  }
  
  static func setCurrentDelegate(_ delegate: (UIImagePickerControllerDelegate & UINavigationControllerDelegate)?, to object: UIImagePickerController) {
    object.delegate = delegate
  }
}
