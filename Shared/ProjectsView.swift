//
//  ProjectsView.swift
//  DoDate
//
//  Created by Max Fisher on 11/14/20.
//

import SwiftUI

struct ProjectsView: View {
	@EnvironmentObject var model: Model
	
    var body: some View {
		NavigationView {
			List(model.projects, id: \.self) { project in
				Text(project.entity.name ?? "")
			}
			.navigationTitle("Projects")
			.navigationBarItems(trailing: Button {} label: {
				Image(systemName: "plus")
			})
		}
    }
}

struct ProjectsView_Previews: PreviewProvider {
    static var previews: some View {
		ProjectsView().environmentObject(Model())
    }
}
