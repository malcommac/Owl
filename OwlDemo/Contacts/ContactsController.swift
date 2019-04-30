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
        }
        director?.registerCellAdapter(companyItem)

        director?.add(elements: self.elements)
        director?.reload()
    }
    
    private func openCompanyPeople(_ company: ContactCompany?) {
        guard let company = company else { return }
        let vc = ContactsController.create(items: company.peoples)
        navigationController?.pushViewController(vc, animated: true)
    }

}
