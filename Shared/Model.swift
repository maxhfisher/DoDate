//
//  Model.swift
//  DoDate
//
//  Created by Max Fisher on 11/14/20.
//

import Foundation
import CoreData

class Model: ObservableObject {
	@Published var projects: [Project]
	@Published var dueDates: [DueDate]
	@Published var doDates: [DoDate]
	
	init() {
		do {
			try projects = Project.fetchRequest().execute()
		} catch {
			projects = []
		}
		do {
			let dueDatesFetchRequest: NSFetchRequest<DueDate> = DueDate.fetchRequest()
			dueDatesFetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \DueDate.date, ascending: true)]
			try dueDates = dueDatesFetchRequest.execute()
		} catch {
			dueDates = []
		}
		do {
			let doDatesFetchRequest: NSFetchRequest<DoDate> = DoDate.fetchRequest()
			doDatesFetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \DoDate.date, ascending: true)]
			try doDates = doDatesFetchRequest.execute()
		} catch {
			doDates = []
		}
	}
}
