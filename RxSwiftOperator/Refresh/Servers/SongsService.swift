//
//  File.swift
//  RxSwiftOperator
//
//  Created by wangjiayu on 2023/1/5.
//

import RxCocoa
import RxSwift

class SongService {
  
  //模拟请求歌曲数据
  static func songsRequest() -> Observable<[MusicModel]> {
    print("正在刷新数据")
    
    let singers = ["陈奕迅","S.H.E","陈洁仪","朴树","张杰","刀郎","萨顶顶","HITA","金玟岐","李宗南"]
    let songs = ["无条件","你曾是少年","从前的我","在木星","人间烟火","花花的世界","左手指月","赤岭","思美人兮","狂浪生"]
    
    var source = [MusicModel]()
    let items = (0..<5).map { _ in
      let index = Int(arc4random()) % 10
      let song = songs[index]
      let singer = singers[index]
      return SongModel(name: song, singer: singer)
    }
    source.append(MusicModel(items: items))
    
    return Observable.just(source).delay(.seconds(3),scheduler: MainScheduler.instance)
  }
  
  static func loadMoreRequest() -> Observable<[MusicModel]> {
    print("正在加载数据")
    
    let singers = ["陈奕迅","S.H.E","陈洁仪","朴树","张杰","刀郎","萨顶顶","HITA","金玟岐","李宗南"]
//    let songs = ["无条件","你曾是少年","从前的我","在木星","人间烟火","花花的世界","左手指月","赤岭","思美人兮","狂浪生"]
    
    var source = [MusicModel]()
    let items = (0..<5).map { _ in
      let index = Int(arc4random()) % 10
//      let song = songs[index]
      let singer = singers[index]
      return SongModel(name: singer, singer: singer)
    }
    source.append(MusicModel(items: items))
    
    return Observable.just(source).delay(.seconds(3),scheduler: MainScheduler.instance)
  }
}
