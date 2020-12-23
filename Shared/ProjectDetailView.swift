//
//  ProjectDetailView.swift
//  DoDate
//
//  Created by Max Fisher on 12/21/20.
//

import SwiftUI

struct ProjectDetailView: View {
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
					ForEach(0..<project.dueDates!.count, id: \.self) { i in
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
								Spacer()
							}
						}
					}
					.padding(.bottom)
					
					Text("Do Dates")
						.font(.title)
						.fontWeight(.bold)
					ForEach(0..<project.doDates!.count, id: \.self) { i in
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
						}
					}
					Spacer()
				}
				.padding([.leading, .trailing])
				Spacer()
			}
		}
		.navigationBarTitle(project.name ?? "")
    }
}

//struct ProjectDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        ProjectDetailView()
//    }
//}
