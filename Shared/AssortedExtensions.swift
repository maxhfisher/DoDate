//
//  AssortedExtensions.swift
//  DoDate
//
//  Created by Max Fisher on 11/29/20.
//

import Foundation

extension Date {
	static func dateString(from dateComponents: DateComponents, withFormat format: String) -> String {
		let date = Calendar.current.date(from: dateComponents)!
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = format
		return dateFormatter.string(from: date)
	}
}
