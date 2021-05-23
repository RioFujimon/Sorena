//
//  UIColor-Extension.swift
//  Sorena
//
//  Created by 藤門莉生 on 2021/02/03.
//

import UIKit

//RGBで色を指定できるようにするメソッドを実装
extension UIColor {
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat)->UIColor {
        return self.init(red: red / 255, green: green / 255, blue: blue / 255, alpha: 1)
    }
}
