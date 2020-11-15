//
//  ToDoView.swift
//  DoDate
//
//  Created by Max Fisher on 11/14/20.
//

import SwiftUI

struct ToDoView: View {

	@State private var days: [Day] = []

    var body: some View {
		NavigationView {
			ZStack {
				Text("To Do")
					.navigationTitle("DoDate")
				
				VStack {
					Spacer()
					HStack {
						Spacer()
						PlusButtonView()
							.padding()
					}
				}
			}
		}
		.onAppear(perform: sortDays)
    }
	
	func sortDays() {
		var sortedDays: [Day] = []
		var dates: [Date] = []

		for doDate in doDates {
			guard doDate.date != nil else { continue }

			if dates.contains(doDate.date!) {
				sortedDays.first(where: { doDate.date == $0.date })!.doDates.append(doDate)
			} else {
				dates.append(doDate.date!)

				let newDay = Day(forDate: doDate.date!)
				newDay.doDates.append(doDate)
				sortedDays.append(newDay)
			}
		}

		for dueDate in dueDates {
			guard dueDate.date != nil else { continue }

			if dates.contains(dueDate.date!) {
				sortedDays.first(where: { dueDate.date == $0.date })!.dueDates.append(dueDate)
			} else {
				dates.append(dueDate.date!)

				let newDay = Day(forDate: dueDate.date!)
				newDay.dueDates.append(dueDate)
				sortedDays.append(newDay)
			}
		}
	}
	
	struct PlusButtonView: View {
		var body: some View {
			Menu {
				Button("Add Project") {

				}
				Button("Add Due Date") {

				}.accessibility(hint: Text("Add a date when something is due"))
				Button("Add Do Date") {

				}.accessibility(hint: Text("Add a date to do something"))
			} label: { Image(systemName: "plus")
				.font(.system(size: 50))
				.foregroundColor(.white)
				.padding()
				.background(Color.pink)
				.clipShape(Circle())
			}
		}
	}

	class Day {
		let date: Date
		var doDates: [DoDate] = []
		var dueDates: [DueDate] = []

		init(forDate date: Date) {
			self.date = date
		}
	}
}

struct ToDoView_Previews: PreviewProvider {
    static var previews: some View {
		ToDoView()
    }
}
