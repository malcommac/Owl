//
//  Owl
//  A declarative type-safe framework for building fast and flexible list with Tables & Collections
//
//  Created by Daniele Margutti
//   - Web: https://www.danielemargutti.com
//   - Twitter: https://twitter.com/danielemargutti
//   - Mail: hello@danielemargutti.com
//
//  Copyright © 2019 Daniele Margutti. Licensed under Apache 2.0 License.
//

import UIKit

public protocol ReusableCellViewProtocol: class {

//    static func reusableViewType() -> AnyObject.Type
//    static func reusableViewClass() -> AnyClass
//    static func reusableViewIdentifier() -> String
//    static func reusableViewSource() -> ReusableViewSource
//
//    static func registerReusableView(inTable table: UITableView?, as type: ReusableViewRegistrationType)
//    static func registerReusableView(inCollection collection: UICollectionView?, as type: ReusableViewRegistrationType)
}

public enum ReusableViewSource {
    case fromStoryboard
    case fromXib(name: String?, bundle: Bundle?)
    case fromClass
}

/*
public extension ReusableCellViewProtocol {
    
    static func reusableViewClass() -> AnyClass {
        return self
    }

    static func reusableViewType() -> AnyObject.Type {
		return reusableViewClass().self
	}

//    static func reusableViewSource() -> ReusableViewSource {
//        return .fromStoryboard
//    }

    static func reusableViewIdentifier() -> String {
		return String(describing: reusableViewType())
	}

    static func registerReusableView(inTable table: UITableView?, as registrationType: ReusableViewRegistrationType) {
        let reusableID = reusableViewIdentifier()
        let reusableClass: AnyClass = reusableViewClass()
        let reusableSource = reusableViewSource()
        
		switch reusableSource {
		case .fromStoryboard:
			if registrationType.isHeaderFooter {
				fatalError("Cannot load header/footer from storyboard. Use another source (xib/class) instead.")
			}
			break

		case .fromXib(let name, let bundle):
			let srcBundle = (bundle ?? Bundle.init(for: reusableClass))
			let srcNib = UINib(nibName: (name ?? reusableID), bundle: srcBundle)

			if registrationType == .cell {
				table?.register(srcNib, forCellReuseIdentifier: reusableID)
			} else {
				table?.register(srcNib, forHeaderFooterViewReuseIdentifier: reusableID)
			}

		case .fromClass:

			if registrationType == .cell {
				table?.register(reusableClass, forCellReuseIdentifier: reusableID)
			} else {
				table?.register(reusableClass, forHeaderFooterViewReuseIdentifier: reusableID)
			}
		}
	}

    static func registerReusableView(inCollection collection: UICollectionView?, as type: ReusableViewRegistrationType) {
        
        let reusableID = reusableViewIdentifier()
        let reusableClass: AnyClass = reusableViewClass()
        let reusableSource = reusableViewSource()

		switch reusableSource {
		case .fromStoryboard:
			if type.isHeaderFooter {
				fatalError("Cannot load header/footer from storyboard. Use another source (xib/class) instead.")
			}
			break

		case .fromXib(let name, let bundle):
			let srcBundle = (bundle ?? Bundle.init(for: reusableClass))
			let srcNib = UINib(nibName: (name ?? reusableID), bundle: srcBundle)

			switch type {
			case .cell:
				collection?.register(srcNib, forCellWithReuseIdentifier: reusableID)
			case .header:
				collection?.register(srcNib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: reusableID)
			case .footer:
				collection?.register(srcNib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: reusableID)
			}

		case .fromClass:
			switch type {
			case .cell:
				collection?.register(reusableClass, forCellWithReuseIdentifier: reusableID)
			case .header:
				collection?.register(reusableClass, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: reusableID)
			case .footer:
				collection?.register(reusableClass, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: reusableID)
			}

		}
	}

}
*/

public enum ReusableViewRegistrationType {
	case cell
	case header
	case footer

	var isHeaderFooter: Bool {
		guard case .cell = self else {
			return true
		}
		return false
	}
}


extension UITableViewCell : ReusableCellViewProtocol {
//    public static func reusableViewClass() -> AnyClass {
//        return self
//    }
//
////    public static func reusableViewSource() -> ReusableViewSource {
////            return .fromStoryboard
    }
//}
//
extension UICollectionReusableView: ReusableCellViewProtocol {
//    public static func reusableViewClass() -> AnyClass {
//        return self
//    }
//
////    public static func reusableViewSource() -> ReusableViewSource {
////        return .fromStoryboard
    }
//}
//
