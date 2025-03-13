import Foundation

struct RPNConverter {

    static func replace(_ input: String) -> [String] {
        var result = input
        result = result.replacingOccurrences(of: "÷", with: "/")
        result = result.replacingOccurrences(of: "×", with: "*")
    
        var output:[String] = []
        let chars = result.split(separator: "")
        for i in 0..<chars.count {
            let char = chars[i]
            switch char {
            case "-":
                if i == 0 || chars[i - 1] == "(" {
                    output.append("0")
                }
                output.append(String(char))
            default:
                output.append(String(char))
            }
        }
        return output
    }
    
    static func infixToRPN(_ input: [String]) -> [String] {
        var output: [String] = []
        var operatorStack: [String] = []
        var currentNumber = ""
        for char in input {
            func resetCurrentNumber() {
                if !currentNumber.isEmpty {
                    output.append(currentNumber)
                    currentNumber = ""
                }
            }
            switch char {
            case let token where token.first?.isNumber == true || token.first == ".":
                currentNumber.append(token)
            case "(":
                resetCurrentNumber()
                operatorStack.append(char)
            case ")":
                resetCurrentNumber()
                while let last = operatorStack.last, last != "(" {
                    output.append(String(last))
                    operatorStack.removeLast()
                }
                if !operatorStack.isEmpty {
                    operatorStack.removeLast()
                }
            default:
                resetCurrentNumber()
                while let last = operatorStack.last, last != "(", getPriority(char) <= getPriority(last) {
                    output.append(String(last))
                    operatorStack.removeLast()
                }
                operatorStack.append(char)
            }
        
        }
        if !currentNumber.isEmpty {
            output.append(currentNumber)
        }
        while let last = operatorStack.last {
            operatorStack.removeLast()
            if last != "(" {
                output.append(String(last))
            }
        }
        print("RPN expression: \(output)")
        return output
    }
    
    private static func getPriority(_ c: String) -> Int {
        switch c {
        case "+", "-":
            return 1
        case "*", "/":
            return 2
        case "^":
            return 3
        default:
            return 0
        }
    }

}
