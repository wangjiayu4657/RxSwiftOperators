//
//  ViewController.swift
//  RxSwiftOperator
//
//  Created by wangjiayu on 2022/12/14.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class ViewController: UIViewController {
  
  private lazy var disbag = DisposeBag()
  private lazy var viewModel = MusicViewModel()
  private lazy var tableView:UITableView = {
    let tableView = UITableView(frame: .zero, style: .plain)
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "musicCellID")
    return tableView
  }()
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "RxSwift 操作符练习"
    view.backgroundColor = .orange

    buildSubViews()
    bindData()
  }
}

// MARK: - 设置UI
extension ViewController {
  private func buildSubViews() {
    view.addSubview(tableView)
    tableView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
}

extension ViewController {
  private func bindData() {
    viewModel.musics
      .bind(to: tableView.rx.items(cellIdentifier: "musicCellID")){ _, music, cell in
        cell.textLabel?.text = music.name
      }
      .disposed(by: disbag)
    
    tableView.rx
      .modelSelected(Music.self)
      .subscribe(onNext: {[weak self] in
        print("选中的歌曲名称: \($0.name)")
        let contrl = DatePickerViewController()
        self?.navigationController?.pushViewController(contrl, animated: true)
      })
      .disposed(by: disbag)
  }
}


struct MusicViewModel {
  let musics = Observable.just([
  	Music(name: "无条件", singer: "陈奕迅"),
    Music(name: "你曾是少年", singer: "S.H.E"),
    Music(name: "从前的我", singer: "陈洁仪"),
    Music(name: "在木星", singer: "朴树")
  ])
}

struct Music {
  var name:String = ""
  var singer:String = ""
  
  init(name: String, singer: String) {
    self.name = name
    self.singer = singer
  }
}
