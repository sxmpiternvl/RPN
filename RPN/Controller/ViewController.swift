import UIKit

class ViewController: UIViewController {
    
    let calculatorView = CalculatorView()
    let logic = CalculatorLogic()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupCalculatorView()
        setupButtonActions()
        updateDisplay()
    }
    
    private func setupCalculatorView() {
        view.addSubview(calculatorView)
        calculatorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            calculatorView.topAnchor.constraint(equalTo: view.topAnchor),
            calculatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            calculatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            calculatorView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupButtonActions() {
        for row in calculatorView.buttonsContainer.arrangedSubviews {
            if let rowStack = row as? UIStackView {
                for buttonView in rowStack.arrangedSubviews {
                    if let button = buttonView as? UIButton {
                        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
                    }
                }
            }
        }
    }
    
    @objc func buttonTapped(_ sender: UIButton) {
        guard let title = sender.currentTitle,
              let button = Button(rawValue: title) else { return }
        handleButton(button)
        updateDisplay()
    }

    private func handleButton(_ button: Button) {
        switch button {
        case .allClear:
            logic.handleInput(.allClear)
        case .backspace:
            logic.handleInput(.backspace)
        case .openParenthesis:
            logic.handleInput(.openParenthesis)
        case .closeParenthesis:
            logic.handleInput(.closeParenthesis)
        case .divide:
            logic.handleInput(.divide)
        case .multiply:
            logic.handleInput(.multiply)
        case .subtract:
            logic.handleInput(.subtract)
        case .add:
            logic.handleInput(.add)
        case .decimalSeparator:
            logic.handleInput(.decimalSeparator)
        case .equals:
            logic.handleInput(.equals)
        case .zero, .one, .two, .three, .four, .five, .six, .seven, .eight, .nine:
            logic.handleInput(button)
        case .power:
            logic.handleInput(.power)
        }
    }

        private func updateDisplay() {
        let expression = logic.getExpressionText()
        let fontSize: CGFloat = (expression == "Не определено") ? 46 : 58
        let font = UIFont.systemFont(ofSize: fontSize, weight: .medium)
        
        let mainAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .font: font
        ]
        let attributedText = NSMutableAttributedString(string: expression, attributes: mainAttributes)
        
        if logic.openParenthesisCount > 0 {
            let lightText = String(repeating: ")", count: logic.openParenthesisCount)
            let lightAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.lightGray,
                .font: font
            ]
            let lightAttributedText = NSAttributedString(string: lightText, attributes: lightAttributes)
            attributedText.append(lightAttributedText)
        }
        
        calculatorView.displayLabel.attributedText = attributedText
        updateClearButtonTitle()
        view.layoutIfNeeded()
        let maxOffsetX = max(0, calculatorView.displayScrollView.contentSize.width - calculatorView.displayScrollView.bounds.width)
        calculatorView.displayScrollView.setContentOffset(CGPoint(x: maxOffsetX, y: 0), animated: false)
    }
    
    
    private func updateClearButtonTitle() {
        switch logic.state {
        case .undefined, .empty, .result(_):
            calculatorView.dynamicClearButton?.setTitle("AC", for: .normal)
        case .normal(_):
            calculatorView.dynamicClearButton?.setTitle("⌫", for: .normal)
        }
    }
}
