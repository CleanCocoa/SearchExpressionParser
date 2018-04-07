//  Copyright © 2018 Christian Tietze. All rights reserved. Distributed under the MIT License.

struct AnyEquatable<Target>: Equatable {
    typealias Comparer = (Target, Target) -> Bool

    let _target: Target
    let _comparer: Comparer

    init(target: Target, comparer: @escaping Comparer) {
        _target = target
        _comparer = comparer
    }
}

func ==<T>(lhs: AnyEquatable<T>, rhs: AnyEquatable<T>) -> Bool {
    return lhs._comparer(lhs._target, rhs._target)
}

// Hide the `AnyEquatable<...>(...)` portion from assertion failures
extension AnyEquatable: CustomDebugStringConvertible, CustomStringConvertible  {
    var description: String {
        return "\(_target)"
    }

    var debugDescription: String {
        return "\(_target)"
    }
}
