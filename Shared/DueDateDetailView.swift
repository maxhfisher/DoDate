//
//  DueDateDetailView.swift
//  DoDate
//
//  Created by Max Fisher on 12/25/20.
//

import SwiftUI

struct DueDateDetailView: View {
	let dueDate: DueDate
	
	@Environment(\.presentationMode) var presentationMode
	@Environment(\.managedObjectContext) var context
	
	@State private var showingEditView = false
	
    var body: some View {
		ScrollView {
			HStack {
				VStack(alignment: .leading) {
					HStack {
						ProjectCategoryView(category: ProjectCategory(rawValue: dueDate.project?.category ?? ""))
						VStack(alignment: .leading) {
							Text("Details")
								.font(.title)
								.fontWeight(.bold)
							Text(dueDate.details ?? "")
								.font(.callout)
							Text("Due: \(Date.dateString(from: Calendar.current.dateComponents([.day, .month, .year], from: dueDate.date!), withFormat: "MM/dd/yyyy"))")
								.font(.callout)
						}
					}
					.padding(.bottom)
					
					Text("Project")
						.font(.title)
						.fontWeight(.bold)
					NavigationLink(destination: ProjectDetailView(project: dueDate.project!)) {
						HStack {
							ProjectCategoryView(category: ProjectCategory(rawValue: dueDate.project?.category ?? ""), isSmall: true)
							VStack(alignment: .leading) {
								Text(dueDate.project?.name ?? "")
									.font(.title3)
									.fontWeight(.bold)
									.lineLimit(1)
								Text(dueDate.project?.details ?? "")
									.font(.caption)
									.lineLimit(3)
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
					.padding(.bottom)
					
					Text("Do Dates")
						.font(.title)
						.fontWeight(.bold)
						.accessibility(hint: Text("Dates things are to be done"))
					ForEach(0..<dueDate.doDates!.count) { i in
						NavigationLink(destination: DoDateDetailView(doDate: dueDate.doDates!.allObjects[i] as! DoDate)) {
							HStack {
								ProjectCategoryView(category: ProjectCategory(rawValue: dueDate.project?.category ?? ""), isSmall: true)
								VStack(alignment: .leading) {
									Text((dueDate.doDates?.allObjects[i] as! DoDate).task!)
										.font(.title3)
										.fontWeight(.bold)
										.lineLimit(1)
									Text(Date.dateString(from: Calendar.current.dateComponents([.day, .month, .year], from: (dueDate.doDates?.allObjects[i] as! DoDate).date!), withFormat: "MM/dd/yyyy"))
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
				}
				.padding([.leading, .trailing])
				Spacer()
			}
		}
		.navigationTitle(dueDate.name!)
		.navigationBarItems(trailing: Button("Edit") { showingEditView = true })
		.sheet(isPresented: $showingEditView, content: { EditDueDateView(dueDate: dueDate, onDelete: { presentationMode.wrappedValue.dismiss() }).environment(\.managedObjectContext, context) })
    }
}

struct EditDueDateView: View {
	let onDelete: () -> Void
	let dueDate: DueDate
	
	@Environment(\.managedObjectContext) var context
	@Environment(\.presentationMode) var presentationMode
	
	@FetchRequest(entity: DoDate.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \DoDate	.date, ascending: true)]) var doDates: FetchedResults<DoDate>
	
	@State private var projectSelection: Project?
	@State private var name: String
	@State private var details: String
	@State private var date: Date
	
	@State private var showingErrorAlert = false
	@State private var showingNewProjectView = false
	@State private var showingDeleteAlert = false
	
	init(dueDate: DueDate, onDelete: @escaping () -> Void) {
		self.dueDate = dueDate
		self.onDelete = onDelete
		
		_name = State(initialValue: dueDate.name ?? "")
		_details = State(initialValue: dueDate.details ?? "")
		_date = State(initialValue: dueDate.date ?? Date())
		_projectSelection = State(initialValue: dueDate.project)
	}
	
	var body: some View {
		NavigationView {
			Form {
				Section {
					ProjectSelectionView(selection: $projectSelection)
				}
				
				if projectSelection != nil {
					Section {
						TextField("Name", text: $name)
						TextField("Details", text: $details)
					}
					
					Section {
						DatePicker("Date", selection: $date, in: Date()..., displayedComponents: .date)
							.datePickerStyle(GraphicalDatePickerStyle())
					}
					
					Section(header: Text("Do Dates")) {
						List {
							ForEach(doDates, id: \.self) { doDate in
								if doDate.project?.id == dueDate.project?.id {
									HStack {
										ProjectCategoryView(category: ProjectCategory(rawValue: doDate.project?.category ?? ""), isSmall: true)
										VStack(alignment: .leading) {
											Text(doDate.task ?? "")
												.font(.title3)
												.fontWeight(.bold)
											Text(Date.dateString(from: Calendar.current.dateComponents([.day, .month, .year], from: doDate.date ?? Date()), withFormat: "MM/dd/yyyy"))
												.font(.caption)
										}
									}
								}
							}
							.onDelete(perform: deleteDoDate)
						}
					}
					
					Section {
						HStack {
							Spacer()
							Button("Delete Due Date") {
								showingDeleteAlert = true
							}
							.foregroundColor(.red)
							.alert(isPresented: $showingDeleteAlert, content: {
								Alert(title: Text("Delete Due Date?"), message: Text("Are you sure? All associated Do Dates will be deleted too. This actiion cannot be undone."), primaryButton: .cancel(), secondaryButton: .destructive(Text("Delete"), action: delete))
							})
							Spacer()
						}
					}
				}
			}
			.navigationBarTitleDisplayMode(.inline)
			.navigationTitle("New Due Date")
			.navigationBarItems(leading: Button("Cancel") { presentationMode.wrappedValue.dismiss() }, trailing: Button("Save", action: save))
			.alert(isPresented: $showingErrorAlert, content: {
				Alert(title: Text("There was an error saving your due date"))
			})
		}
	}
	
	func save() {
		let hapticGenerator = UINotificationFeedbackGenerator()
		hapticGenerator.prepare()
		
		if projectSelection == nil || name.isEmpty || details.isEmpty {
			hapticGenerator.notificationOccurred(.error)
		} else {
			dueDate.project = projectSelection
			dueDate.name = name
			dueDate.details = details
			dueDate.date = date
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
	func delete() {
		presentationMode.wrappedValue.dismiss()
		onDelete()
		for case let doDate as DoDate in dueDate.doDates!.allObjects {
			context.delete(doDate)
		}
		context.delete(dueDate)
	}
	func deleteDoDate(atOffsets offsets: IndexSet) {
		for i in offsets {
			context.delete(doDates[i])
		}
	}
}


//struct DueDateDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        DueDateDetailView()
//    }
//}
