//  Copyright © 2018 Christian Tietze. All rights reserved. Distributed under the MIT License.

public protocol Expression { }

/// Wildcard that is satisfied by any string.
public struct AnythingNode: Expression { }

public struct ContainsNode: Expression {
    public let string: String

    public init(_ string: String) {
        self.string = string
    }
}
