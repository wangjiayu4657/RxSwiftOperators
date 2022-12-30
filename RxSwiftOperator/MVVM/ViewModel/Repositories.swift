//
//  Repositories.swift
//  RxSwiftOperator
//
//  Created by wangjiayu on 2022/12/29.
//

import UIKit
import ObjectMapper
import RxDataSources

struct Repositories: Mappable {
  var totalCount: Int = 0
  var incompleteResults: Bool = false
  var items: [Repository]?
  
  init?(map: Map) {}
  
  mutating func mapping(map: Map) {
    totalCount <- map["total_count"]
    incompleteResults <- map["incompleteResults"]
    items <- map["items"]
  }
}

struct Repository : Mappable {
  var id:Int = 0
  var name:String = ""
  var fullName:String = ""
  var htmlUrl:String = ""
  var description:String = ""
  
  init?(map: Map) {}
  
  mutating func mapping(map: Map) {
    id <- map["id"]
    name <- map["name"]
    fullName <- map["fullName"]
    htmlUrl <- map["htmlUrl"]
    description <- map["description"]
  }
}

extension Repository : SectionModelType {
  typealias Item = Repository
  
  var items:[Repository] {
    return [self]
  }
  
  init(original:Repository, items:[Item]) {
    self = original
  }
}
