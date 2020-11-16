//
//  ProjectsView.swift
//  DoDate
//
//  Created by Max Fisher on 11/14/20.
//

import SwiftUI

struct ProjectsView: View {
	@Environment(\.managedObjectContext) var context
	@FetchRequest(entity: Project.entity(), sortDescriptors: []) var projects: FetchedResults<Project>
	
	@State private var showingAddProjectSheet = false
	
    var body: some View {
		NavigationView  {
			Group {
				if projects.isEmpty {
					Text("No Projects Yet")
						.font(.largeTitle)
						.foregroundColor(.secondary)
				} else {
					List {
						ForEach(projects,id: \.self) { project in
							Text(project.name ?? "")
						}
						.onDelete(perform: delete)
					}
				}
			}
			.navigationTitle("Projects")
			.navigationBarItems(leading: EditButton(), trailing: Button { showingAddProjectSheet = true } label: {
				Image(systemName: "plus")
			})
			.sheet(isPresented: $showingAddProjectSheet, content: { NewProjectView() })
		}
    }
	
	func delete(atOffsets offsets: IndexSet) {
		for index in offsets {
			context.delete(projects[index])
		}
		try? context.save()
	}
}

struct NewProjectView: View {
	@Environment(\.managedObjectContext) var context
	@Environment(\.presentationMode) var presentationMode
	
	@State private var name = ""
	@State private var details = ""
	
	@State private var showingErrorAlert = false
	
	var body: some View {
		NavigationView {
			Form {
				Section {
					TextField("Name", text: $name)
					TextField("Details", text: $details)
				}
				
				Section {
					HStack {
						Spacer()
						Button("Save") {
							let hapticGenerator = UINotificationFeedbackGenerator()
							hapticGenerator.prepare()
							
							if name.isEmpty || details.isEmpty {
								hapticGenerator.notificationOccurred(.error)
							} else {
								do {
									let newProject = Project(context: context)
									newProject.name = name
									newProject.details = details
									try context.save()
									hapticGenerator.notificationOccurred(.success)
									presentationMode.wrappedValue.dismiss()
								} catch {
									print(error.localizedDescription)
									hapticGenerator.notificationOccurred(.error)
									showingErrorAlert = true
								}
							}
						}
						.alert(isPresented: $showingErrorAlert, content: {
							Alert(title: Text("There was an error saving your project"))
						})
						Spacer()
					}
				}
			}
			.navigationBarTitleDisplayMode(.inline)
			.navigationTitle("New Project")
			.navigationBarItems(trailing: Button("Cancel") { presentationMode.wrappedValue.dismiss() })
		}
	}
}

struct ProjectsView_Previews: PreviewProvider {
    static var previews: some View {
		ProjectsView()
    }
}
