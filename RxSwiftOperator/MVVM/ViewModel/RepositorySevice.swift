//
//  RepositorySevice.swift
//  RxSwiftOperator
//
//  Created by wangjiayu on 2022/12/30.
//

import UIKit
import RxCocoa
import RxSwift


class RepositorySevice {
  static func repository(query:String) -> Driver<Repositories> {
    return Provider.rx.request(.repositories(query))
      .filterSuccessfulStatusCodes()
      .mapObject(Repositories.self)
      .asDriver(onErrorDriveWith: Driver<Repositories>.empty())
  }
}
