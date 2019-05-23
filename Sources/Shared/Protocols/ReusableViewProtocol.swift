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

// Just be sure it's supported type.
public protocol ReusableViewProtocol: class { }
extension UITableViewCell : ReusableViewProtocol { }
extension UICollectionReusableView: ReusableViewProtocol { }

/// Load reusable view (cell/view for header/footer) source:
///
/// - fromStoryboard: from storyboard (not supported for header/footer in table). Uses cell prototypes of the managed table/collection.
/// - fromXib: load the root view from xib (if xib name is `nil` it uses the same name of the class as xib filename, if bundle is `nil` it will use the bundle where the class is located.
/// - fromClass: load from class (via code).
public enum ReusableViewLoadSource {
    case fromStoryboard
    case fromXib(name: String?, bundle: Bundle?)
    case fromClass
}
