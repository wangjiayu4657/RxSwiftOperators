//
//  MusicModel.swift
//  RxSwiftOperator
//
//  Created by wangjiayu on 2023/1/5.
//

import UIKit
import RxDataSources

struct SongModel {
  var name:String
  var singer:String
  
  init(name: String, singer: String) {
    self.name = name
    self.singer = singer
  }
}

struct MusicModel {
  var header:String = ""
  var items:[Item]
}

extension MusicModel : SectionModelType {
  typealias Item = SongModel

  init(original: MusicModel, items: [SongModel]) {
    self = original
    self.items = items
  }
}
