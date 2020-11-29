//
//  ProjectCategoryView.swift
//  DoDate
//
//  Created by Max Fisher on 11/28/20.
//

import SwiftUI

enum ProjectCategory: String, CaseIterable {
	case work = "work"
	case science = "science"
	case math = "math"
	case geography = "geography"
	case communications = "communications"
	case shopping = "shopping"
	case health = "health"
	case transportation = "transportation"
	case engineering = "engineering"
	case aviation = "aviation"
	case nature = "nature"
	case art = "art"
	case gaming = "gaming"
	case computing = "computing"
	
	var color: Color {
		switch self {
		case .work:
			return .init(.brown)
		case .science:
			return .init(.systemBlue)
		case .math:
			return .yellow
		case .geography:
			return .init(.systemOrange)
		case .communications:
			return .init(.systemGreen)
		case .shopping:
			return .init(.systemYellow)
		case .health:
			return .init(.systemPink)
		case .transportation:
			return .blue
		case .engineering:
			return .gray
		case .aviation:
			return .init(.systemTeal)
		case .nature:
			return .green
		case .art:
			return .init(.systemRed)
		case .gaming:
			return .init(.cyan)
		case .computing:
			return .init(.orange)
		}
	}
	
	var iconName: String {
		switch self {
		case .work:
			return "briefcase.fill"
		case .science:
			return "atom"
		case .math:
			return "function"
		case .geography:
			return "globe"
		case .communications:
			return "envelope.fill"
		case .shopping:
			return "cart.fill"
		case .health:
			return "staroflife.fill"
		case .transportation:
			return "car.fill"
		case .engineering:
			return "gearshape.fill"
		case .aviation:
			return "airplane"
		case .nature:
			return "leaf.fill"
		case .art:
			return "paintpalette.fill"
		case .gaming:
			return "gamecontroller.fill"
		case .computing:
			return "pc"
		}
	}
}

struct ProjectCategoryView: View {
	let category: ProjectCategory
	let isSmall: Bool
	
	init(category: ProjectCategory, isSmall: Bool) {
		self.category = category
		self.isSmall = isSmall
	}
	init(category: ProjectCategory) {
		self.category = category
		self.isSmall = false
	}
	
    var body: some View {
		Image(systemName: category.iconName)
			.font(isSmall ? .title:.largeTitle)
			.padding()
			.frame(width: isSmall ? 50:75)
			.background(category.color)
			.clipShape(Circle())
			.accessibility(label: Text(category.rawValue))
    }
}

struct ProjectCategoryView_Previews: PreviewProvider {
    static var previews: some View {
		ForEach(ProjectCategory.allCases, id: \.self) { cat in
			ProjectCategoryView(category: cat, isSmall: true)
		}
    }
}
