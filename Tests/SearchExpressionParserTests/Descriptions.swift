//  Copyright © 2018 Christian Tietze. All rights reserved. Distributed under the MIT License.

import SearchExpressionParser

// Here are String representations that ease reading in failure statements

extension ContainsNode: CustomStringConvertible {
    public var description: String {
        return "ContainsNode(\"\(self.string)\")"
    }
}

extension NotNode: CustomStringConvertible {
    public var description: String {
        return "NotNode(\(self.expression))"
    }
}

extension AndNode: CustomStringConvertible {
    public var description: String {
        return "AndNode(lhs: \(self.lhs), rhs: \(self.rhs))"
    }
}

extension OrNode: CustomStringConvertible {
    public var description: String {
        return "OrNode(lhs: \(self.lhs), rhs: \(self.rhs))"
    }
}
