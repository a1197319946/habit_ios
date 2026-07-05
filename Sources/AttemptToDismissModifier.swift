import SwiftUI

struct AttemptToDismissModifier: ViewModifier {
    let action: () -> Void
    func body(content: Content) -> some View {
        content.background(AttemptToDismissView(action: action))
    }
}

extension View {
    func onAttemptToDismiss(perform action: @escaping () -> Void) -> some View {
        self.modifier(AttemptToDismissModifier(action: action))
    }
}

struct AttemptToDismissView: UIViewControllerRepresentable {
    let action: () -> Void
    
    func makeUIViewController(context: Context) -> UIViewController {
        let vc = ViewController(action: action)
        vc.view.backgroundColor = .clear
        return vc
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    
    class ViewController: UIViewController, UIAdaptivePresentationControllerDelegate {
        let action: () -> Void
        
        init(action: @escaping () -> Void) {
            self.action = action
            super.init(nibName: nil, bundle: nil)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func didMove(toParent parent: UIViewController?) {
            super.didMove(toParent: parent)
            if let parent = parent {
                parent.presentationController?.delegate = self
            }
        }
        
        func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
            action()
        }
    }
}
