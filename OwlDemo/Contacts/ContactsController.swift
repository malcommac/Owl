//
//  ExampleTableController.swift
//  Example
//
//  Created by dan on 28/03/2019.
//  Copyright © 2019 FlowKit2. All rights reserved.
//

import UIKit

public class ContactsController: UIViewController {

    @IBOutlet public var table: UITableView!
    
    private var director: TableDirector?
    private var elements = [ElementRepresentable]()
    
    static func create(items: [ElementRepresentable]) -> ContactsController {
		let storyboard = UIStoryboard(name: "ContactsController", bundle: Bundle.main)
		let vc = storyboard.instantiateViewController(withIdentifier: "ContactsController") as! ContactsController
        vc.elements = items
        return vc
	}
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        director = TableDirector(table: table)
        
        let header = TableHeaderFooterAdapter<GroupHeaderView> { config in
            config.events.dequeue = { ctx in
                ctx.view?.headerTitleLabel?.text = "..."
                ctx.view?.headerSubtitleLabel?.text = "Section #\(ctx.section)"
            }
            config.events.height = { _ in
                return 30
            }
        }
        
        let singleItem = TableCellAdapter<ContactSingle,ContactSingleCell> { dr in
            dr.events.dequeue = { ctx in
                ctx.cell?.item = ctx.element
            }
        }
        director?.registerCellAdapter(singleItem)
        
        let companyItem = TableCellAdapter<ContactCompany,ContactCompanyCell> { dr in
            dr.events.dequeue = { ctx in
                ctx.cell?.item = ctx.element
            }
            dr.events.didSelect = { ctx in
                self.openCompanyPeople(ctx.element)
                return .deselectAnimated
            }
            dr.events.canEditRow = { ctx in
                return true
            }
            dr.events.editStyle = { ctx in
                return .delete
            }
            dr.events.deleteConfirmTitle = { ctx in
                return "Remove"
            }
            dr.events.commitEdit = { (ctx, action) in
                guard let indexPath = ctx.indexPath else { return }
                self.director?.reload(afterUpdate: { _ in
                    self.director?.remove(indexPath: indexPath)
                    return .automatic
                }, completion: nil)
            }
        }
        director?.registerCellAdapter(companyItem)

        let section = TableSection(elements: self.elements, headerView: header, footerView: nil)
        director?.add(section: section)
        director?.reload()
    }
    
    private func openCompanyPeople(_ company: ContactCompany?) {
        guard let company = company else { return }
        let vc = ContactsController.create(items: company.peoples)
        navigationController?.pushViewController(vc, animated: true)
    }

}
