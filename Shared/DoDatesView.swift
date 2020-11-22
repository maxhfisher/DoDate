//
//  DoDatesView.swift
//  DoDate
//
//  Created by Max Fisher on 11/14/20.
//

import SwiftUI

struct DoDatesView: View {
	@Environment(\.managedObjectContext) var context
	
	@FetchRequest(entity: DoDate.entity(), sortDescriptors: []) var doDates: FetchedResults<DoDate>
	
	@State private var showingNewDoDateView = false
	
    var body: some View {
		NavigationView {
			Group {
				if doDates.isEmpty {
					Text("No Do Dates Yet")
						.font(.largeTitle)
						.foregroundColor(.secondary)
				} else {
					List {
						ForEach(doDates, id: \.id) { doDate in
							Text(doDate.details ?? "")
						}
					}
				}
			}
			.navigationTitle("Do Dates")
			.navigationBarItems(leading: EditButton(), trailing: Button { showingNewDoDateView = true } label: {
				Image(systemName: "plus")
			})
			.sheet(isPresented: $showingNewDoDateView, content: { NewDoDatesView().environment(\.managedObjectContext, context) })
		}
    }
}

struct NewDoDatesView: View {
	@Environment(\.managedObjectContext) var context
	
	@FetchRequest(entity: Project.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Project.name, ascending: true)]) var projects: FetchedResults<Project>
	
	@State private var projectSelection = 0
	@State private var dueDateSelection = 0
	
	var body: some View {
		NavigationView {
			Form {
				Section {
					ProjectSelectionView(projects: Array(projects), selectionIndex: $projectSelection)
				}
			}
			.navigationBarTitleDisplayMode(.inline)
			.navigationTitle("New Do Date")
		}
	}
	
	func formatDate(_ date: Date) -> String {
		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .short
		
		return dateFormatter.string(from: date)
	}
}

struct DoDatesView_Previews: PreviewProvider {
    static var previews: some View {
        DoDatesView()
    }
}
