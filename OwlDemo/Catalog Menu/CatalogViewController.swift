//
//  CatalogViewController.swift
//  Example
//
//  Created by dan on 12/02/2019.
//  Copyright © 2019 FlowKit2. All rights reserved.
//

import UIKit

class CatalogViewController: UIViewController {

	@IBOutlet public var tableView: UITableView!

	private var tableDirector: TableDirector?

	override func viewDidLoad() {
		super.viewDidLoad()

		self.title = "FlowKit"

		prepareTable()
		prepareTableContents()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Test", style: .plain, target: self, action: #selector(didTap))
	}

    @objc public func didTap(_ sender: Any) {
        tableDirector?.reload(afterUpdate: { d in
            d.remove(section: 0)
            return .automatic
        }, completion: nil)
    }
    
	// MARK: - Table Configuration -

	private func prepareTable() {
		tableDirector = TableDirector(table: tableView)
		tableDirector?.rowHeight = .explicit(60)
        
		let catalogAdapter = TableCellAdapter<CatalogItem, CatalogItemCell>()
		tableDirector?.registerCellAdapter(catalogAdapter)

        catalogAdapter.events.rowHeight = { ctx in
            return 60.0
        }
		catalogAdapter.events.dequeue = { ctx in
			ctx.cell?.item = ctx.element
		}

		catalogAdapter.events.didSelect = { ctx in
			self.selectCatalogItem(ctx.element)
			return .deselectAnimated
		}
        
        catalogAdapter.events.editStyle = { ctx in
            return .delete
        }
        
        catalogAdapter.events.canEditRow = { ctx in
            return true
        }
        
        catalogAdapter.events.deleteConfirmTitle = { ctx in
            return "Delete"
        }
        
        catalogAdapter.events.commitEdit = { [weak self] ctx, style in
            guard let indexPath = ctx.indexPath else { return }
            self?.tableDirector?.reload(afterUpdate: { dir in
                dir.sections[indexPath.section].remove(at: indexPath.row)
                return UITableView.RowAnimation.none
            }, completion: nil)
        }
	}

	// MARK: - Prepare Contents -

	private func prepareTableContents() {
		let demo1 = CatalogItem(id: "demo1", icon: "tableView".image, title: "Contacts")
        demo1.shortDesc = "An example of UITableView with different models managed by different adapters. It also shows how to reload data automatically and autolayout on cells."

		let demo2 = CatalogItem(id: "demo2", icon: "collectionView".image, title: "Contacts")
		demo2.shortDesc = ""
        
        tableDirector?.add(elements: [demo1,demo2])
		tableDirector?.reload()
	}

	// MARK: - Helpers -

	private func selectCatalogItem(_ item: CatalogItem?) {
		guard let vc = controllerForCatalogItem(item) else {
			return
		}
		navigationController?.pushViewController(vc, animated: true)
	}

	private func controllerForCatalogItem(_ item: CatalogItem?) -> UIViewController? {
		guard let item = item else { return nil }
		switch item.id {
		case "demo1":
            return ContactsController.create(items: DataSet.shared.companies)
		case "demo2":
			return EmojiBrowserController.create(items: DataSet.shared.emoji)

		default:
			return nil
		}
	}
	
}
