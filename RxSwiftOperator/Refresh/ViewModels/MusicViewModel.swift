//
//  SongViewModel.swift
//  RxSwiftOperator
//
//  Created by wangjiayu on 2023/1/5.
//

import UIKit
import RxSwift
import RxCocoa


class MusicViewModel {
  let source = BehaviorRelay<[MusicModel]>(value: [])
  var endHeaderRefreshing:Driver<Bool>
  var endFooterRefreshing:Driver<Bool>
  
  init(input:(startRefresh:Driver<Void>,loadMoreRefresh:Driver<Void>),disbag:DisposeBag) {
    
    let refreshData = input.startRefresh
      .startWith(())
      .flatMapLatest({SongService.songsRequest()})
      
    let loadMoreData = input.loadMoreRefresh
      .startWith(())
      .flatMapLatest({SongService.loadMoreRequest()})
    
    endHeaderRefreshing = refreshData.map({!$0.isEmpty})
    endFooterRefreshing = loadMoreData.map({!$0.isEmpty})
    
    refreshData
      .drive {[weak self] items in
      	self?.source.accept(items)
      }
      .disposed(by: disbag)
    
    loadMoreData
      .drive { [unowned self] items in
        self.source.accept(self.source.value + items)
      }
      .disposed(by: disbag)
  }
}


