//
//  WidgetCollectionViewCell.swift
//  Goat-Weather
//
//  Created by Yefga on 14/12/23.
//

import Foundation
import UIKit

public extension UIView {
    class func loadFromNib<T>(_ name: String = String(describing: T.self),
                              owner: AnyObject? = nil,
                              options: [AnyHashable: Any]? = nil,
                              bundle: Bundle? = Bundle.main) -> T {
        return UINib(nibName: name,
                     bundle: bundle).instantiate(withOwner: owner,
                                                 options: options).first as! T
    }
}

class WidgetCollectionViewCell: UICollectionViewCell {
    
    var widgets: WidgetModel? {
        didSet {
            if let content = oldValue {
                widget.updateUI(content)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static var reuseIdentifier: String {
        String(describing: self)
    }
    
    private lazy var widget: WidgetView = {
        let vw: WidgetView = .loadFromNib()
        vw.clipsToBounds = true
        vw.layer.cornerRadius = 20
        vw.translatesAutoresizingMaskIntoConstraints = false
        return vw
    }()
    
    private func setupUI() {
        // Add your view configuration code here
        contentView.addSubview(widget)
        applyDropShadow()
    }
    
    func applyDropShadow() {
        widget.layer.cornerRadius = 20
        widget.layer.masksToBounds = false
        
        // Apply a shadow
        widget.layer.shadowRadius = 8.0
        widget.layer.shadowOpacity = 0.10
        widget.layer.shadowColor = UIColor.black.cgColor
        widget.layer.shadowOffset = CGSize(width: 0, height: 5)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowPath = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: 20
        ).cgPath
        if let size = widgets?.size {
            widget.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            widget.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
            var heightConstraint = widget.heightAnchor.constraint(equalToConstant: 170)
            switch size {
            case .iPhoneSmall:
                widget.widthAnchor.constraint(equalToConstant: self.bounds.width / 2).isActive = true
                heightConstraint = widget.heightAnchor.constraint(equalToConstant: self.bounds.width / 2)
                heightConstraint.priority = UILayoutPriority.init(200)
                heightConstraint.isActive = true
            case .iPhoneMedium:
                widget.widthAnchor.constraint(equalToConstant: self.bounds.width).isActive = true
                heightConstraint = widget.heightAnchor.constraint(equalToConstant: self.bounds.width / 2)
                heightConstraint.priority = .init(200)
                heightConstraint.isActive = true
            case .iPhoneLarge:
                widget.widthAnchor.constraint(equalToConstant: self.bounds.width).isActive = true
                heightConstraint = widget.heightAnchor.constraint(equalToConstant: self.bounds.width)
                heightConstraint.priority = .init(200)
                heightConstraint.isActive = true
            }
        }
    }
    
}

extension WidgetCollectionViewCell {
    // MARK: Custom Methods
}
