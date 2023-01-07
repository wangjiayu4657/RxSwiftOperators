//
//  DatePickerViewController.swift
//  RxSwiftOperator
//
//  Created by wangjiayu on 2022/12/28.
//

import UIKit
import RxCocoa
import RxSwift


class DatePickerViewController: UIViewController {
  
  //开始按钮
  private lazy var startBtn = UIButton(type: .custom)
  //倒计时时间选择控件
  private lazy var datePicker:UIDatePicker = {
     let datePicker = UIDatePicker(frame: .zero)
     datePicker.preferredDatePickerStyle = .wheels
     datePicker.datePickerMode = .countDownTimer
     return datePicker
  }()
  //剩余时间
  private lazy var leftTime = BehaviorRelay(value: TimeInterval(180))
  //倒计时是否结束
  private lazy var isStopped = BehaviorRelay(value: true)

  private lazy var disbag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor.white
    
    buildSubViews()
    bindData()
  }
}

// MARK: - 设置UI
extension DatePickerViewController {
  private func buildSubViews() {
    view.addSubview(datePicker)
    datePicker.snp.makeConstraints { make in
      make.left.centerY.right.equalToSuperview()
      make.height.equalTo(200)
    }
    
    view.addSubview(startBtn)
    startBtn.backgroundColor  = UIColor.lightGray
    startBtn.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.size.equalTo(CGSize(width: 180, height: 44))
      make.top.equalTo(datePicker.snp.bottom).offset(15)
    }
  }
}

extension DatePickerViewController {
  private func bindData() {
    
    DispatchQueue.main.async {
      _ = self.datePicker.rx.countDownDuration <-> self.leftTime
    }
    
    Observable
      .combineLatest(isStopped, leftTime) { stopped, sec in
        return stopped ? "开始" : "倒计时开始:\(sec)秒"
      }
      .bind(to: startBtn.rx.title())
      .disposed(by: disbag)
    
    isStopped.bind(to: startBtn.rx.isEnabled).disposed(by: disbag)
    isStopped.bind(to: datePicker.rx.isEnabled).disposed(by: disbag)
    
    startBtn.rx.tap
      .subscribe {[weak self] _ in
        self?.startBtnClick()
      }
      .disposed(by: disbag)
  }
  
  private func startBtnClick() {
    isStopped.accept(false)
    
    Observable<Int>
      .interval(.seconds(1), scheduler: MainScheduler.instance)
      .takeUntil(isStopped.filter({$0}))
      .subscribe {[unowned self] element in
        let value = self.leftTime.value
        self.leftTime.accept(value - 1)
        if self.leftTime.value == 0 {
          print("倒计时结束")
          self.isStopped.accept(true)
          self.leftTime.accept(TimeInterval(180))
        }
      }
      .disposed(by: disbag)
  }
}
