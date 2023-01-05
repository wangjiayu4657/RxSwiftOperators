//
//  Provider.swift
//  RxSwiftOperator
//
//  Created by wangjiayu on 2022/12/29.
//

import UIKit
import Moya

private let timeoutClosure = {(endpoint: Endpoint, closure: MoyaProvider<Api>.RequestResultClosure) -> Void in
    if var urlRequest = try? endpoint.urlRequest() {
      	print("urlRequest.url == \(urlRequest.url)")
        urlRequest.timeoutInterval = 10
        closure(.success(urlRequest))
    } else {
        closure(.failure(MoyaError.requestMapping(endpoint.url)))
    }
}

let Provider = MoyaProvider<Api>(requestClosure: timeoutClosure)

//请求分类
public enum Api {
  case repositories(String) //查询资源库
  case usernameAvailable(String) //用户名是否可用
}

extension Api : TargetType {
  public var baseURL: URL {
    switch self {
      case .usernameAvailable: return URL(string: "https://github.com")!
      default: return URL(string: "https://api.github.com")!
    }
  }
  
  public var path: String {
    switch self {
      case .repositories: return "/search/repositories"
      case .usernameAvailable: return ""
    }
  }
  
  public var method: Moya.Method {
    return .get
  }
  
  public var task: Moya.Task {
    var paramters:[String:Any] = [:]
    switch self {
      case .repositories(let query):
        paramters["q"] = query
        paramters["sort"] = "stars"
        paramters["order"] = "desc"
      case .usernameAvailable(let username):
        paramters["username"] = username
    }
    return .requestParameters(parameters: paramters, encoding: URLEncoding.default)
  }
  
  public var sampleData: Data {
    return "{}".data(using: .utf8)!
  }
  
  public var headers: [String : String]? {
    return nil
  }
}
