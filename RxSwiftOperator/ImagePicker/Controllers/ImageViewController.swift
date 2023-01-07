//
//  ImageViewController.swift
//  RxSwiftOperator
//
//  Created by wangjiayu on 2023/1/7.
//

import UIKit

class ImageViewController: UIViewController {
  
  private lazy var stackView:UIStackView = {
    let stackView = UIStackView(frame: .zero)
    stackView.axis = .horizontal
    stackView.alignment = .fill
    stackView.distribution = .fillEqually
    stackView.addArrangedSubview(cameraBtn)
    stackView.addArrangedSubview(pictureBtn)
    stackView.addArrangedSubview(editBtn)
    return stackView
  }()
  
  private lazy var cameraBtn:UIButton = {
    let cameraBtn = UIButton(type: .roundedRect)
    cameraBtn.setTitle("相机", for: .normal)
    return cameraBtn
  }()
  
  private lazy var pictureBtn:UIButton = {
    let pictureBtn = UIButton(type: .roundedRect)
    pictureBtn.setTitle("相册", for: .normal)
    return pictureBtn
  }()
  
  private lazy var editBtn:UIButton = {
    let editBtn = UIButton(type: .roundedRect)
    editBtn.setTitle("编辑", for: .normal)
    return editBtn
  }()
  
  private lazy var imageView:UIImageView = {
    let imageView = UIImageView(frame: .zero)
    imageView.contentMode = .scaleAspectFill
    return imageView
  }()

  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "图片选择器"
    
    buildSubViews()
  }
}

// MARK: - 设置UI
extension ImageViewController {
  private func buildSubViews() {
    view.addSubview(stackView)
    stackView.snp.makeConstraints { make in
      make.top.equalTo(20)
      make.left.equalTo(15)
      make.right.equalTo(-15)
      make.height.equalTo(48)
    }
    
    view.addSubview(imageView)
    imageView.snp.makeConstraints { make in
      make.top.equalTo(stackView.snp.bottom).offset(10)
      make.left.right.equalTo(stackView)
      make.height.equalTo(240)
    }
  }
}
