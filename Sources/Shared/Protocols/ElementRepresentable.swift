//
//  ElementRepresentable.swift
//  FlowKit2
//
//  Created by dan on 02/04/2019.
//  Copyright © 2019 FlowKit2. All rights reserved.
//

import Foundation

// MARK: - Copying -

protocol Copying {
    init(original: Self)
}

extension Copying {
    func copy() -> Self {
        return Self.init(original: self)
    }
}

// MARK: - Differentiable -

public protocol Differentiable {
    var differenceIdentifier: String { get }
    func isContentEqual(to other: Differentiable) -> Bool
}

// MARK: - ElementRepresentable -

public protocol ElementRepresentable: Differentiable {
    
    var modelClassIdentifier: String { get }
    
}

public extension ElementRepresentable {
    
    var modelClassIdentifier: String {
        return String(describing: type(of: self))
    }
    
}

// MARK: - DifferentiableSection -

public  protocol DifferentiableSection: Differentiable {
    var elements: [ElementRepresentable] { get }
    init<C: Swift.Collection>(source: Self, elements: C) where C.Element ==  ElementRepresentable
}

extension String: Differentiable, ElementRepresentable {
    
    public var differenceIdentifier: String {
        return self
    }
    
    public func isContentEqual(to other: Differentiable) -> Bool {
        guard let other = other as? String else { return false }
        return self == other
    }
    
}

extension Int: Differentiable, ElementRepresentable {
    
    public var differenceIdentifier: String {
        return String(self)
    }
    
    public func isContentEqual(to other: Differentiable) -> Bool {
        guard let other = other as? Int else { return false }
        return self == other
    }
    
}
