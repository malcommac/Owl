//
//  CollectionAdapterProtocol.swift
//  FlowKit2
//
//  Created by dan on 26/03/2019.
//  Copyright © 2019 FlowKit2. All rights reserved.
//

import UIKit

public protocol CollectionCellAdapterProtocol {

	var modelType: Any.Type { get }
	var modelCellType: Any.Type { get }
	var modelIdentifier: String { get }

	func dequeueCell(inCollection: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell

	@discardableResult
	func registerReusableCellViewForDirector(_ director: CollectionDirector) -> Bool

	@discardableResult
	func dispatchEvent(_ kind: CollectionAdapterEventID, model: Any?,
					   cell: ReusableCellViewProtocol?,
					   path: IndexPath?,
					   params: Any?...) -> Any?
}

public extension CollectionCellAdapterProtocol {

	var modelIdentifier: String {
		return String(describing: modelType)
	}

}
