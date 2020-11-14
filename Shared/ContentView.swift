//
//  ContentView.swift
//  Shared
//
//  Created by Max Fisher on 11/13/20.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
	
    var body: some View {
		TabView {
			ToDoView()
				.tabItem {
					Image(systemName: "calendar")
					Text("To Do")
				}
			
			ProjectsView()
				.tabItem {
					Image(systemName: "hammer")
					Text("Projects")
				}
			
			DueDatesView()
				.tabItem {
					Image(systemName: "list.bullet.below.rectangle")
					Text("Due Dates")
						.accessibility(hint: Text("Dates that things are due"))
				}
			
			DoDatesView()
				.tabItem {
					Image(systemName: "list.dash")
					Text("Do Dates")
						.accessibility(hint: Text("Dates when things are to be done"))
				}
		}
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
