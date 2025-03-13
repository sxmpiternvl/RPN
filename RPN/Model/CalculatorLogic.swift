import Foundation

enum ExpressionState {
    case empty
    case normal(String)
    case undefined
    case result(String)
}

class CalculatorLogic {
    private(set) var state: ExpressionState = .empty
    var openParenthesisCount: Int = 0
    
    func getExpressionText() -> String {
        switch state {
        case .empty:
            return ButtonTitle.zero.rawValue
        case .normal(let expression):
            return expression
        case .undefined:
            return "Не определено"
        case .result(let result):
            return result
        }
    }
    
    func handleInput(_ button: ButtonTitle) {
        switch button {
        case .zero, .one, .two, .three, .four, .five, .six, .seven, .eight, .nine:
            addDigit(button.rawValue)
        case .decimalSeparator:
            addDecimalPoint()
        case .add:
            addOperator(ButtonTitle.add.rawValue)
        case .subtract:
            addOperator(ButtonTitle.subtract.rawValue)
        case .multiply:
            addOperator(ButtonTitle.multiply.rawValue)
        case .divide:
            addOperator(ButtonTitle.divide.rawValue)
        case .power:
            addOperator(ButtonTitle.power.rawValue)
        case .openParenthesis:
            addOpenParenthesis()
        case .closeParenthesis:
            addCloseParenthesis()
        case .equals:
            evaluateExpression()
        case .allClear:
            reset()
        case .backspace:
            deleteLastInput()
        }
    }
    
    // MARK: - Reset
    func reset() {
        state = .empty
        openParenthesisCount = 0
    }
    
    // MARK: addDigit
    private func addDigit(_ digit: String) {
        switch state {
        case .undefined, .empty, .result(_):
            state = .normal(digit)
        case .normal(let expression):
            if digit == ButtonTitle.zero.rawValue {
                let newExpr = (expression == ButtonTitle.zero.rawValue) ? digit : (expression + digit)
                state = .normal(newExpr)
            }}
    }
    
    // MARK: addDecimal
    private func addDecimalPoint() {
        switch state {
        case .undefined, .empty, .result(_):
            state = .normal(ButtonTitle.zero.rawValue + ButtonTitle.decimalSeparator.rawValue)
        case .normal(let expr):
            if !expr.contains(ButtonTitle.decimalSeparator.rawValue) {
                if let last = expr.last, last == "(" || ((ButtonTitle(rawValue: String(last))?.isOperator) == true) {
                    state = .normal(expr + ButtonTitle.zero.rawValue + ButtonTitle.decimalSeparator.rawValue)
                } else {
                    state = .normal(expr + ButtonTitle.decimalSeparator.rawValue)
                }
            }
        }
    }
    
    // MARK: - Добавление оператора
    private func addOperator(_ op: String) {
        switch state {
        case .undefined:
            state = .normal(ButtonTitle.zero.rawValue + op)
        case .empty:
            state = (op == ButtonTitle.subtract.rawValue) ? .normal(ButtonTitle.subtract.rawValue) : .normal(ButtonTitle.zero.rawValue + op)
        case .result(let val):
            state = .normal(val + op)
        case .normal(var expr):
            guard let last = expr.last else {
                expr += op
                state = .normal(expr)
                return
            }
            if last == Character(ButtonTitle.openParenthesis.rawValue) {
                if op == ButtonTitle.subtract.rawValue {
                    expr += op
                    state = .normal(expr)
                }
                return
            }
            if last.isNumber {
                expr += op
                state = .normal(expr)
                return
            }
            if expr.hasSuffix(ButtonTitle.multiply.rawValue + ButtonTitle.subtract.rawValue) ||
                expr.hasSuffix(ButtonTitle.divide.rawValue + ButtonTitle.subtract.rawValue) {
                if op == ButtonTitle.subtract.rawValue {
                    return
                } else {
                    expr.removeLast(2)
                    expr += op
                    state = .normal(expr)
                    return
                }
            }
            if ((ButtonTitle(rawValue: String(last))?.isOperator) == true) {
                if (last == Character(ButtonTitle.multiply.rawValue) ||
                    last == Character(ButtonTitle.divide.rawValue) ||
                    last == Character(ButtonTitle.power.rawValue))
                    && op == ButtonTitle.subtract.rawValue {
                    expr += op
                    state = .normal(expr)
                    return
                }
                if expr.count >= 2 {
                    let lastTwo = expr.suffix(2)
                    if lastTwo.first == Character(ButtonTitle.openParenthesis.rawValue) &&
                        lastTwo.last == Character(ButtonTitle.subtract.rawValue) &&
                        op != ButtonTitle.subtract.rawValue {
                        expr.removeLast()
                        state = .normal(expr)
                        return
                    }
                }
                expr.removeLast()
                expr += op
                state = .normal(expr)
                return
            }
            expr += op
            state = .normal(expr)
        }
    }
    
