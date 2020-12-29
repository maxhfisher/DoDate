//
//  ProjectDetailView.swift
//  DoDate
//
//  Created by Max Fisher on 12/21/20.
//

import SwiftUI

struct ProjectDetailView: View {
	@Environment(\.managedObjectContext) var context
	@Environment(\.presentationMode) var presentationMode
	
	let project: Project
	
	@State private var showingEditView = false
	
    var body: some View {
		ScrollView {
			HStack {
				VStack(alignment: .leading) {
					HStack {
						ProjectCategoryView(category: ProjectCategory(rawValue: project.category!))
						VStack(alignment: .leading) {
							Text("Details")
								.font(.title)
								.fontWeight(.bold)
							Text(project.details ?? "")
						}
					}
					.padding(.bottom)
					
					Text("Due Dates")
						.font(.title)
						.fontWeight(.bold)
						.accessibility(hint: Text("Date things are due"))
					ForEach(0..<project.dueDates!.count, id: \.self) { i in
						NavigationLink(destination: DueDateDetailView(dueDate: project.dueDates!.allObjects[i] as! DueDate)) {
							HStack {
								ProjectCategoryView(category: ProjectCategory(rawValue: project.category!), isSmall: true)
								VStack(alignment: .leading) {
									Text((project.dueDates!.allObjects[i] as! DueDate).name!)
										.font(.title3)
										.fontWeight(.bold)
										.lineLimit(1)
									Text(Date.dateString(from: Calendar.current.dateComponents([.day, .month, .year], from: (project.dueDates!.allObjects[i] as! DueDate).date!), withFormat: "MM/dd/yyyy"))
										.font(.caption)
									Text((project.dueDates!.allObjects[i] as! DueDate).details!)
										.font(.caption)
										.lineLimit(2)
								}
								Spacer()
								Image(systemName: "chevron.right")
									.foregroundColor(.secondary)
									.padding()
							}
							.padding(5)
						}
						.background(Color(UIColor.secondarySystemBackground))
						.cornerRadius(10)
						.foregroundColor(.primary)
						.padding(.bottom, 3)
					}
					
					Text("Do Dates")
						.font(.title)
						.fontWeight(.bold)
						.accessibility(hint: Text("Dates things are to be done"))
					ForEach(0..<project.doDates!.count) { i in
						NavigationLink(destination: DoDateDetailView(doDate: project.doDates!.allObjects[i] as! DoDate)) {
							HStack {
								ProjectCategoryView(category: ProjectCategory(rawValue: project.category!), isSmall: true)
								VStack(alignment: .leading) {
									Text((project.doDates!.allObjects[i] as! DoDate).task!)
										.font(.title3)
										.fontWeight(.bold)
										.lineLimit(1)
									Text(Date.dateString(from: Calendar.current.dateComponents([.day, .month, .year], from: (project.doDates!.allObjects[i] as! DoDate).date!), withFormat: "MM/dd/yyyy"))
										.font(.caption)
									Text((project.doDates!.allObjects[i] as! DoDate).dueDate!.name!)
										.font(.caption)
								}
								Spacer()
								Image(systemName: "chevron.right")
									.foregroundColor(.secondary)
									.padding()
							}
							.padding(5)
						}
						.background(Color(UIColor.secondarySystemBackground))
						.cornerRadius(10)
						.foregroundColor(.primary)
						.padding(.bottom, 3)
					}
					Spacer()
				}
				.padding([.leading, .trailing])
				Spacer()
			}
		}
		.navigationBarTitle(project.name ?? "")
		.navigationBarItems(trailing: Button("Edit") { showingEditView = true })
		.sheet(isPresented: $showingEditView, content: { EditProjectView(project: project){ presentationMode.wrappedValue.dismiss() }.environment(\.managedObjectContext, context) })
    }
}

struct EditProjectView: View {
	private let project: Project
	private let onDelete: () -> Void
	
	@Environment(\.managedObjectContext) private var context
	@Environment(\.presentationMode) private var presentationMode
	
