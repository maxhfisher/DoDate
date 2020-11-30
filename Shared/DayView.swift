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
				Text(Date.dateString(from: day.date, withFormat: "EEEE, MMMM dd"))
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
				HStack {
					VStack(alignment: .leading) {
						if !day.doDates.isEmpty {
							Text("To Do")
								.font(.title2)
								.fontWeight(.semibold)
							HStack {
								ForEach(day.doDates, id: \.self) { doDate in
									HStack {
										ProjectCategoryView(category: ProjectCategory(rawValue: doDate.project!.category!)!, isSmall: true)
										VStack(alignment: .leading) {
											Text(doDate.task!)
												.font(.title3)
												.lineLimit(1)
											Text(doDate.dueDate!.name!)
												.font(.caption)
												.fontWeight(.light)
												.lineLimit(1)
											Text("Due \(Date.dateString(from: Calendar.current.dateComponents([.day, .month, .year], from: doDate.dueDate!.date!), withFormat: "MM/dd/yyyy"))")
												.font(.caption)
												.fontWeight(.light)
										}
									}
								}
							}
						}
						if !day.dueDates.isEmpty {
							Text("Due")
								.font(.title2)
								.fontWeight(.semibold)
							HStack {
								ForEach(day.dueDates, id: \.self) { dueDate in
									HStack {
										ProjectCategoryView(category: ProjectCategory(rawValue: dueDate.project!.category!)!, isSmall: true)
										VStack(alignment: .leading) {
											Text(dueDate.name!)
												.font(.title3)
												.lineLimit(1)
											Text(dueDate.project!.name!)
												.font(.caption)
												.lineLimit(1)
										}
									}
								}
							}
						}
					}
					Spacer()
				}
			}
		}
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
