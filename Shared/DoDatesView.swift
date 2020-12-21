//
//  DoDatesView.swift
//  DoDate
//
//  Created by Max Fisher on 11/14/20.
//

import SwiftUI
import UserNotifications

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
							HStack {
								ProjectCategoryView(category: ProjectCategory(rawValue: doDate.project!.category!)!)
								VStack(alignment: .leading) {
									Text(doDate.task!)
										.font(.title3)
										.fontWeight(.semibold)
										.lineLimit(1)
									Text(Date.dateString(from: Calendar.current.dateComponents([.month, .day, .year], from: doDate.date!), withFormat: "MM/dd/yy"))
										.font(.headline)
									Text(doDate.dueDate!.name!)
										.font(.headline)
										.lineLimit(1)
									Text("Due \(Date.dateString(from: Calendar.current.dateComponents([.month, .day, .year], from: doDate.dueDate!.date!), withFormat: "MM/dd/yy"))")
										.font(.caption)
								}
							}
						}
						.onDelete(perform: delete)
					}
				}
			}
			.navigationTitle("Do Dates")
			.navigationBarItems(leading: EditButton(), trailing: Button { showingNewDoDateView = true } label: {
				Image(systemName: "plus")
			})
			.sheet(isPresented: $showingNewDoDateView, content: { NewDoDateView().environment(\.managedObjectContext, context) })
		}
    }
	
	func delete(atOffsets offsets: IndexSet) {
		for i in offsets {
			context.delete(doDates[i])
		}
		try? context.save()
	}
}

struct NewDoDateView: View {
	@Environment(\.managedObjectContext) var context
	@Environment(\.presentationMode) var presentationMode
	
	@State private var projectSelection: Project?
	@State private var dueDateSelection: DueDate?
	@State private var task = ""
	@State private var date = Calendar.current.startOfDay(for: Date(timeIntervalSinceNow: 86400 * 2)).addingTimeInterval(-1)
	@State private var notify = false
	
	var body: some View {
		NavigationView {
			Form {
				Section {
					ProjectSelectionView(selection: Binding(get: { self.projectSelection }, set: { newValue in
						if newValue?.id != projectSelection?.id {
							dueDateSelection = nil
						}
						self.projectSelection = newValue
					}))
					if projectSelection != nil {
						DueDateSelectionView(selection: $dueDateSelection, project: projectSelection!)
					}
				}
				
				if dueDateSelection != nil {
					Section {
						TextField("Task", text: $task)
					}
					Section(footer: Text("Send a notification to remind you of your Do Date")) {
						DatePicker("Date", selection: $date, in: Date(timeIntervalSinceNow: 60)...Calendar.current.startOfDay(for: dueDateSelection!.date!.addingTimeInterval(86400)).addingTimeInterval(-1), displayedComponents: notify ? [.date, .hourAndMinute]:.date)
							.datePickerStyle(GraphicalDatePickerStyle())
						Toggle("Alert", isOn: $notify.animation())
					}
					Section {
						Button {
							let hapticGenerator = UINotificationFeedbackGenerator()
							hapticGenerator.prepare()

							if projectSelection == nil || dueDateSelection == nil || task.isEmpty {
								hapticGenerator.notificationOccurred(.error)
							} else {
								do {
									let newDoDate = DoDate(context: context)
									newDoDate.project = projectSelection!
									newDoDate.dueDate = dueDateSelection!
									newDoDate.task = task
									newDoDate.date = date
									newDoDate.notify = notify
									newDoDate.id = UUID()

									if notify {
										if Date(timeIntervalSinceNow: 0) <= date {
											addNotificationFor(newDoDate) { success, error in
												if !success {
													hapticGenerator.notificationOccurred(.error)
													print(error!.localizedDescription)
													return
												}
											}
											try context.save()
											hapticGenerator.notificationOccurred(.success)
											presentationMode.wrappedValue.dismiss()
										} else {
											hapticGenerator.notificationOccurred(.warning)
											date = Date(timeIntervalSinceNow: 300)
										}
									} else {
										try context.save()
										hapticGenerator.notificationOccurred(.success)
										presentationMode.wrappedValue.dismiss()
									}
								} catch {
									print(error.localizedDescription)
									hapticGenerator.notificationOccurred(.error)
								}
							}
						} label: {
							HStack {
								Spacer()
								Text("Save")
								Spacer()
							}
						}
					}
				}
			}
			.navigationBarTitleDisplayMode(.inline)
			.navigationTitle("New Do Date")
			.navigationBarItems(trailing: Button("Cancel") { presentationMode.wrappedValue.dismiss() })
		}
	}
	
	func addNotificationFor(_ doDate: DoDate, completion: @escaping (Bool, Error?) -> Void) {
		enum AddNotificationError: LocalizedError {
			case failedToGetAuthorization
		}
		
		let addRequest = {
			let notificationContent = UNMutableNotificationContent()
			notificationContent.title = "To Do"
			notificationContent.subtitle = doDate.task!
			notificationContent.sound = UNNotificationSound.default
			notificationContent.badge = 1
			
			UNUserNotificationCenter.current().add(UNNotificationRequest(identifier: doDate.id?.uuidString ?? "", content: notificationContent, trigger: UNTimeIntervalNotificationTrigger(timeInterval: doDate.date!.timeIntervalSince(Date()), repeats: false)))
		}
		
		let notificationCenter = UNUserNotificationCenter.current()
		notificationCenter.getNotificationSettings { settings in
			if settings.authorizationStatus == .authorized {
				addRequest()
			} else {
				notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
					if success {
						addRequest()
					}
					completion(success, error)
				}
			}
		}
	}
}

struct DoDatesView_Previews: PreviewProvider {
    static var previews: some View {
        DoDatesView()
    }
}
