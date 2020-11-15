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
	
	let model = Model()
	
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
				.environmentObject(model)
        }
    }
}
