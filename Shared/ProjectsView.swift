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
						ForEach(projects ,id: \.self) { project in
							NavigationLink(destination: ProjectDetailView(project: project)) {
								HStack {
									ProjectCategoryView(category: ProjectCategory(rawValue: project.category!)!)
									VStack(alignment: .leading) {
										Text(project.name!)
											.font(.title)
											.fontWeight(.semibold)
											.lineLimit(1)
										Text(project.details!)
											.lineLimit(3)
									}
								}
							}
						}
						.onDelete(perform: delete)
					}
					.listStyle(InsetGroupedListStyle())
				}
			}
			.navigationTitle("Projects")
			.navigationBarItems(leading: EditButton(), trailing: Button { showingAddProjectSheet = true } label: {
				Image(systemName: "plus")
			})
			.sheet(isPresented: $showingAddProjectSheet, content: { NewProjectView().environment(\.managedObjectContext, context) })
		}
    }
	
	func delete(atOffsets offsets: IndexSet) {
		for i in offsets {
			let project = projects[i]
			for case let dueDate as DueDate in project.dueDates! {
				for case let doDate as DoDate in dueDate.doDates! {
					context.delete(doDate)
				}
				context.delete(dueDate)
			}
			context.delete(project)
		}
		try? context.save()
	}
}

struct NewProjectView: View {
	@Environment(\.managedObjectContext) var context
	@Environment(\.presentationMode) var presentationMode
	
	@State private var name = ""
	@State private var details = ""
	@State private var categorySelection: ProjectCategory?
	
	@State private var showingErrorAlert = false
	
	var body: some View {
		NavigationView {
			Form {
				Section {
					TextField("Name", text: $name)
					TextField("Details", text: $details)
				}
				
				Section(header: Text("Category")) {
					CategorySelectionView(categorySelection: $categorySelection)
				}
				
				Section {
					HStack {
						Spacer()
						Button("Save") {
							let hapticGenerator = UINotificationFeedbackGenerator()
							hapticGenerator.prepare()
							
							if name.isEmpty || details.isEmpty || categorySelection == nil {
								hapticGenerator.notificationOccurred(.error)
							} else {
								do {
									let newProject = Project(context: context)
									newProject.name = name
									newProject.details = details
									newProject.category = categorySelection!.rawValue
									newProject.id = UUID()
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
	
	private struct CategorySelectionView: View {
		@Binding var categorySelection: ProjectCategory?
		
		var body: some View {
			ScrollView(.horizontal) {
				HStack {
					ForEach(ProjectCategory.allCases, id: \.self) { category in
						ProjectCategoryView(category: category)
							.shadow(radius: categorySelection == category ? 10:0)
							.overlay(categorySelection == category ? Circle().stroke(Color.accentColor, lineWidth: 7):Circle().stroke(Color.clear, lineWidth: 0))
							.padding()
							.onTapGesture {
								categorySelection = category
							}
							.accessibilityAddTraits(categorySelection == category ? [.isButton, .isSelected]:[.isButton])
					}
				}
			}
		}
	}
}

struct ProjectSelectionView: View {
	@Binding var selection: Project?
	
	var body: some View {
		NavigationLink(destination: ProjectListView(selection: $selection)) {
				HStack {
					Text("Project")
					Spacer()
					if selection != nil  {
						Text(selection?.name ?? "")
							.foregroundColor(.secondary)
					}
				}
			}
	}
	
	private struct ProjectListView: View {
		@Environment(\.managedObjectContext) var context
		@Environment(\.presentationMode) var presentationMode
		
		@FetchRequest(entity: Project.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Project.name, ascending: true)]) var projects: FetchedResults<Project>
		
		@Binding var selection: Project?
		@State private var showingAddProjectView = false
		var body: some View {
			Form {
				Section {
					ForEach(projects, id: \.self) { project in
						Button {
							withAnimation {
								selection = project
							}
							presentationMode.wrappedValue.dismiss()
						} label: {
							HStack {
								Text(project.name ?? "")
								Spacer()
								if selection == project {
									Image(systemName: "checkmark")
										.foregroundColor(.accentColor)
								}
							}
						}
						.foregroundColor(.primary)
						.accessibilityElement(children: .ignore)
						.accessibility(label: Text(project.name ?? ""))
						.accessibility(addTraits: selection == project ? [.isSelected]:[])
					}
				}
				Section {
					Button("Add New Project") {
						showingAddProjectView = true
					}
				}
			}
			.navigationTitle("Select a Project")
			.sheet(isPresented: $showingAddProjectView, content: { NewProjectView().environment(\.managedObjectContext, context) })
		}
	}
}

struct ProjectsView_Previews: PreviewProvider {
    static var previews: some View {
		ProjectsView()
    }
}
