extension Character {
    var isParens: Bool {
        switch self {
        case "(", ")": return true
        default: return false
        }
    }

    var isQuotationMark: Bool {
        return self == "\""
    }
}
