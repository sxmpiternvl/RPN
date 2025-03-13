import UIKit

class CalculatorView: UIView {
    let mainStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    let displayScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .black
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceHorizontal = true
        return scrollView
    }()
    let displayContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    let displayLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .right
        label.lineBreakMode = .byClipping
        label.numberOfLines = 1
        label.backgroundColor = .black
        label.text = "0"
        return label
    }()
    let buttonsContainer: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.backgroundColor = .black
        return stack
    }()
    let buttonTitles: [[String]] = [
        ["AC", "(", ")", "÷"],
        ["7", "8", "9", "×"],
        ["4", "5", "6", "-"],
        ["1", "2", "3", "+"],
        ["^", "0", ".", "="]
    ]
    
    var dynamicClearButton: UIButton?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
        setupButtons()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setupViews() {
        addSubview(mainStack)
        mainStack.addArrangedSubview(displayScrollView)
        mainStack.addArrangedSubview(buttonsContainer)
        displayScrollView.addSubview(displayContainer)
        displayContainer.addSubview(displayLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 16),
            mainStack.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            mainStack.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])

        let displayHeightConstraint = displayScrollView.heightAnchor.constraint(equalTo: mainStack.heightAnchor, multiplier: 0.45)
        displayHeightConstraint.isActive = true

        NSLayoutConstraint.activate([
            displayContainer.topAnchor.constraint(equalTo: displayScrollView.contentLayoutGuide.topAnchor),
            displayContainer.bottomAnchor.constraint(equalTo: displayScrollView.contentLayoutGuide.bottomAnchor),
            displayContainer.leadingAnchor.constraint(equalTo: displayScrollView.contentLayoutGuide.leadingAnchor),
            displayContainer.trailingAnchor.constraint(equalTo: displayScrollView.contentLayoutGuide.trailingAnchor),
            displayContainer.heightAnchor.constraint(equalTo: displayScrollView.frameLayoutGuide.heightAnchor),
            displayContainer.widthAnchor.constraint(greaterThanOrEqualTo: displayScrollView.frameLayoutGuide.widthAnchor)
        ])
        NSLayoutConstraint.activate([
            displayLabel.bottomAnchor.constraint(equalTo: displayContainer.bottomAnchor, constant: -16),
            displayLabel.leadingAnchor.constraint(equalTo: displayContainer.leadingAnchor, constant: 16),
            displayLabel.trailingAnchor.constraint(equalTo: displayContainer.trailingAnchor, constant: -16)
        ])
    }

    
    private func setupButtons() {
        for row in buttonTitles {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = 10
            rowStack.alignment = .fill
            rowStack.distribution = .fillEqually
            for title in row {
                let button = UIButton(type: .system)
                button.setTitle(title, for: .normal)
                button.titleLabel?.font = UIFont.systemFont(ofSize: 28, weight: .bold)
                button.layer.cornerRadius = 30
                if ["+", "-", "×", "÷", "="].contains(title) {
                    button.backgroundColor = .systemPink
                } else if ["(", ")", "AC", "⌫"].contains(title) {
                    button.backgroundColor = .darkGray
                } else {
                    button.backgroundColor = .gray
                }
                button.setTitleColor(.orange, for: .normal)
                
                if (title == "AC" || title == "⌫") && dynamicClearButton == nil {
                    dynamicClearButton = button
                }
                rowStack.addArrangedSubview(button)
            }
            buttonsContainer.addArrangedSubview(rowStack)
        }
    }
}
