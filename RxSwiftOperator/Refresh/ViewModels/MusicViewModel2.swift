//
//  MusicViewModel2.swift
//  RxSwiftOperator
//
//  Created by wangjiayu on 2023/1/6.
//  上拉加载和下拉刷新互不影响

import UIKit
import RxSwift
import RxCocoa

class MusicViewModel2: NSObject {
  
  let source = BehaviorRelay<[MusicModel]>(value: [])
  var endHeaderRefreshing:Observable<Bool>
  var endFooterRefreshing:Observable<Bool>
 
  init(
    input:(
      headerRefresh:Observable<Void>,
      footerRefresh:Observable<Void>
    ),
    disbag:DisposeBag) {
    
    let headerRefreshData = input.headerRefresh
      .startWith(())
      .flatMapLatest { SongService.songsRequest() }
      .share(replay: 1, scope: .forever)

    let footerRefreshData = input.footerRefresh
      .flatMapLatest { SongService.loadMoreRequest() }
      .share(replay: 1,scope: .forever)

    endHeaderRefreshing = headerRefreshData.map({_ in true})
    endFooterRefreshing = footerRefreshData.map({_ in true })

    super.init()
      
    headerRefreshData
      .subscribe(onNext: {[weak self] items in
        self?.source.accept(items)
      })
      .disposed(by: disbag)

    footerRefreshData
      .subscribe(onNext: { [unowned self] items in
        self.source.accept(self.source.value + items)
      })
      .disposed(by: disbag)
  }
}
