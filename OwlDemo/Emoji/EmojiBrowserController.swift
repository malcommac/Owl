//
//  EmojiBrowserController.swift
//  Example
//
//  Created by dan on 04/04/2019.
//  Copyright © 2019 FlowKit2. All rights reserved.
//

import UIKit

public class EmojiBrowserController: UIViewController {
    
    @IBOutlet public var collection: UICollectionView!
    
    private var emojiList = [[String]]()
    
    private var director: FlowCollectionDirector?
    
    static func create(items: [[String]]) -> EmojiBrowserController {
        let storyboard = UIStoryboard(name: "EmojiBrowserController", bundle: Bundle.main)
        let vc = storyboard.instantiateViewController(withIdentifier: "EmojiBrowserController") as! EmojiBrowserController
        vc.emojiList = items
        return vc
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        director = FlowCollectionDirector(collection: collection)
        
        // CELL ADAPTER
        let emojiAdapter = CollectionCellAdapter<String, EmojiCell> { adapter in
            adapter.events.dequeue = { ctx in
                ctx.cell?.emoji = ctx.element
            }
            adapter.events.itemSize = { ctx in
                return CGSize(width: 50, height: 50)
            }
            adapter.events.endDisplay = { ctx in
                debugPrint("end!")
            }
        }
        director?.registerAdapter(emojiAdapter)
        
        // HEADER ADAPTER
		let headerAdapter = CollectionHeaderFooterAdapter<EmojiHeaderView> { cfg in
			cfg.events.dequeue = { ctx in
				ctx.view?.titleLabel.text = ctx.section?.identifier ?? "-"
			}
            cfg.events.referenceSize = { ctx in
                return CGSize(width: self.collection.frame.size.width, height: 22)
            }
		}
        director?.registerHeaderFooterAdapter(headerAdapter)
        
        // DATA
        for (idx, rawSection) in emojiList.enumerated() {
            let section = CollectionSection(id: "Section \(idx)" ,elements: rawSection)
            section.minimumInterItemSpacing = 2
            section.minimumLineSpacing = 2
            section.headerView = headerAdapter
            section.headerSize = CGSize(width: self.collection.frame.size.width, height: 30)
            
            director?.add(section: section)
        }
		
        director?.reload(afterUpdate: nil, completion: nil)
    }
    
    @IBAction public func shuffleAllEmojiInSection(_ sender: Any) {
        director?.reload(afterUpdate: { dir in
            //for section in dir.sections  {
                let shuffledEmoji = dir.firstSection!.elements.shuffled()
                dir.firstSection?.set(elements: shuffledEmoji)
            dir.firstSection!.move(from: 0, to: dir.firstSection!.elements.count - 1)
            //}
        }, completion: nil)
    }
    
    @IBAction public func shuffleSection(_ sender: Any) {
        director?.reload(afterUpdate: { dir in
            let shuffledSections = dir.sections.shuffled()
            dir.set(sections: shuffledSections)
        }, completion: nil)
    }
	
	@IBAction public func shuffleItemsInAllSections(_ sender: Any) {
		director?.reload(afterUpdate: { dir in
			
			for idx in 1..<dir.sections.count {
				let sourceSection = dir.sections[idx]
				var destSection: CollectionSection?
				repeat {
					let nextSectionIdx = Int.random(in: 0..<dir.sections.count)
					if nextSectionIdx != idx {
						destSection = dir.sections[nextSectionIdx]
						break
					}
				} while true
				
				let randomRangeFrom = Int.random(in: 0..<sourceSection.elements.count)
				let randomRangeTo = Int.random(in: randomRangeFrom..<sourceSection.elements.count)
				let subArray = Array(sourceSection.elements[randomRangeFrom..<randomRangeTo])
				destSection?.add(elements: subArray, at: 0)

				
			}
		}, completion: nil)
	}
    
}
