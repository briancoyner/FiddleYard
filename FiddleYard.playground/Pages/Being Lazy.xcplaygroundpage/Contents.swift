/*:
 [Home](Welcome) • [Previous page](@previous) • [Next page](@next)
 
 ---
 ## Being Lazy
 
 A lazy stored property is a property whose initial value is not set until the first time it is accessed.
 
 There are several reasons to choose a lazy stored property. Here's a few:
 - delay creation of expensive resources
 - resource requires access to `self` during initialization
 - makes it "easier" to set up data structures requiring two-step initialization (i.e. most `UIView` subclasses).
 
 - Important: lazy stored properties are not `let` properties. Therefore, it's possible to change a lazy stored property's value.
 However, 99.9% of the time the lazy stored property is/ should be effectively immutable (i.e. promise not to change it)
 
 Lazy stored properties, in general, should follow this structure:
 
 ```
 fileprivate lazy var someThing = self.lazySomeThing()
 ```
 
 Let's break it apart:
 - `fileprivate` so it's only visible within the class/struct and source file
 - The property is set by a function shoved near the end of the source file in a `fileprivate` extension (when possible)
 - the function body is typically not considered "important" code, so it goes towards the end of the file
 - The property function name follows this pattern (exceptions are possible, when needed)
 - `self.lazyNameOfVariable`
 
 ```
 fileprivate lazy var okButton = self.lazyOkButton()
 fileprivate lazy var cancelButton = self.lazyCancelButton()
 fileprivate lazy var recordActionView = self.lazyRecordActionView()
 ```
 
 ### Other Notes
 
 Check out Apple's [Swift Language Guide](https://developer.apple.com/library/content/documentation/Swift/Conceptual/Swift_Programming_Language/Properties.html) for additional details.
 
 ---
 
 ### Example View Controller
 */
import Foundation
import UIKit
import PlaygroundSupport

final class SomeViewController: UIViewController {
    
    /// Yes. `fileprivate`: private to the view controller and source file
    /// Yes. The property is set by a function shoved near the end of the source file.
    /// Yes. the property function name follows the project naming convention for lazy property functions.
    fileprivate lazy var yesButton = self.lazyYesButton()
    fileprivate lazy var maybeButton = self.lazyMaybeButton()
    
    /// No. Don't inline the function here with lots of boring code. Instead, shove the function body near the end of the file.
    fileprivate lazy var noButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.setTitle("No", for: .normal)
        return button
    }()
}

extension SomeViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("view did load")
        
        view.backgroundColor = .white
        
        let buttonStackView = makeButtonStackView(withButtons: [
            yesButton,
            noButton,
            maybeButton
        ])
        
        view.addSubview(buttonStackView)
        
        let layoutGuide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            buttonStackView.centerXAnchor.constraint(equalTo: layoutGuide.centerXAnchor),
            buttonStackView.centerYAnchor.constraint(equalTo: layoutGuide.centerYAnchor)
        ])
    }
}

extension SomeViewController {
    
    fileprivate func lazyYesButton() -> UIButton {
        print("creating lazy 'yes' button")
        return makeButton(withTitle: "Yes")
    }
    
    fileprivate func lazyMaybeButton() -> UIButton {
        print("creating lazy 'maybe' button")
        return makeButton(withTitle: "Maybe")
    }
    
    fileprivate func makeButton(withTitle title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.setTitle(title, for: .normal)
        
        return button
    }
}

extension SomeViewController {
    
    fileprivate func makeButtonStackView(withButtons buttons: [UIView]) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: buttons)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = UIStackView.spacingUseSystem
        
        return stackView
    }
}

let viewController = SomeViewController()
PlaygroundPage.current.liveView = viewController.view
