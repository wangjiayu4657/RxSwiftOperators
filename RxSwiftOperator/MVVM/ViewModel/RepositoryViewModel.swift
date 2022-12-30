//
//  RepositoryViewModel.swift
//  RxSwiftOperator
//
//  Created by wangjiayu on 2022/12/29.
//

import UIKit
import RxSwift
import RxCocoa
import ObjectMapper
import Moya_ObjectMapper

class RepositoryViewModel {
	//输入信号
  private let search:Driver<String>
  
  //输出信号
  let searchResult:Driver<Repositories>
  let repositories:Driver<[Repository]>
  let cleanResult:Driver<Void>
  let navigatorTitle:Driver<String>
  
  init(search: Driver<String>) {
    self.search = search
   
    self.searchResult = search
      .filter{!$0.isEmpty}
      .flatMapLatest { RepositorySevice.repository(query: $0)}
    
    //生成清空结果动作序列
    self.cleanResult = search.filter({$0.isEmpty}).map{_ in Void()}
    
    //生产查询结果里的资源列表序列(如果查询到结果则返回结果, 如果是清空数据则返回空数组)
    self.repositories = Driver.merge(searchResult.map{$0.items ?? []},cleanResult.map{[]})
      
    //生成导航栏标题序列(如果查询到结果则返回数量,如果是清空数据则返回默认标题)
    self.navigatorTitle = Driver.merge(searchResult.map{"共有: \($0.totalCount)个结果"},cleanResult.map{"hanggle.com"})
  }
}
