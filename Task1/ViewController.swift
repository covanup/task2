import UIKit

final class ViewController: UIViewController {
    lazy var stackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [
                Button(title: "First Button"),
                Button(title: "Second Medium Button"),
                Button(title: "Third", action: { [weak self] in self?.presentController() }),
            ]
        )
        stackView.axis = .vertical
        stackView.distribution = .equalCentering
        stackView.alignment = .center
        stackView.spacing = 8.0
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate(
            [
                stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            ]
        )
    }
    
    func presentController() {
        let vc = UIViewController()
        vc.view.backgroundColor = .white
        show(vc, sender: self)
    }
}

private final class Button: UIButton {
    private var action: (() -> ())?
    private var currentAnimator: UIViewPropertyAnimator?
    
    init(title: String, action: @escaping () -> () = {}) {
        super.init(frame: .zero)
        
        configuration = .rounded(title: title)
        self.action = action
        addTarget(self, action: #selector(buttonTouchDown), for: .touchDown)
        addTarget(self, action: #selector(buttonTouchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func buttonTouchDown(_ sender: UIButton) {
        animate(button: sender, touched: true)
    }
    
    @objc func buttonTouchUp(_ sender: UIButton) {
        animate(button: sender, touched: false)
    }
    
    @objc func buttonPressed(_ sender: UIButton) {
        action?()
    }
    
    private func animate(button: UIButton, touched: Bool) {
        let scale = 0.9
        let duration = 0.2
        
        if let animator = currentAnimator, animator.isRunning {
            animator.stopAnimation(true)
        }
        
        let newScale: CGFloat = touched ? scale : 1.0
        let animator = UIViewPropertyAnimator(duration: duration, curve: .easeInOut) {
            button.transform = CGAffineTransform(scaleX: newScale, y: newScale)
        }
        animator.startAnimation()
        currentAnimator = animator
    }
    
    override var isHighlighted: Bool {
        get { return false }
        set { }
    }
}

private extension UIButton.Configuration {
    static func rounded(title: String) -> Self {
        var configuration = UIButton.Configuration.filled()
        
        configuration.title = title
        configuration.image = UIImage(systemName: "arrow.right.circle.fill")
        configuration.baseBackgroundColor = .systemBlue
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 14, bottom: 10, trailing: 14)
        configuration.imagePlacement = .trailing
        configuration.imagePadding = 8
        
        return configuration
    }
}
