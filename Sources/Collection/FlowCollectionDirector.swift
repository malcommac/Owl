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

open class FlowCollectionDirector: CollectionDirector, UICollectionViewDelegateFlowLayout {

	// MARK: - Public Properties -

    /// Internal representation of the cell size
    private var _itemSize: ItemSize = .default
    
    /// Define the size of the items into the cell (valid with `UICollectionViewFlowLayout` layout).
    public var itemSize: ItemSize {
        set {
            guard let layout = self.collection?.collectionViewLayout as? UICollectionViewFlowLayout else {
                return
            }
            self._itemSize = newValue
            switch _itemSize {
            case .auto(let estimateSize):
                layout.estimatedItemSize = estimateSize
                layout.itemSize = CGSize(width: 50.0, height: 50.0) // default
            case .explicit(let fixedSize):
                layout.estimatedItemSize = .zero
                layout.itemSize = fixedSize
            case .default:
                layout.estimatedItemSize = .zero
                layout.itemSize = CGSize(width: 50.0, height: 50.0) // default
            }
        }
        get {
            return _itemSize
        }
    }
    
	/// Margins to apply to content.
	/// This is a global value, you can customize a per-section behaviour by implementing `sectionInsets` property into a section.
	/// Initially is set to `.zero`.
	public var sectionsInsets: UIEdgeInsets {
		set { self.layout?.sectionInset = newValue }
		get { return self.layout!.sectionInset }
	}

	/// Minimum spacing (in points) to use between items in the same row or column.
	/// This is a global value, you can customize a per-section behaviour by implementing `minimumInteritemSpacing` property into a section.
	/// Initially is set to `CGFloat.leastNormalMagnitude`.
	public var minimumInteritemSpacing: CGFloat {
		set { self.layout?.minimumInteritemSpacing = newValue }
		get { return self.layout!.minimumInteritemSpacing }
	}

	/// The minimum spacing (in points) to use between rows or columns.
	/// This is a global value, you can customize a per-section behaviour by implementing `minimumInteritemSpacing` property into a section.
	/// Initially is set to `0`.
	public var minimumLineSpacing: CGFloat {
		set { self.layout?.minimumLineSpacing = newValue }
		get { return self.layout!.minimumLineSpacing }
	}

	/// When this property is true, section header views scroll with content until they reach the top of the screen,
	/// at which point they are pinned to the upper bounds of the collection view.
	/// Each new header view that scrolls to the top of the screen pushes the previously pinned header view offscreen.
	///
	/// The default value of this property is `false`.
	@available(iOS 9.0, *)
	public var stickyHeaders: Bool {
		set { self.layout?.sectionHeadersPinToVisibleBounds = newValue }
		get { return (self.layout?.sectionHeadersPinToVisibleBounds ?? false) }
	}

	/// When this property is true, section footer views scroll with content until they reach the bottom of the screen,
	/// at which point they are pinned to the lower bounds of the collection view.
	/// Each new footer view that scrolls to the bottom of the screen pushes the previously pinned footer view offscreen.
	///
	/// The default value of this property is `false`.
	@available(iOS 9.0, *)
	public var stickyFooters: Bool {
		set { self.layout?.sectionFootersPinToVisibleBounds = newValue }
		get { return (self.layout?.sectionFootersPinToVisibleBounds ?? false) }
	}

	/// Set the section reference starting point.
	@available(iOS 11.0, *)
	public var sectionInsetReference: UICollectionViewFlowLayout.SectionInsetReference {
		set { self.layout?.sectionInsetReference = newValue }
		get { return self.layout!.sectionInsetReference }
	}

	/// Return/set the `UICollectionViewFlowLayout` associated with the collection.
	public var layout: UICollectionViewFlowLayout? {
		get { return (self.collection?.collectionViewLayout as? UICollectionViewFlowLayout) }
		set {
			guard let c = newValue else { return }
			self.collection?.collectionViewLayout = c
		}
	}

	// MARK: - Initialization -

	/// Initialize a new flow collection manager.
	/// Note: Layout of the collection must be a UICollectionViewFlowLayout or subclass.
	///
	/// - Parameters:
	///   - collection: collection instance to manage.
	///   - flowLayout: if not `nil` it will be set a `collectionViewLayout` of given collection.
	public init(collection: UICollectionView, flowLayout: UICollectionViewLayout? = nil) {
		let usedLayout = (flowLayout ?? collection.collectionViewLayout)
		guard usedLayout is UICollectionViewFlowLayout else {
			fatalError("FlowCollectionManager require a UICollectionViewLayout layout.")
		}
		if let newLayout = flowLayout {
			collection.collectionViewLayout = newLayout
		}
		super.init(collection)
	}

}

// MARK: - UICollectionViewFlowLayoutDelegate -

public extension FlowCollectionDirector {

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let (model,adapter) = self.context(forItemAt: indexPath)
		switch self.itemSize {
		case .default:
			guard let size = adapter.dispatchEvent(.itemSize, model: model, cell: nil, path: indexPath, params: nil) as? CGSize else {
				return self.layout!.itemSize
			}
			return size
		case .auto(let est):
			return est
		case .explicit(let size):
			return size
		}
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		guard let value = self.sections[section].sectionInsets else {
			return self.sectionsInsets
		}
		return value
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		guard let value = self.sections[section].minimumInterItemSpacing else {
			return self.minimumInteritemSpacing
		}
		return value
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		guard let value = self.sections[section].minimumLineSpacing else {
			return self.minimumLineSpacing
		}
		return value
	}

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        guard let size = sections[section].headerView?.dispatch(.referenceSize, isHeader: true, view: nil, section: sections[section], index: section) as? CGSize else {
            return .zero
        }
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        guard let size = sections[section].footerView?.dispatch(.referenceSize, isHeader: false, view: nil, section: sections[section], index: section) as? CGSize else {
            return .zero
        }
        return size
    }
}
