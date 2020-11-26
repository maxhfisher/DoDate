//
//  DueDatesView.swift
//  DoDate
//
//  Created by Max Fisher on 11/14/20.
//

import SwiftUI

struct DueDatesView: View {
	@Environment(\.managedObjectContext) var context
	
	@FetchRequest(entity: DueDate.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \DueDate.date, ascending: true)]) var dueDates: FetchedResults<DueDate>
	
	@State private var showingAddDueDateView = false
	
    var body: some View {
		NavigationView {
			Group {
				if dueDates.isEmpty {
					Text("No Due Dates Yet")
						.font(.largeTitle)
						.foregroundColor(.secondary)
				} else {
					List {
						ForEach(dueDates, id: \.self) { dueDate in
							Text(dueDate.name ?? "")
						}
						.onDelete(perform: delete)
					}
				}
			}
			.navigationTitle("Due Dates")
			.navigationBarItems(leading: EditButton(), trailing: Button { showingAddDueDateView = true } label: {
				Image(systemName: "plus")
			})
			.sheet(isPresented: $showingAddDueDateView, content: { NewDueDateView() })
		}
    }
	
	func delete(atOffsets offsets: IndexSet) {
		for index in offsets {
			context.delete(dueDates[index])
		}
		try? context.save()
	}
}

struct NewDueDateView: View {
	@Environment(\.managedObjectContext) var context
	@Environment(\.presentationMode) var presentationMode
	
	@State private var projectSelection: Project?
	@State private var name = ""
	@State private var details = ""
	@State private var date = Date(timeIntervalSinceNow: 86400)
	
	@State private var showingErrorAlert = false
	@State private var showingNewProjectView = false
	
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
					
					Section {
						HStack {
							Spacer()
							Button("Save") {
								let hapticGenerator = UINotificationFeedbackGenerator()
								hapticGenerator.prepare()
								
								if projectSelection == nil || name.isEmpty || details.isEmpty {
									hapticGenerator.notificationOccurred(.error)
								} else {
									do {
										let newDueDate = DueDate(context: context)
										newDueDate.project = projectSelection
										newDueDate.name = name
										newDueDate.details = details
										newDueDate.id = UUID()
										newDueDate.date = date
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
								Alert(title: Text("There was an error saving your due date"))
							})
							Spacer()
							}
						}
					}
				}
				.navigationBarTitleDisplayMode(.inline)
				.navigationTitle("New Due Date")
				.navigationBarItems(trailing: Button("Cancel") { presentationMode.wrappedValue.dismiss() })
			}
		}
	}

	struct DueDateSelectionView: View {
		@Binding var selection: DueDate?
		let project: Project
		
		var body: some View {
			NavigationLink(destination: DueDatesListView(project: project, selection: $selection)) {
				HStack {
					Text("DueDate")
					Spacer()
					if selection != nil {
						Text(selection?.name ?? "")
							.foregroundColor(.secondary)
					}
				}
			}
		}
		
		private struct DueDatesListView: View {
			@Environment(\.managedObjectContext) var context
			@Environment(\.presentationMode) var presentationMode
			
			let project: Project
			@FetchRequest(entity: DueDate.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \DueDate.date, ascending: true)], predicate: NSPredicate(format: "date > %@", NSDate())) var dueDates: FetchedResults<DueDate>
			
			@Binding var selection: DueDate?
			@State private var showingAddDueDateView = false
			
			var body: some View {
				Form {
					Section {
						ForEach(dueDates, id: \.self) { dueDate in
							if dueDate.project?.id == project.id {
								Button {
									withAnimation {
										selection = dueDate
									}
									presentationMode.wrappedValue.dismiss()
								} label: {
									HStack {
										Text(dueDate.name ?? "")
										Spacer()
										if selection == dueDate {
											Image(systemName: "checkmark")
												.foregroundColor(.accentColor)
										}
									}
								}
								.foregroundColor(.primary)
								.accessibilityElement(children: .ignore)
								.accessibility(label: Text(dueDate.name ?? ""))
								.accessibility(addTraits: selection == dueDate ? [.isSelected]:[])
							}
						}
					}
					Section {
						Button("New Due Date") {
							showingAddDueDateView = true
						}
				}
			}
			.navigationTitle("Select a Due Date")
			.sheet(isPresented: $showingAddDueDateView) { NewDueDateView().environment(\.managedObjectContext, context) }
		}
	}
}

struct DueDatesView_Previews: PreviewProvider {
    static var previews: some View {
        DueDatesView()
    }
}
