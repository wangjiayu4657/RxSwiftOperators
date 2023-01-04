//
//  InputView.swift
//  RxSwiftOperator
//
//  Created by wangjiayu on 2023/1/3.
//

import UIKit
import RxSwift
import RxCocoa

class InputView: UIView {

  private lazy var textFiled:UITextField = {
    let textFiled = UITextField(frame: .zero)
    textFiled.layer.borderWidth = 1
    textFiled.layer.borderColor = UIColor(hex: "#F7F7F7")?.cgColor
    return textFiled
  }()
  
  lazy var tipLabel:UILabel = {
    let tipLabel = UILabel(frame: .zero)
    tipLabel.font = UIFont.systemFont(ofSize: 14)
    return tipLabel
  }()
  
  
  var input:Driver<String> {
    return textFiled.rx.text.orEmpty.asDriver().throttle(.milliseconds(300)).distinctUntilChanged()
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    buildSubViews()
  }
  
  convenience init(placeholder:String?="") {
    self.init()
    
    textFiled.placeholder = placeholder
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - 设置UI
extension InputView {
  private func buildSubViews() {
    addSubview(textFiled)
    textFiled.snp.makeConstraints { make in
      make.top.equalTo(15)
      make.left.equalTo(20)
      make.right.equalTo(-20)
      make.height.equalTo(40)
    }
    
    addSubview(tipLabel)
    tipLabel.snp.makeConstraints { make in
      make.top.equalTo(textFiled.snp.bottom).offset(5)
      make.left.right.equalTo(textFiled)
      make.height.equalTo(30)
    }
  }
}
