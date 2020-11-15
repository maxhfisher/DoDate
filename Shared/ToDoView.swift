//
//  ToDoView.swift
//  DoDate
//
//  Created by Max Fisher on 11/14/20.
//

import SwiftUI

struct ToDoView: View {
	@State private var showingNewProjectsView = false
	
    var body: some View {
		NavigationView {
			ZStack {
				Text("To Do")
					.navigationTitle("DoDate")
				
				VStack {
					Spacer()
					HStack {
						Spacer()
						PlusButtonView(showingNewProjectsView: $showingNewProjectsView)
							.padding()
					}
				}
			}
		}
		.sheet(isPresented: $showingNewProjectsView, content: { NewProjectView() })
    }
	
	struct PlusButtonView: View {
		@Binding var showingNewProjectsView: Bool
		
		var body: some View {
			Menu {
				Button("Add Project") { showingNewProjectsView = true }
				Button("Add Due Date") {

				}.accessibility(hint: Text("Add a date when something is due"))
				Button("Add Do Date") {

				}.accessibility(hint: Text("Add a date to do something"))
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
