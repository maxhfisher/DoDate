//
//  ToDoView.swift
//  DoDate
//
//  Created by Max Fisher on 11/14/20.
//

import SwiftUI

struct ToDoView: View {
	@State private var showingNewProjectsView = false
	@State private var showingNewDueDateView = false
	@State private var showingNewDoDateView = false
	
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
						PlusButtonView(showingNewProjectsView: $showingNewProjectsView, showingNewDueDateView: $showingNewDueDateView, showingNewDoDateView: $showingNewDoDateView)
							.padding()
					}
				}
			}
			.navigationTitle("DoDate")
		}
		.sheet(isPresented: $showingNewProjectsView, content: { NewProjectView() })
		.sheet(isPresented: $showingNewDueDateView, content: { NewDueDateView() })
		.sheet(isPresented: $showingNewDoDateView, content: { NewDoDateView() })
    }
	
	struct PlusButtonView: View {
		@Binding var showingNewProjectsView: Bool
		@Binding var showingNewDueDateView: Bool
		@Binding var showingNewDoDateView: Bool
		
		var body: some View {
			Menu {
				Button("Add Project") { showingNewProjectsView = true }
				Button("Add Due Date") { showingNewDueDateView = true }.accessibility(hint: Text("Add a date when something is due"))
				Button("Add Do Date") { showingNewDoDateView = true }.accessibility(hint: Text("Add a date to do something"))
			} label: { Image(systemName: "plus")
				.font(.system(size: 50))
				.foregroundColor(.white)
				.padding()
				.background(Color.pink)
				.clipShape(Circle())
			}
		}
	}
}

struct ToDoView_Previews: PreviewProvider {
    static var previews: some View {
		ToDoView()
    }
}
