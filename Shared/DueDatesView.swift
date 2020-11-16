//
//  DueDatesView.swift
//  DoDate
//
//  Created by Max Fisher on 11/14/20.
//

import SwiftUI

struct DueDatesView: View {
	@Environment(\.managedObjectContext) var context
	
	@FetchRequest(entity: DueDate.entity(), sortDescriptors: []) var dueDates: FetchedResults<DueDate>
	
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
	
	@FetchRequest(entity: Project.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Project.name, ascending: true)]) var projects: FetchedResults<Project>
	
	@State private var projectSelection = 0
	@State private var name = ""
	@State private var details = ""
	@State private var date = Date(timeIntervalSinceNow: 86400)
	
	@State private var showingErrorAlert = false
	
	var body: some View {
		NavigationView {
			Form {
				Section {
					Picker("Project", selection: $projectSelection) {
						if projects.isEmpty {
							Text("No Projects Yet")
						} else {
							ForEach(0..<projects.count) {
								Text(projects[$0].name ?? "")
							}
						}
					}
				}
				
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
							
							if projects.isEmpty || name.isEmpty || details.isEmpty {
								hapticGenerator.notificationOccurred(.error)
							} else {
								do {
									let newDueDate = DueDate(context: context)
									newDueDate.project = projects[projectSelection]
									newDueDate.name = name
									newDueDate.details = details
									newDueDate.id = UUID()
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
			.navigationBarTitleDisplayMode(.inline)
			.navigationTitle("New Due Date")
			.navigationBarItems(trailing: Button("Cancel") { presentationMode.wrappedValue.dismiss() })
		}
	}
}

struct DueDatesView_Previews: PreviewProvider {
    static var previews: some View {
        DueDatesView()
    }
}
