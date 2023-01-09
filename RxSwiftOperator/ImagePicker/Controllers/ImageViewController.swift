//
//  ImageViewController.swift
//  RxSwiftOperator
//
//  Created by wangjiayu on 2023/1/7.
//

import UIKit
import RxCocoa
import RxSwift

class ImageViewController: UIViewController {
  
  private lazy var stackView:UIStackView = {
    let stackView = UIStackView(frame: .zero)
    stackView.axis = .horizontal
    stackView.alignment = .fill
    stackView.distribution = .fillEqually
    stackView.backgroundColor = UIColor(hex: "#F7F7F7")
    stackView.addArrangedSubview(cameraBtn)
    stackView.addArrangedSubview(pictureBtn)
    stackView.addArrangedSubview(editBtn)
    return stackView
  }()
  
  private lazy var cameraBtn:UIButton = {
    let cameraBtn = UIButton(type: .roundedRect)
    cameraBtn.setTitle("拍照", for: .normal)
    cameraBtn.backgroundColor = .orange
    return cameraBtn
  }()
  
  private lazy var pictureBtn:UIButton = {
    let pictureBtn = UIButton(type: .roundedRect)
    pictureBtn.setTitle("相册", for: .normal)
    pictureBtn.backgroundColor = .red
    return pictureBtn
  }()
  
  private lazy var editBtn:UIButton = {
    let editBtn = UIButton(type: .roundedRect)
    editBtn.setTitle("编辑", for: .normal)
    editBtn.backgroundColor = .green
    return editBtn
  }()
  
  private lazy var imageView:UIImageView = {
    let imageView = UIImageView(frame: .zero)
    imageView.contentMode = .scaleToFill
    return imageView
  }()

  private lazy var disbag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.title = "图片选择器"
    
    buildSubViews()
    bindData()
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
      make.height.equalTo(180)
    }
  }
  
  private func bindData() {
    //判断拍照按钮是否可用
    cameraBtn.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)

    cameraBtn.rx.tap
      .flatMapLatest{ [weak self] _ in
        return UIImagePickerController.rx
          .createWithParent(self) { picker in
            picker.sourceType = .camera
            picker.allowsEditing = false
          }
          .flatMap{$0.rx.didFinishedPickerInfomation}
      }
      .map{ $0[UIImagePickerController.InfoKey.originalImage.rawValue] as? UIImage}
      .bind(to: imageView.rx.image)
      .disposed(by: disbag)
    
    pictureBtn.rx.tap
      .flatMapLatest{[weak self] _ in
        return UIImagePickerController.rx.createWithParent(self) { picker in
          picker.sourceType = .photoLibrary
          picker.allowsEditing = false
        }
        .flatMap{$0.rx.didFinishedPickerInfomation}
      }
      .map{$0[UIImagePickerController.InfoKey.originalImage.rawValue] as? UIImage}
      .bind(to: imageView.rx.image)
      .disposed(by: disbag)
    
    editBtn.rx.tap
      .flatMapLatest{[weak self] _ in
        return UIImagePickerController.rx.createWithParent(self) { picker in
          picker.sourceType = .photoLibrary
          picker.allowsEditing = true
        }
        .flatMap{$0.rx.didFinishedPickerInfomation}
      }
      .map{$0[UIImagePickerController.InfoKey.editedImage.rawValue] as? UIImage}
      .bind(to: imageView.rx.image)
      .disposed(by: disbag)
  }
}
