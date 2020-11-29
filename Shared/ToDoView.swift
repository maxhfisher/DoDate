//
//  ToDoView.swift
//  DoDate
//
//  Created by Max Fisher on 11/14/20.
//

import SwiftUI

struct ToDoView: View {
	@State private var showingSheet = false
	@State private var sheetToShow: SheetToShow = .newProjectView
	
	@FetchRequest(entity: DoDate.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \DueDate.date, ascending: true)], predicate: NSPredicate(format: "date > %@", Calendar.current.startOfDay(for: Date()) as NSDate)) private var doDates: FetchedResults<DoDate>
	@FetchRequest(entity: DueDate.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \DueDate.date, ascending: true)], predicate: NSPredicate(format: "date > %@", Calendar.current.startOfDay(for: Date()) as NSDate)) private var dueDates: FetchedResults<DueDate>
	private var days: [Day] {
		var days = [Day]()
		
		var dateOfLastDay = Date(timeIntervalSinceNow: -86400)
		if let dueDate = dueDates.last {
			dateOfLastDay = dueDate.date!
		}
		if let doDate = doDates.last {
			dateOfLastDay = doDate.date! > dateOfLastDay ? doDate.date!:dateOfLastDay
		}
		
		var date = Calendar.current.dateComponents([.day, .month, .year], from: Date())
		while Calendar.current.date(from: date)! < dateOfLastDay {
			days.append(Day(date: date, doDates: [], dueDates: []))
			date.day! += 1
		}
		for doDate in doDates {
			let dateComponents = Calendar.current.dateComponents([.day, .month, .year], from: doDate.date!)
			if let index = days.firstIndex(where: { dateComponents == $0.date }) {
				days[index].doDates.append(doDate)
			}
		}
		for dueDate in dueDates {
			let dateComponents = Calendar.current.dateComponents([.day, .month, .year], from: dueDate.date!)
			if let index = days.firstIndex(where: { dateComponents == $0.date }) {
				days[index].dueDates.append(dueDate)
			}
		}
		
		return days
	}
	
    var body: some View {
		NavigationView {
			ZStack {
				if days.isEmpty {
					Text("Nothing To Do")
						.font(.largeTitle)
						.foregroundColor(.secondary)
				} else {
					ScrollView {
						LazyVStack(spacing: 10) {
							ForEach(days, id: \.self) { day in
								DayView(day: day)
							}
							.padding()
							.frame(maxWidth: .infinity)
							.background(Color(UIColor.secondarySystemBackground))
							.cornerRadius(10)
						}
						.padding([.leading, .trailing])
						Spacer()
					}
				}
				
				VStack {
					Spacer()
					HStack {
						Spacer()
						PlusButtonView(showingSheet: $showingSheet, sheetToShow: $sheetToShow)
							.padding()
					}
				}
			}
			.navigationTitle("DoDate")
		}
		.sheet(isPresented: $showingSheet, content: {
			if sheetToShow == .newProjectView {
				NewProjectView()
			} else if sheetToShow == .newDueDateView {
				NewDueDateView()
			} else {
				NewDoDateView()
			}
		})
		
    }
	
	private struct PlusButtonView: View {
		@Binding var showingSheet: Bool
		@Binding var sheetToShow: SheetToShow
		
		var body: some View {
			Menu {
				Button("Add Project") {
					sheetToShow = .newProjectView
					showingSheet = true
				}
				Button("Add Due Date") {
					sheetToShow = .newDueDateView
					showingSheet = true
				}
				.accessibility(hint: Text("Add a date when something is due"))
				Button("Add Do Date") {
					sheetToShow = .newDoDateView
					showingSheet = true
				}
				.accessibility(hint: Text("Add a date to do something"))
			} label: { Image(systemName: "plus")
				.font(.system(size: 50))
				.foregroundColor(.white)
				.padding()
				.background(Color.pink)
				.clipShape(Circle())
			}
		}
	}
	
	private enum SheetToShow {
		case newProjectView, newDueDateView, newDoDateView
	}
}

struct ToDoView_Previews: PreviewProvider {
    static var previews: some View {
		ToDoView()
    }
}
