//
//  UIImagePickerController+Extension.swift
//  RxSwiftOperator
//
//  Created by wangjiayu on 2023/1/7.
//

import UIKit
import RxSwift
import RxCocoa

func dismissController(_ viewController:UIViewController, animated: Bool) {
  if viewController.isBeingDismissed || viewController.isBeingPresented {
    DispatchQueue.main.async {
      dismissController(viewController, animated: animated)
    }
    return
  }
  
  if viewController.presentationController != nil {
    viewController.dismiss(animated: animated)
  }
}

extension Reactive where Base : UIImagePickerController {
  ///代理委托
  var pickerDelegate:DelegateProxy<UIImagePickerController,UIImagePickerControllerDelegate & UINavigationControllerDelegate> {
    return RxImagePickerDelegateProxy.proxy(for: base)
  }
  
  ///图片选择完毕代理方法的封装
  var didFinishedPickerInfomation:Observable<[String:Any]> {
    return pickerDelegate
      .methodInvoked(#selector(UIImagePickerControllerDelegate.imagePickerController(_:didFinishPickingMediaWithInfo:)))
      .map({try castOrThrow(Dictionary<String,Any>.self, $0[1])})
  }
  
  ///取消图片选择代理方法的封装
  var didCancle:Observable<Void> {
    return pickerDelegate
      .methodInvoked(#selector(UIImagePickerControllerDelegate.imagePickerControllerDidCancel(_:)))
      .map{_ in ()}
  }
  
  private func castOrThrow<T>(_ resultType:T.Type, _ object:Any) throws -> T {
    guard let value = object as? T else {
       throw RxCocoaError.castingError(object: object, targetType: resultType)
    }
    return value
  }
  
  static func createWithParent(_ parent:UIViewController?,
                               animated:Bool = true,
                               configureImagePicker:@escaping (UIImagePickerController) throws -> () = {x in })
  														  -> Observable<UIImagePickerController> {
      return Observable.create { observer in
        let imgPicker = UIImagePickerController()
        let dismissDisposable = Observable
          .merge(
            imgPicker.rx.didFinishedPickerInfomation.map({_ in ()}),
            imgPicker.rx.didCancle
          )
          .subscribe { _ in
            observer.onCompleted()
          }
        
        do {
          try configureImagePicker(imgPicker)
        } catch let err {
          observer.onError(err)
          return Disposables.create()
        }
        
        guard let parent = parent else {
          observer.onCompleted()
          return Disposables.create()
        }
        
        parent.present(imgPicker, animated: animated)
        observer.onNext(imgPicker)
        
        return Disposables.create(dismissDisposable, Disposables.create {
          dismissController(imgPicker, animated:animated)
        })
      }
  }
}
