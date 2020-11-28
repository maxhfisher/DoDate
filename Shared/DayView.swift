//
//  DayView.swift
//  DoDate
//
//  Created by Max Fisher on 11/27/20.
//

import SwiftUI

struct DayView: View {
	let day: Day
	
    var body: some View {
		VStack {
			HStack {
				Text(DayView.dateString(from: day.date))
					.font(.title)
					.fontWeight(.bold)
				Spacer()
			}
			if day.doDates.isEmpty && day.dueDates.isEmpty {
				Text("Nothing To Do")
					.font(.title2)
					.foregroundColor(.secondary)
					.padding()
			} else {
				
			}
		}
    }
	
	private static func dateString(from dateComponents: DateComponents) -> String {
		let date = Calendar.current.date(from: dateComponents)!
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "EEEE, MMMM dd"
		return dateFormatter.string(from: date)
	}
}

struct DayView_Previews: PreviewProvider {
    static var previews: some View {
		Group {
			DayView(day: Day(date: DateComponents(), doDates: [], dueDates: []))
		}
    }
}

struct Day: Hashable {
	let date: DateComponents
	
	var doDates: [DoDate]
	var dueDates: [DueDate]
}
