//
//  MJRefreshComponent+Extension.swift
//  RxSwiftOperator
//
//  Created by wangjiayu on 2023/1/5.
//

import RxSwift
import RxCocoa
import MJRefresh

///对MJRefreshComponent增加rx扩展
extension Reactive where Base : MJRefreshComponent {
  
  ///正在刷新事件
  var refreshing:ControlEvent<Void> {
    let source:Observable<Void> = Observable<Void>.create { [weak control = self.base] observer in
      control?.refreshingBlock = {
        observer.onNext(())
      }
      return Disposables.create()
    }
    return ControlEvent(events: source)
  }
  
  ///停止刷新
  var endRefreshing:Binder<Bool> {
    return Binder(base) { refresh, isEnd in
      if isEnd {
        refresh.endRefreshing()
      }
    }
  }
}
