//
//  String+Extension.swift
//  RxSwiftOperator
//
//  Created by wangjiayu on 2023/1/3.
//

import UIKit

extension String {
  //字符串的url地址转义
   var URLEscaped: String {
       return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
   }
}
