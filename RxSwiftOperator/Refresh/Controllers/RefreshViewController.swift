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
//    tableView.mj_header = MJRefreshNormalHeader()
//    tableView.mj_footer = MJRefreshAutoNormalFooter()
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "musicCellID")
    
    tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: {[unowned self] in
      self.subject.onNext(self.headerSubject)
      self.headerSubject.onNext(true)
      self.tableView.mj_footer?.endRefreshing()
    })

    tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: {[unowned self] in
      self.subject.onNext(self.footerSubject)
      self.footerSubject.onNext(false)
      self.tableView.mj_header?.endRefreshing()
    })

    tableView.mj_header?.beginRefreshing()
    return tableView
  }()
  
  private lazy var dataSource = RxTableViewSectionedReloadDataSource<MusicModel>(
    configureCell: {(_,tb,indexPath,music) in
      let cell = tb.dequeueReusableCell(withIdentifier: "musicCellID")
      cell?.textLabel?.text = music.name
      return cell ?? UITableViewCell()
    }
  )
  
  private lazy var headerSubject = PublishSubject<Bool>()
  private lazy var footerSubject = PublishSubject<Bool>()
  private lazy var subject = BehaviorSubject(value: headerSubject)
  
  private lazy var viewModel = MusicViewModel(service: subject, disbag: disbag)
  
//  private lazy var viewModel = MusicViewModel2(
//    input: (
//      headerRefresh: tableView.mj_header!.rx.refreshing.asObservable(),
//      footerRefresh: tableView.mj_footer!.rx.refreshing.asObservable()
//    ),
//    disbag: disbag
//  )
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.title = "RxSwift 操作符练习"

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
      .bind(to: tableView.mj_header!.rx.endRefreshing)
      .disposed(by: disbag)
    
    viewModel
      .endFooterRefreshing
      .bind(to: tableView.mj_footer!.rx.endRefreshing)
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





