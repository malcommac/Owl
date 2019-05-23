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

public protocol ReusableViewProtocol: class { }

extension UITableViewCell : ReusableViewProtocol { }
extension UICollectionReusableView: ReusableViewProtocol { }

public enum ReusableViewLoadSource {
    case fromStoryboard
    case fromXib(name: String?, bundle: Bundle?)
    case fromClass
}
