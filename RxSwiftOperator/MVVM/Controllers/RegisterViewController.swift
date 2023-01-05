//
//  RegisterViewController.swift
//  RxSwiftOperator
//
//  Created by wangjiayu on 2022/12/30.
//

import UIKit
import RxCocoa
import RxSwift
import MBProgressHUD

class RegisterViewController: UIViewController {
  private lazy var userInputView:InputView = InputView(placeholder: "用户名")
  private lazy var pwdInputView:InputView = InputView(placeholder: "密码")
  private lazy var rPwdInputView:InputView = InputView(placeholder: "再次输入密码")
  
  private lazy var registerBtn:UIButton = {
    let registerBtn = UIButton(type: .custom)
    registerBtn.setTitle("注册", for: .normal)
    registerBtn.setTitleColor(.white, for: .normal)
    registerBtn.backgroundColor = UIColor.blue
    registerBtn.layer.cornerRadius = 8
    return registerBtn
  }()
  
  private lazy var hud = MBProgressHUD.showAdded(to: self.view, animated: true)
  private lazy var disbag = DisposeBag()
  private lazy var viewModel = RegisterViewModel(
    																username: userInputView.input,
                                    password: pwdInputView.input,
                                   rPassword: rPwdInputView.input,
                                    loginTap: registerBtn.rx.tap.asSignal())
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.title = "注册"
    view.backgroundColor = UIColor.white
    
    buildSubViews()
    bindData()
  }
}

// MARK: - 设置UI
extension RegisterViewController {
  private func buildSubViews() {
    view.addSubview(userInputView)
    userInputView.snp.makeConstraints { make in
      make.top.equalTo(15)
      make.left.equalTo(20)
      make.right.equalTo(-20)
      make.height.equalTo(70)
    }
    
    view.addSubview(pwdInputView)
    pwdInputView.snp.makeConstraints { make in
      make.top.equalTo(userInputView.snp.bottom).offset(5)
      make.left.height.right.equalTo(userInputView)
    }
    
    view.addSubview(rPwdInputView)
    rPwdInputView.snp.makeConstraints { make in
      make.top.equalTo(pwdInputView.snp.bottom).offset(5)
      make.left.height.right.equalTo(pwdInputView)
    }
    
    view.addSubview(registerBtn)
    registerBtn.snp.makeConstraints { make in
      make.top.equalTo(rPwdInputView.snp.bottom).offset(30)
      make.left.right.equalTo(rPwdInputView)
      make.height.equalTo(56)
    }
  }
}

extension RegisterViewController {
  private func bindData() {
    viewModel
      .validateUsername
      .drive(userInputView.tipLabel.rx.validateResult)
      .disposed(by: disbag)
    
    viewModel
      .validatePassword
      .drive(pwdInputView.tipLabel.rx.validateResult)
      .disposed(by: disbag)
    
    viewModel
      .validateRepeatePwd
      .drive(rPwdInputView.tipLabel.rx.validateResult)
      .disposed(by: disbag)
  	
    viewModel
      .btnEnable
      .drive(onNext: {[weak self] isEnable in
        self?.registerBtn.isEnabled = isEnable
        self?.registerBtn.alpha = isEnable ? 1.0 : 0.3
      })
      .disposed(by: disbag)
    
    viewModel
      .signingIn
      .map({!$0})
      .drive(hud.rx.isHidden)
      .disposed(by: disbag)
    
    viewModel
      .registerResult
      .drive(onNext: {[weak self] msg in
        self?.showAlertView(msg: msg)
      })
      .disposed(by: disbag)
  }
  
  private func showAlertView(msg:String) {
    let alert = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
    let okAction = UIAlertAction(title: "确定", style: .default)
    let cancleAction = UIAlertAction(title: "取消", style: .cancel)
    alert.addAction(okAction)
    alert.addAction(cancleAction)
    self.navigationController?.present(alert, animated: true)
  }
}
