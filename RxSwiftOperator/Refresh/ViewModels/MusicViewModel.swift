//
//  SongViewModel.swift
//  RxSwiftOperator
//
//  Created by wangjiayu on 2023/1/5.
//  上拉加载时取消下拉刷新, 下拉刷新时取消上拉加载

import UIKit
import RxSwift
import RxCocoa


class MusicViewModel {
  let source = BehaviorRelay<[MusicModel]>(value: [])
  var endHeaderRefreshing:Observable<Bool>
  var endFooterRefreshing:Observable<Bool>
  
  init(service:BehaviorSubject<PublishSubject<Bool>>,disbag:DisposeBag) {
    //true:下拉刷新 false:上拉加载
    var isHaderRefreshing = true
    service
      .switchLatest()
      .map({$0})
      .subscribe(onNext: { isHeaderRefresh in
        isHaderRefreshing = isHeaderRefresh
       })
      .disposed(by: disbag)

    //开始请求数据,下拉刷新或上拉加载
    let freshData = service
      .switchLatest()
      .flatMapLatest({$0 ? SongService.songsRequest() : SongService.loadMoreRequest()})
      .share(replay: 1, scope: .forever)

    endHeaderRefreshing = freshData.map({_ in true})
    endFooterRefreshing = freshData.map({_ in true})

    freshData.subscribe(onNext: {[unowned self] items in
      if isHaderRefreshing {
        self.source.accept(items)
      } else {
        self.source.accept(self.source.value + items)
      }
    })
    .disposed(by: disbag)
  }
}
