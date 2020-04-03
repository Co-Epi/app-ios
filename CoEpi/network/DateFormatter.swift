//
//  DateFormatter.swift
//  
//
//  Created by Hamish Rodda on 28/3/20.
//

import Foundation

/*extension DateFormatter {
    static var unixDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
}*/

class UnixDateFormatter : DateFormatter {

  override func getObjectValue(_ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?, for string: String, range rangep: UnsafeMutablePointer<NSRange>?) throws {
    if let secSince1970 = Double(string) {
      let convertedDate: AnyObject = Date(timeIntervalSince1970: secSince1970) as NSDate
      
      obj?.pointee = convertedDate
    }
  }

}