    // MARK: openParenthesis
    private func addOpenParenthesis() {
        switch state {
        case .undefined, .empty, .result(_):
            state = .normal(ButtonTitle.openParenthesis.rawValue)
            openParenthesisCount = 1
        case .normal(var expr):
            if let last = expr.last, last.isNumber || last == Character(ButtonTitle.closeParenthesis.rawValue) {
                expr.append(ButtonTitle.multiply.rawValue)
                expr.append(ButtonTitle.openParenthesis.rawValue)
            } else if expr == ButtonTitle.zero.rawValue {
                expr = ButtonTitle.openParenthesis.rawValue
            } else {
                expr.append(ButtonTitle.openParenthesis.rawValue)
            }
            openParenthesisCount += 1
            state = .normal(expr)
        }
    }
    
    // MARK: closeParenthesis
    private func addCloseParenthesis() {
        guard openParenthesisCount > 0 else { return }
        switch state {
        case .undefined, .empty, .result(_):
            return
        case .normal(var expr):
            if let last = expr.last, last == Character(ButtonTitle.openParenthesis.rawValue) || ((ButtonTitle(rawValue: String(last))?.isOperator) == true) {
                return
            }
            expr.append(ButtonTitle.closeParenthesis.rawValue)
            openParenthesisCount -= 1
            state = .normal(expr)
        }
    }
    
    // MARK:  Backspace
    private func deleteLastInput() {
        switch state {
        case .undefined, .empty, .result(_):
            reset()
        case .normal(var expr):
            if expr.count <= 1 {
                openParenthesisCount = 0
                state = .empty
            } else {
                let removed = expr.removeLast()
                if removed == Character(ButtonTitle.openParenthesis.rawValue) {
                    openParenthesisCount = max(openParenthesisCount - 1, 0)
                }
                state = expr.isEmpty ? .empty : .normal(expr)
            }
        }
    }
    
    
    // MARK: - evaluate
    private func evaluateExpression() {
        guard case .normal(let expr) = state else { return }
        guard expr.filter({ $0.isNumber }).count >= 2 else { return }
        
        var expressionToEvaluate = expr
        if let last = expressionToEvaluate.last, ButtonTitle(rawValue: String(last))?.isOperator == true {
            expressionToEvaluate.removeLast()
        }
        if openParenthesisCount > 0 {
            expressionToEvaluate.append(String(repeating: ButtonTitle.closeParenthesis.rawValue, count: openParenthesisCount))
            openParenthesisCount = 0
        }
        print("Infix expression: \(expressionToEvaluate)")
        let replaced = RPNConverter.replace(expressionToEvaluate)
        let rpn = RPNConverter.infixToRPN(replaced)
        let resultVal = RPNEvaluator.evaluate(rpn)
        
        if resultVal.isNaN {
            state = .undefined
        } else {
            state = .result(stringFromRoundedNumber(resultVal, toPlaces: 8))
        }
    }
    
    
}




