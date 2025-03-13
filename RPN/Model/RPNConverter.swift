import Foundation

struct RPNConverter {

    static func normalize(_ input: String) -> String {
        var result = input
        result = result.replacingOccurrences(of: "÷", with: "/")
        result = result.replacingOccurrences(of: "×", with: "*")
    
        var output = ""
        let chars = Array(result)
        for i in 0..<chars.count {
            let char = chars[i]
            switch char {
            case "-":
                if i == 0 || chars[i - 1] == "(" {
                    output.append("0")
                }
                output.append(char)
            default:
                output.append(char)
            }
        }
        return output
    }
    
    static func infixToRPN(_ input: String) -> String {
        var output = ""
        var operatorStack: [Character] = []
        var currentNumber = ""
        for char in input {
            func resetCurrentNumber() {
                if !currentNumber.isEmpty {
                    output.append(currentNumber)
                    output.append(" ")
                    currentNumber = ""
                }
            }
            switch char {
            case let x where x.isNumber || x == ".":
                currentNumber.append(char)
            case "(":
                resetCurrentNumber()
                operatorStack.append(char)
            case ")":
                resetCurrentNumber()
                while let last = operatorStack.last, last != "(" {
                    output.append(last)
                    output.append(" ")
                    operatorStack.removeLast()
                }
                if !operatorStack.isEmpty {
                    operatorStack.removeLast()
                }
            default:
                resetCurrentNumber()
                while let last = operatorStack.last, last != "(", getPriority(char) <= getPriority(last) {
                    output.append(last)
                    output.append(" ")
                    operatorStack.removeLast()
                }
                operatorStack.append(char)
            }
        
        }
        if !currentNumber.isEmpty {
            output.append(currentNumber)
            output.append(" ")
        }
        while let last = operatorStack.last {
            operatorStack.removeLast()
            if last != "(" {
                output.append(last)
                output.append(" ")
            }
        }
        print("RPN expression: \(output)")
        return output
    }
    
    private static func getPriority(_ c: Character) -> Int {
        switch c {
        case Character(Button.add.rawValue), Character(Button.subtract.rawValue):
            return 1
        case Character(Button.multiply.rawValue),Character(Button.divide.rawValue):
            return 2
        case Character(Button.power.rawValue):
            return 3
        default:
            return 0
        }
    }

}
