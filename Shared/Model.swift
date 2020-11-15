//
//  Model.swift
//  DoDate
//
//  Created by Max Fisher on 11/14/20.
//

import Foundation
import CoreData

class Model: ObservableObject {
	let context: NSManagedObjectContext
	
	@Published private(set) var projects: [Project]
	@Published private(set) var dueDates: [DueDate]
	@Published private(set) var doDates: [DoDate]
	@Published private(set) var days: [Day]
	
	init(context: NSManagedObjectContext) {
		self.context  = context
		
		do {
			try projects = context.fetch(Project.fetchRequest())
		} catch {
			projects = []
		}
		do {
			let dueDatesFetchRequest: NSFetchRequest<DueDate> = DueDate.fetchRequest()
			dueDatesFetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \DueDate.date, ascending: true)]
			try dueDates = context.fetch(dueDatesFetchRequest)
		} catch {
			dueDates = []
		}
		do {
			let doDatesFetchRequest: NSFetchRequest<DoDate> = DoDate.fetchRequest()
			doDatesFetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \DoDate.date, ascending: true)]
			try doDates = context.fetch(doDatesFetchRequest)
		} catch {
			doDates = []
		}
		do {
			let daysFetchRequest: NSFetchRequest<Day> = Day.fetchRequest()
			daysFetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Day.date, ascending: true)]
			try days = context.fetch(daysFetchRequest)
		} catch {
			days = []
		}
	}
	
	func add(project name: String, details: String) throws {
		let newProject = Project(context: context)
		newProject.id = UUID()
		newProject.name = name
		newProject.details = details
		try context.save()
	}
	
	func add(dueDate date: Date, name: String, details: String, project: Project) throws {
		let newDueDate = DueDate(context: context)
		newDueDate.id = UUID()
		newDueDate.date = date
		newDueDate.name = name
		newDueDate.details = details
		newDueDate.project = project
		try context.save()
	}
	
	func add(doDate date: Date, details: String, dueDate: DueDate) throws {
		let newDoDate = DoDate(context: context)
		newDoDate.id = UUID()
		newDoDate.date = date
		newDoDate.details = details
		newDoDate.dueDate = dueDate
		newDoDate.project = dueDate.project
		try context.save()
	}
	
	func add(day date: Date) throws -> Day {
		if days.contains(where: { $0.date == date }) {
			return days.first(where: { $0.date == date })!
		} else {
			let newDay = Day(context: context)
			newDay.date = date
			try context.save()
			
			return newDay
		}
	}
}
