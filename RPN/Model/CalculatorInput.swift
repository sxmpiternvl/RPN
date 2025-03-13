enum ButtonTitle: String, CaseIterable {
    case zero = "0"
    case one = "1"
    case two = "2"
    case three = "3"
    case four = "4"
    case five = "5"
    case six = "6"
    case seven = "7"
    case eight = "8"
    case nine = "9"
    case openParenthesis = "("
    case closeParenthesis = ")"
    case divide = "÷"
    case multiply = "×"
    case subtract = "-"
    case add = "+"
    case allClear = "AC"
    case backspace = "⌫"
    case decimalSeparator = "."
    case equals = "="
    case power = "^"
    
    var isOperator: Bool {
        switch self {
        case .add, .subtract, .multiply, .divide, .power:
            return true
        default:
            return false
        }
    }
}


