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
					DueDateIndividualView(dueDate: project.dueDates!.allObjects[i] as! DueDate)
				}
				.padding(.bottom)
				
				Text("Do Dates")
					.font(.title)
					.fontWeight(.bold)
				ForEach(0..<project.doDates!.count, id: \.self) { i in
					DoDateIndividualView(doDate: project.doDates!.allObjects[i] as! DoDate)
				}
				Spacer()
			}
			.padding([.leading, .trailing])
			Spacer()
		}
		.navigationBarTitle(project.name ?? "")
    }
}

//struct ProjectDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        ProjectDetailView()
//    }
//}
