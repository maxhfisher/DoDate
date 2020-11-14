//
//  ToDoView.swift
//  DoDate
//
//  Created by Max Fisher on 11/14/20.
//

import SwiftUI

struct ToDoView: View {
    var body: some View {
		NavigationView {
			ZStack {
				Text("To Do")
					.navigationTitle("DoDate")
				
				VStack {
					Spacer()
					HStack {
						Spacer()
						PlusButtonView()
							.padding()
					}
				}
			}
		}
    }
}

struct PlusButtonView: View {
	var body: some View {
		Button(action: {}) {
			Image(systemName: "plus")
				.font(.system(size: 50))
				.foregroundColor(.white)
				.padding()
				.background(Color.pink)
				.clipShape(Circle())
		}
	}
}

struct ToDoView_Previews: PreviewProvider {
    static var previews: some View {
        ToDoView()
    }
}
