//
//  UIColor+Extension.swift
//  RxSwiftDemo
//
//  Created by wangjiayu on 2022/2/23.
//

import UIKit

extension UIColor {
    // 在extension中给系统的类扩充构造函数,只能扩充`便利构造函数`
    convenience init(r : CGFloat, g : CGFloat, b : CGFloat, alpha : CGFloat = 1.0) {
      self.init(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: alpha)
    }
    
    convenience init?(hex : String, alpha : CGFloat = 1.0) {
      // 0xff0000
      // 1.判断字符串的长度是否符合
    
      guard hex.count >= 6 else { return nil }
      
      // 2.将字符串转成大写
      var tempHex = hex.uppercased()
      
      // 3.判断开头: 0x/#/##
      if tempHex.hasPrefix("0x") || tempHex.hasPrefix("##") {
          tempHex = (tempHex as NSString).substring(from: 2)
      }
      if tempHex.hasPrefix("#") {
          tempHex = (tempHex as NSString).substring(from: 1)
      }
      
      // 4.分别取出RGB
      // FF --> 255
      var range = NSRange(location: 0, length: 2)
      let rHex = (tempHex as NSString).substring(with: range)
      range.location = 2
      let gHex = (tempHex as NSString).substring(with: range)
      range.location = 4
      let bHex = (tempHex as NSString).substring(with: range)
      
      // 5.将十六进制转成数字 emoji表情
      var r : UInt64 = 0, g : UInt64 = 0, b : UInt64 = 0
      Scanner(string: rHex).scanHexInt64(&r)
      Scanner(string: gHex).scanHexInt64(&g)
      Scanner(string: bHex).scanHexInt64(&b)
      
      self.init(r : CGFloat(r), g : CGFloat(g), b : CGFloat(b))
    }
    
    //返回随机颜色
    public class var randomColor:UIColor {
      get {
        let red = CGFloat(arc4random_uniform(256))
        let green = CGFloat(arc4random_uniform(256))
        let blue = CGFloat(arc4random_uniform(256))
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
      }
    }
  
    class func getRGBDelta(_ firstColor : UIColor, _ seccondColor : UIColor) -> (CGFloat, CGFloat, CGFloat) {
      let firstRGB = firstColor.getRGB()
      let secondRGB = seccondColor.getRGB()
      return (firstRGB.0 - secondRGB.0, firstRGB.1 - secondRGB.1, firstRGB.2 - secondRGB.2)
    }
    
    func getRGB() -> (CGFloat, CGFloat, CGFloat) {
      guard let cmps = cgColor.components else {
          fatalError("保证普通颜色是RGB方式传入")
      }
      
      return (cmps[0] * 255, cmps[1] * 255, cmps[2] * 255)
    }
}