	@FetchRequest(entity: DueDate.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \DueDate.date, ascending: true)]) var dueDates: FetchedResults<DueDate>
	@FetchRequest(entity: DoDate.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \DoDate.date, ascending: true)]) var doDates: FetchedResults<DoDate>
	
	@State private var name: String
	@State private var details: String
	@State private var categorySelection: ProjectCategory?
	
	@State private var showingErrorAlert = false
	@State private var shwowingDeleteAlert = false
	
	init(project: Project, onDelete: @escaping () -> Void) {
		_name = State(initialValue: project.name!)
		_details = State(initialValue: project.details!)
		_categorySelection = State(initialValue: ProjectCategory(rawValue: project.category!))
		self.project = project
		self.onDelete = onDelete
	}
	
	var body: some View {
		NavigationView {
			Form {
				Section {
					TextField("Name", text: Binding<String>(get: { self.name }, set: { name = $0 }))
					TextField("Details", text: Binding<String>(get: {self.details }, set: { details = $0 }))
				}
				
				Section(header: Text("Category")) {
					CategorySelectionView(categorySelection: $categorySelection)
				}
				
				Section(header: Text("Due Dates")) {
					List {
						ForEach(dueDates, id: \.self) { dueDate in
							if dueDate.project!.id! == project.id! {
								HStack {
									ProjectCategoryView(category: ProjectCategory(rawValue: project.category!), isSmall: true)
									VStack(alignment: .leading) {
										Text(dueDate.name!)
											.font(.title3)
											.fontWeight(.bold)
											.lineLimit(1)
										Text(Date.dateString(from: Calendar.current.dateComponents([.month, .day, .year], from: dueDate.date!), withFormat: "MM/dd/yyyy"))
											.font(.caption)
										Text(dueDate.details!)
											.font(.caption)
											.lineLimit(1)
									}
									Spacer()
								}
							}
						}
						.onDelete(perform: deleteDueDate)
					}
				}
				
				Section(header: Text("Do Dates")) {
					List {
						ForEach(doDates, id: \.self) { doDate in
							if doDate.project!.id! == project.id! {
								HStack {
									ProjectCategoryView(category: ProjectCategory(rawValue: project.category!), isSmall: true)
									VStack(alignment: .leading) {
										Text(doDate.task!)
											.font(.title3)
											.fontWeight(.bold)
											.lineLimit(1)
										Text(Date.dateString(from: Calendar.current.dateComponents([.month, .day, .year], from: doDate.date!), withFormat: "MM/dd/yyyy"))
											.font(.caption)
										Text(doDate.dueDate!.name!)
											.font(.caption)
											.lineLimit(1)
									}
									Spacer()
								}
							}
						}
						.onDelete(perform: deleteDoDate)
					}
				}
				
				Section {
					HStack {
						Spacer()
						Button {
							shwowingDeleteAlert = true
						} label: {
							Text("Delete Project")
								.foregroundColor(.red)
						}
						.alert(isPresented: $shwowingDeleteAlert) {
							Alert(title: Text("Delete Project?"), message: Text("All associated Due Dates and Do Dates will be deleted too. This action cannot be undone"), primaryButton: .cancel(), secondaryButton: .destructive(Text("Delete"), action: delete))
						}
						Spacer()
					}
				}
			}
			.navigationBarTitleDisplayMode(.inline)
			.navigationTitle("Edit Project")
			.navigationBarItems(leading: Button("Cancel") { presentationMode.wrappedValue.dismiss() }, trailing: Button("Save", action: save))
			.alert(isPresented: $showingErrorAlert, content: {
				Alert(title: Text("There was an error saving your project"))
			})
		}
	}
	
	private func save() {
		let hapticGenerator = UINotificationFeedbackGenerator()
		hapticGenerator.prepare()
		
		if name.isEmpty || details.isEmpty || categorySelection == nil {
			hapticGenerator.notificationOccurred(.error)
		} else {
			project.name = name
			project.details = details
			project.category = categorySelection!.rawValue
			if context.hasChanges {
				do {
					try context.save()
					hapticGenerator.notificationOccurred(.success)
					presentationMode.wrappedValue.dismiss()
				} catch {
					print(error.localizedDescription)
					hapticGenerator.notificationOccurred(.error)
					showingErrorAlert = true
				}
			} else {
				presentationMode.wrappedValue.dismiss()
			}
		}
	}
	
	private func delete() {
		for case let dueDate as DueDate in project.dueDates! {
			for case let doDate as DoDate in dueDate.doDates! {
				context.delete(doDate)
			}
			context.delete(dueDate)
		}
		context.delete(project)
		presentationMode.wrappedValue.dismiss()
		onDelete()
	}
	
	private func deleteDueDate(atOffsets offsets: IndexSet) {
		for i in offsets {
			let dueDate = dueDates[i]
			
			for case let doDate as DoDate in dueDate.doDates! {
				context.delete(doDate)
			}
			context.delete(dueDate)
		}
	}
	
	private func deleteDoDate(atOffsets offsets: IndexSet) {
		for i in offsets {
			context.delete(doDates[i])
		}
	}
}

//struct ProjectDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        ProjectDetailView()
//    }
//}
