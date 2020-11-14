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
			NavigationView {
				Text("To Do")
					.navigationTitle("DoDate")
			}
			.tabItem {
				Image(systemName: "calendar")
				Text("To Do")
			}
			
			NavigationView {
				Text("Projects")
					.navigationTitle("Projects")
			}
			.tabItem {
				Image(systemName: "hammer")
				Text("Projects")
			}
			
			NavigationView {
				Text("Due Dates")
					.navigationTitle("Due Dates")
			}
			.tabItem {
				Image(systemName: "list.bullet.below.rectangle")
				Text("Due Dates")
					.accessibility(hint: Text("Dates that things are due"))
			}
			
			NavigationView {
				Text("Do Dates")
					.navigationTitle("Do Dates")
			}
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
