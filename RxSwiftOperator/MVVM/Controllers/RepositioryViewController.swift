//
//  RepositioryViewController.swift
//  RxSwiftOperator
//
//  Created by wangjiayu on 2022/12/30.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class RepositioryViewController: UIViewController {

  private lazy var searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 56))
  private lazy var tableView:UITableView = {
    let tableView = UITableView(frame: .zero, style: .plain)
    tableView.tableHeaderView = searchBar
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "kCellID")
    return tableView
  }()
  
  private lazy var disbag = DisposeBag()
  
  private lazy var viewModel = RepositoryViewModel(search: searchBar.rx.text.orEmpty.asDriver().throttle(.milliseconds(300)).distinctUntilChanged())
  
  private lazy var dataSource = RxTableViewSectionedReloadDataSource<Repository>(
    configureCell: {_,tb,indexPath,element in
      let cell = tb.dequeueReusableCell(withIdentifier: "kCellID")
      cell?.textLabel?.text = element.name
      return cell ?? UITableViewCell()
    }
  )
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    buildSubViews()
    bindData()
  }
}

// MARK: - 设置UI
extension RepositioryViewController {
  private func buildSubViews() {
    view.addSubview(tableView)
    tableView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
}

// MARK: - 绑定数据
extension RepositioryViewController {
  private func bindData() {
    viewModel.navigatorTitle
      .drive(self.rx.title)
      .disposed(by: disbag)
    
    viewModel.repositories
      .drive(tableView.rx.items(dataSource: dataSource))
      .disposed(by: disbag)

    tableView.rx
      .modelSelected(Repository.self)
      .subscribe(onNext: {print($0.name)})
      .disposed(by: disbag)
  }
}
