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
				Text("Hello World")
					.navigationTitle("DoDate")
			}
		}
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
