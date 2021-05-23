//
//  DateUtils.swift
//  Sorena
//
//  Created by 藤門莉生 on 2021/01/28.
//

import Foundation
import UIKit

class DateUtils {
    class func stringFromDate(date: Date, format: String) -> String {
        let formatter: DateFormatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
}
