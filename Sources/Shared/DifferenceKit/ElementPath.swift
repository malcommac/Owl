import Foundation

public struct ElementPath: Hashable {
	public var element: Int
	public var section: Int
	
	@inlinable
	public init(element: Int, section: Int) {
		self.element = element
		self.section = section
	}
}
