import UIKit

extension CALayer {
    func applySketchShadow(color: UIColor = .black, alpha: Float = 0.5, x: CGFloat = 0, y: CGFloat = 2, blur: CGFloat = 4, spread: CGFloat = 0) {   
        removeSketchShadow()
        /*
        shadowColor = color.cgColor
        shadowOpacity = alpha
        shadowOffset = CGSize(width: x, height: y)
        shadowRadius = blur / 2.0
        if spread == 0 {
            shadowPath = nil
        } else {
            let dx = -spread
            let rect = bounds.insetBy(dx: dx, dy: dx)
            shadowPath = UIBezierPath(rect: rect).cgPath
        }
         */
    }
    
    func removeSketchShadow() {
        shadowColor = nil
        shadowOpacity = 0
        shadowOffset = CGSize(width: 0, height: 0)
        shadowRadius = 0
        shadowPath = nil
    }
}
