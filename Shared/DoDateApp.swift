//
//  DoDateApp.swift
//  Shared
//
//  Created by Max Fisher on 11/13/20.
//

import SwiftUI

@main
struct DoDateApp: App {
    let persistenceController = PersistenceController.shared
	
	@FetchRequest(entity: Project.entity(), sortDescriptors: []) var projects: FetchedResults<Project>
	@FetchRequest(entity: DueDate.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \DueDate.date, ascending: true)], predicate: NSPredicate(format: "date >= %@", Date() as CVarArg)) var dueDates: FetchedResults<DueDate>
	@FetchRequest(entity: DoDate.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \DoDate.date, ascending: true)], predicate: NSPredicate(format: "date >= %@", Date() as CVarArg)) var doDates: FetchedResults<DoDate>

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
