//
//  DueDatesView.swift
//  DoDate
//
//  Created by Max Fisher on 11/14/20.
//

import SwiftUI

struct DueDatesView: View {
    var body: some View {
		NavigationView {
			Text("Due Dates")
				.navigationTitle("Due Dates")
				.navigationBarItems(trailing: Button {} label: {
					Image(systemName: "plus")
				})
		}
    }
}

struct DueDatesView_Previews: PreviewProvider {
    static var previews: some View {
        DueDatesView()
    }
}
