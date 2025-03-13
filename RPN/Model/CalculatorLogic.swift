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
            return Button.zero.rawValue
        case .normal(let expression):
            return expression
        case .undefined:
            return "Не определено"
        case .result(let result):
            return result
        }
    }
    
    func handleInput(_ button: Button) {
        switch button {
        case .zero, .one, .two, .three, .four, .five, .six, .seven, .eight, .nine:
            addDigit(button.rawValue)
        case .decimalSeparator:
            addDecimalPoint()
        case .add:
            addOperator(Button.add.rawValue)
        case .subtract:
            addOperator(Button.subtract.rawValue)
        case .multiply:
            addOperator(Button.multiply.rawValue)
        case .divide:
            addOperator(Button.divide.rawValue)
        case .power:
            addOperator(Button.power.rawValue)
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
            if digit == Button.zero.rawValue {
                if let last = expression.last, last == "0" {
                    return
                }
            }
            let newExpr = (expression == Button.zero.rawValue) ? digit : (expression + digit)
            state = .normal(newExpr)
        }
    }
    
    // MARK: addDecimal
    private func addDecimalPoint() {
        switch state {
        case .undefined, .empty, .result(_):
            state = .normal(Button.zero.rawValue + Button.decimalSeparator.rawValue)
        case .normal(let expr):
            if !currentNumberContainsDecimal(expr) {
                if let last = expr.last, last == "(" || ((Button(rawValue: String(last))?.isOperator) != nil) {
                    state = .normal(expr + Button.zero.rawValue + Button.decimalSeparator.rawValue)
                } else {
                    state = .normal(expr + Button.decimalSeparator.rawValue)
                }
            }
        }
    }
    
    // MARK: - Добавление оператора
    private func addOperator(_ op: String) {
        switch state {
        case .undefined:
            state = .normal(Button.zero.rawValue + op)
        case .empty:
            state = (op == Button.subtract.rawValue) ? .normal(Button.subtract.rawValue) : .normal(Button.zero.rawValue + op)
        case .result(let val):
            state = .normal(val + op)
        case .normal(var expr):
            guard let last = expr.last else {
                expr += op
                state = .normal(expr)
                return
            }
            if last == Character(Button.openParenthesis.rawValue) {
                if op == Button.subtract.rawValue {
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
            if expr.hasSuffix(Button.multiply.rawValue + Button.subtract.rawValue) ||
               expr.hasSuffix(Button.divide.rawValue + Button.subtract.rawValue) {
                if op == Button.subtract.rawValue {
                    return
                } else {
                    expr.removeLast(2)
                    expr += op
                    state = .normal(expr)
                    return
                }
            }
            if ((Button(rawValue: String(last))?.isOperator) != nil) {
                if (last == Character(Button.multiply.rawValue) ||
                    last == Character(Button.divide.rawValue) ||
                    last == Character(Button.power.rawValue))
                    && op == Button.subtract.rawValue {
                    expr += op
                    state = .normal(expr)
                    return
                }
                if expr.count >= 2 {
                    let lastTwo = expr.suffix(2)
                    if lastTwo.first == Character(Button.openParenthesis.rawValue) &&
                        lastTwo.last == Character(Button.subtract.rawValue) &&
                        op != Button.subtract.rawValue {
                        expr.removeLast()
                        state = .normal(expr)
                        return
                    }
                }
                expr = String(expr.dropLast())
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
            state = .normal(Button.openParenthesis.rawValue)
            openParenthesisCount = 1
        case .normal(var expr):
            if let last = expr.last, last.isNumber || last == Character(Button.closeParenthesis.rawValue) {
                expr.append(Button.multiply.rawValue)
                expr.append(Button.openParenthesis.rawValue)
            } else if expr == Button.zero.rawValue {
                expr = Button.openParenthesis.rawValue
            } else {
                expr.append(Button.openParenthesis.rawValue)
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
            if let last = expr.last, last == Character(Button.openParenthesis.rawValue) || ((Button(rawValue: String(last))?.isOperator) != nil) {
                return
            }
            expr.append(Button.closeParenthesis.rawValue)
            openParenthesisCount -= 1
            state = .normal(expr)
        }
    }
    
    // MARK: - evaluate
    private func evaluateExpression() {
        guard case .normal(let expr) = state else { return }
        guard expr.filter({ $0.isNumber }).count >= 2 else { return }
        
        var expressionToEvaluate = expr
        if let last = expressionToEvaluate.last, ((Button(rawValue: String(last))?.isOperator) != nil) {
            expressionToEvaluate.removeLast()
        }
        if openParenthesisCount > 0 {
            expressionToEvaluate.append(String(repeating: Button.closeParenthesis.rawValue, count: openParenthesisCount))
            openParenthesisCount = 0
        }
        print("Infix expression: \(expressionToEvaluate)")
                let normalized = RPNConverter.normalize(expressionToEvaluate)
                let rpn = RPNConverter.infixToRPN(normalized)
//                let resultVal = RPNEvaluator.evaluate(rpn)
                
//                if resultVal.isNaN {
//                    state = .undefined
//                } else {
//                    state = .result(stringFromRoundedNumber(resultVal, toPlaces: 8))
//                }
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
                if removed == Character(Button.openParenthesis.rawValue) {
                    openParenthesisCount = max(openParenthesisCount - 1, 0)
                }
                state = expr.isEmpty ? .empty : .normal(expr)
            }
        }
    }
    
    // MARK: decimal
    private func currentNumberContainsDecimal(_ expression: String) -> Bool {
        var currentNumber = ""
        for char in expression.reversed() {
            if ((Button(rawValue: String(char))?.isOperator) != nil) {
                break
            }
            currentNumber = String(char) + currentNumber
        }
        return currentNumber.contains(Button.decimalSeparator.rawValue)
    }
}



