//
//  RegisterService.swift
//  RxSwiftOperator
//
//  Created by wangjiayu on 2022/12/30.
//

import UIKit
import RxSwift
import RxCocoa

class RegisterService {

  ///查询用户名是否有效
  private static func usernameAvailable(username:String) -> Driver<Bool> {
    Provider.rx
      .request(.usernameAvailable(username))
      .map{$0.statusCode != 404}
      .asDriver(onErrorDriveWith: Driver<Bool>.just(false))
  }
  
  ///注册是否成功
  static func signup(username:String, password:String) -> Driver<Bool> {
    let signupResult = arc4random() % 3 == 0 ? false : true
    return Driver.just(signupResult).delay(.milliseconds(1500))
  }
  
  ///验证用户名
  static func validateUserName(username:String) -> Driver<ValidationResult> {
    //判断用户名是否为空
    guard username.isEmpty == false else {
      return Driver.just(.empty)
    }
    
    //判断用户名是否只有数字和字母
    guard username.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) == nil else {
      return Driver.just(.failed(msg: "用户名只能包含数字和字母"))
    }
    
    //发起网络请求查询用户名是否存在
    return usernameAvailable(username: username)
      .map({ $0 ? .ok(msg:"用户名可用") : .failed(msg:"用户名已存在")})
      .startWith(.validating)
  }
  
  ///验证密码是否有效
  static func validatePassword(password:String) -> ValidationResult {
    guard password.isEmpty == false else {
      return .empty
    }
    
    guard password.count >= 6 else {
      return .failed(msg: "密码至少需要6个字符")
    }
    
    return .ok(msg: "密码有效")
  }
  
  ///验证两次密码输入是否一致
  static func validateRepeatedPassword(pwd:String, rPwd:String) -> ValidationResult {
    guard rPwd.isEmpty == false else {
      return .empty
    }
    
    guard pwd == rPwd else {
      return .failed(msg: "两次密码输入的不一致")
    }
    
    return .ok(msg: "密码有效")
  }
}
