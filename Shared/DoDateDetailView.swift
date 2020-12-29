//
//  DoDateDetailView.swift
//  DoDate
//
//  Created by Max Fisher on 12/28/20.
//

import SwiftUI

struct DoDateDetailView: View {
	let doDate: DoDate
	
	@State private var showingEditView = false
	
	@Environment(\.managedObjectContext) var context
	@Environment(\.presentationMode) var presentationMode
	
    var body: some View {
		ScrollView {
			HStack {
				VStack(alignment: .leading) {
					HStack {
						ProjectCategoryView(category: ProjectCategory(rawValue: doDate.project?.category ?? ""))
						Text(Date.dateString(from: Calendar.current.dateComponents([.day, .month, .year], from: doDate.date!), withFormat: "MM/dd/yyyy"))
							.font(.title)
							.fontWeight(.bold)
					}
					.padding(.bottom)
					
					Text("Project")
						.font(.title)
						.fontWeight(.bold)
					NavigationLink(destination: ProjectDetailView(project: doDate.project!)) {
						HStack {
							ProjectCategoryView(category: ProjectCategory(rawValue: doDate.project?.category ?? ""), isSmall: true)
							VStack(alignment: .leading) {
								Text(doDate.project?.name ?? "")
									.font(.title3)
									.fontWeight(.bold)
									.lineLimit(1)
								Text(doDate.project?.details ?? "")
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
					.padding(.bottom)
					
					Text("Due Date")
						.font(.title)
						.fontWeight(.bold)
						.accessibility(hint: Text("Date that this is due"))
					NavigationLink(destination: DueDateDetailView(dueDate: doDate.dueDate!)) {
						HStack {
							ProjectCategoryView(category: ProjectCategory(rawValue: doDate.project?.category ?? ""), isSmall: true)
							VStack(alignment: .leading) {
								Text(doDate.dueDate?.name ?? "")
									.font(.title3)
									.fontWeight(.bold)
									.lineLimit(1)
								Text(doDate.dueDate?.details ?? "")
									.font(.caption)
									.lineLimit(1)
								Text("Due: \(Date.dateString(from: Calendar.current.dateComponents([.day, .month, .year], from: doDate.dueDate!.date!), withFormat: "MM/dd/yyyy"))")
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
					.padding(.bottom)
					
					if doDate.notify {
						HStack {
							Text("Notification Time: ")
								.font(.title)
								.fontWeight(.bold)
							Spacer()
							Text(Date.dateString(from: Calendar.current.dateComponents([.minute, .hour], from: doDate.date!), withFormat: "h:mm a"))
								.foregroundColor(.secondary)
						}
					}
				}
				.padding([.leading, .trailing])
				Spacer()
			}
		}
		.navigationBarTitle(doDate.task ?? "")
		.navigationBarItems(trailing: Button("Edit") { showingEditView = true })
		.sheet(isPresented: $showingEditView) { EditDoDateView(doDate: doDate, onDelete: { presentationMode.wrappedValue.dismiss() }).environment(\.managedObjectContext, context) }
    }
}

struct EditDoDateView: View {
	let doDate: DoDate
	let onDelete: () -> Void
	
	@Environment(\.managedObjectContext) var context
	@Environment(\.presentationMode) var presentationMode
	
	@State private var projectSelection: Project?
	@State private var dueDateSelection: DueDate?
	@State private var task: String
	@State private var date: Date
	@State private var notify: Bool
	
	@State private var showingErrorAlert = false
	@State private var showingDeleteAlert = false
	
	init(doDate: DoDate, onDelete: @escaping () -> Void) {
		self.doDate = doDate
		self.onDelete = onDelete
		
		_projectSelection = State(initialValue: doDate.project)
		_dueDateSelection = State(initialValue: doDate.dueDate)
		_task = State(initialValue: doDate.task ?? "")
		_date = State(initialValue: doDate.date ?? Calendar.current.startOfDay(for: Date(timeIntervalSinceNow: 86400 * 2)).addingTimeInterval(-1))
		_notify = State(initialValue: doDate.notify)
	}
	
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
							showingDeleteAlert = true
						} label: {
							HStack {
								Spacer()
								Text("Delete")
									.foregroundColor(.red)
								Spacer()
							}
						}
						.alert(isPresented: $showingDeleteAlert, content: {
							Alert(title: Text("Are you sure?"), message: Text("This action cannot be undone"), primaryButton: .cancel(), secondaryButton: .destructive(Text("Delete"), action: delete))
						})
					}
				}
			}
			.navigationBarTitleDisplayMode(.inline)
			.navigationTitle("Edit Do Date")
			.navigationBarItems(leading: Button("Cancel") { presentationMode.wrappedValue.dismiss() }, trailing: Button("Save", action: save))
			.alert(isPresented: $showingErrorAlert, content: {
				Alert(title: Text("There was an error saving your Do Date"))
			})
		}
	}
	
	func save() {
		let hapticGenerator = UINotificationFeedbackGenerator()
		hapticGenerator.prepare()

		if projectSelection == nil || dueDateSelection == nil || task.isEmpty {
			hapticGenerator.notificationOccurred(.error)
		} else {
			if context.hasChanges {
				doDate.task = task
				doDate.project = projectSelection!
				doDate.dueDate = dueDateSelection!
				
				do {
					if doDate.notify != notify {
						doDate.notify = notify
						doDate.date = date
						
						if notify {
							if Date(timeIntervalSinceNow: 0) <= date {
								addNotificationFor(doDate) { success, error in
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
							UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [doDate.id!.uuidString])
							try context.save()
							hapticGenerator.notificationOccurred(.success)
							presentationMode.wrappedValue.dismiss()
						}
					} else if notify {
						doDate.notify = notify
						
						if doDate.date != date {
							doDate.date = date
							
							UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [doDate.id!.uuidString])
							addNotificationFor(doDate) { success, error in
								if !success {
									showingErrorAlert = true
									hapticGenerator.notificationOccurred(.error)
									return
								}
							}
							
							try context.save()
							hapticGenerator.notificationOccurred(.success)
							presentationMode.wrappedValue.dismiss()
						} else {
							try context.save()
							hapticGenerator.notificationOccurred(.success)
							presentationMode.wrappedValue.dismiss()
						}
					} else {
						try context.save()
						hapticGenerator.notificationOccurred(.success)
						presentationMode.wrappedValue.dismiss()
					}
				} catch {
					showingErrorAlert = true
					print(error.localizedDescription)
					hapticGenerator.notificationOccurred(.error)
				}
			} else {
				presentationMode.wrappedValue.dismiss()
			}
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
	
	func delete() {
		UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [doDate.id!.uuidString])
		context.delete(doDate)
		presentationMode.wrappedValue.dismiss()
		onDelete()
	}
}

//struct DoDateDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        DoDateDetailView()
//    }
//}
