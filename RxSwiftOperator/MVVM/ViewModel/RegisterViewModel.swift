//
//  RegisterViewModel.swift
//  RxSwiftOperator
//
//  Created by wangjiayu on 2023/1/3.
//

import UIKit
import RxSwift
import RxCocoa

enum ValidationResult {
	case validating 					//正在验证中
  case empty 						  	//输入为空
  case ok(msg:String) 	  	//验证通过
  case failed(msg:String) 	//验证失败
}

extension ValidationResult {
  //对应不同的验证结果返回验证是成功还是失败
  var isValid:Bool {
    switch self {
      case .ok: return true
      default: return false
    }
  }
  
  //对应不同的验证结果返回不同的文字颜色
  var textColor:UIColor {
    switch self {
      case .validating: return .gray
      case .empty: return .black
      case .ok: return .green
      case .failed: return .red
    }
  }
}

extension ValidationResult : CustomStringConvertible {
  //对应不同的验证结果返回不同的文字描述
  var description: String {
    switch self {
      case .validating: return "正在验证中..."
      case .empty: return ""
      case let .ok(msg): return msg
      case let .failed(msg): return msg
    }
  }
}

class RegisterViewModel {

  let validateUsername:Driver<ValidationResult>
  let validatePassword:Driver<ValidationResult>
  let validateRepeatePwd:Driver<ValidationResult>
  
  let btnEnable:Driver<Bool>
  let registerResult:Driver<String>
  
  
  init(username: Driver<String>,
       password: Driver<String>,
      rPassword: Driver<String>,
       loginTap: Signal<Void>) {
    
    validateUsername = username
      .flatMapLatest({
        RegisterService
          .validateUserName(username: $0)
          .asDriver(onErrorJustReturn: .failed(msg: "服务器发生错误"))
      })
      
    validatePassword = password
      .map{RegisterService.validatePassword(password: $0)}
    
    validateRepeatePwd = Driver
      .combineLatest(password, rPassword, resultSelector: RegisterService.validateRepeatedPassword)
    
    btnEnable = Driver
      .combineLatest(validateUsername, validatePassword, validateRepeatePwd) {$0.isValid && $1.isValid && $2.isValid}
      .distinctUntilChanged()
    
    //获取最新的用户名和密码
    let usernameAndPassword = Driver.combineLatest(username, password) { (userName:$0, pwd:$1) }
    
    registerResult = loginTap
      .withLatestFrom(usernameAndPassword)
      .flatMapLatest({
        RegisterService
        .signup(username: $0.userName, password: $0.pwd)
        .asDriver(onErrorJustReturn: false)
      })
      .map({$0 ? "注册成功" : "注册失败"})
  }
}
