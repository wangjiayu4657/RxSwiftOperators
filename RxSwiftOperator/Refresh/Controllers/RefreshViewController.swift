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
import RxDataSources
import MJRefresh


class RefreshViewController: UIViewController {
  
  private lazy var disbag = DisposeBag()
  
  private lazy var tableView:UITableView = {
    let tableView = UITableView(frame: .zero, style: .plain)
    tableView.mj_header = MJRefreshNormalHeader()
    tableView.mj_footer = MJRefreshAutoNormalFooter()
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "musicCellID")
    return tableView
  }()
  
  private lazy var dataSource = RxTableViewSectionedReloadDataSource<MusicModel>(
    configureCell: {(_,tb,indexPath,music) in
      let cell = tb.dequeueReusableCell(withIdentifier: "musicCellID")
      cell?.textLabel?.text = music.name
      return cell ?? UITableViewCell()
    }
  )
  
  private lazy var viewModel = MusicViewModel(input: (
    startRefresh: tableView.mj_header!.rx.refreshing.asDriver(),
    loadMoreRefresh: tableView.mj_footer!.rx.refreshing.asDriver()
  ), disbag: disbag)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "RxSwift 操作符练习"

    buildSubViews()
    bindData()
  }
  
  @IBAction func jumpClick(_ sender: UIBarButtonItem) {
    let registerCtrl = RegisterViewController()
    navigationController?.pushViewController(registerCtrl, animated: true)
  }
}

// MARK: - 设置UI
extension RefreshViewController {
  private func buildSubViews() {
    view.addSubview(tableView)
    tableView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
}

//绑定数据
extension RefreshViewController {
  private func bindData() {
    viewModel
      .source
      .bind(to: tableView.rx.items(dataSource: dataSource))
      .disposed(by: disbag)
    
    viewModel
      .endHeaderRefreshing
      .drive(tableView.mj_header!.rx.endRefreshing)
      .disposed(by: disbag)
    
    viewModel
      .endFooterRefreshing
      .drive(tableView.mj_footer!.rx.endRefreshing)
      .disposed(by: disbag)
    
    tableView.rx
      .modelSelected(SongModel.self)
      .subscribe(onNext: {[weak self] in
        print("选中的歌曲名称: \($0.name)")
        let contrl = RepositioryViewController()
        self?.navigationController?.pushViewController(contrl, animated: true)
      })
      .disposed(by: disbag)
  }
}





