//
//  UILabel+Extension.swift
//  RxSwiftOperator
//
//  Created by wangjiayu on 2023/1/4.
//

import UIKit
import RxSwift
import RxCocoa


extension Reactive where Base : UILabel {
  var validateResult:Binder<ValidationResult> {
    return Binder(base) { label, result in
      label.text = result.description
      label.textColor = result.textColor
    }
  }
}
