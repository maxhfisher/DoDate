//
//  DoDatesView.swift
//  DoDate
//
//  Created by Max Fisher on 11/14/20.
//

import SwiftUI

struct DoDatesView: View {
    var body: some View {
		NavigationView {
			Text("Do Dates")
				.navigationTitle("Do Dates")
				.navigationBarItems(trailing: Button {} label: {
					Image(systemName: "plus")
				})
		}
    }
}

struct DoDatesView_Previews: PreviewProvider {
    static var previews: some View {
        DoDatesView()
    }
}
