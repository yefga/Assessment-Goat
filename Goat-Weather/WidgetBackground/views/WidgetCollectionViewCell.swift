/// Copyright (c) 2023 Yefga.com
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.


import Foundation
import UIKit
import Kingfisher

class WidgetCollectionSmallCell: WidgetCollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        containerView.widthAnchor.constraint(equalToConstant: self.bounds.width / 2).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: self.bounds.width / 2).isActive = true
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class WidgetCollectionMediumCell: WidgetCollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        containerView.widthAnchor.constraint(equalToConstant: self.bounds.width).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: self.bounds.width / 2).isActive = true
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class WidgetCollectionLargeCell: WidgetCollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        containerView.widthAnchor.constraint(equalToConstant: self.bounds.width).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: self.bounds.width).isActive = true
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class WidgetCollectionViewCell: UICollectionViewCell {
    var image: UIImage? = .init(named: "image.example")
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate lazy var containerView: UIView = {
        let bg = UIView()
        bg.translatesAutoresizingMaskIntoConstraints = false
        bg.backgroundColor = .clear
        return bg
    }()
    
    fileprivate lazy var borderView: UIView = {
        let vw = UIView()
        vw.layer.cornerRadius = 20
        vw.layer.borderColor = UIColor.black.cgColor
        vw.layer.borderWidth = 0.1
        vw.layer.masksToBounds = true
        return vw
    }()
    
    fileprivate lazy var backgroundImageView: UIImageView = {
        let bg = UIImageView()
        bg.contentMode = .scaleAspectFill
        return bg
    }()
    
    fileprivate lazy var weatherImageView: UIImageView = {
        let bg = UIImageView()
        bg.translatesAutoresizingMaskIntoConstraints = false
        return bg
    }()
    
    fileprivate lazy var locationLabel: UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.textColor = .white
        lb.font = .systemFont(ofSize: 20, weight: .bold)
        lb.numberOfLines = 2
        return lb
    }()
    
    private lazy var stackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [
            weatherImageView, locationLabel
        ])
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .vertical
        sv.spacing = 8.0
        sv.distribution = .fill
        return sv
    }()
    
    override func layoutSubviews() {
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 5, height: 5)
        containerView.layer.shadowOpacity = 0.7
        containerView.layer.shadowRadius = 10.0

        borderView.frame = containerView.bounds
        backgroundImageView.frame = borderView.bounds
        backgroundImageView.image = image == nil ? .init(named: "image.example") : image
        
        let heightConstraint = weatherImageView.heightAnchor.constraint(equalToConstant: containerView.frame.height / 2)
        heightConstraint.priority = .init(999)
        heightConstraint.isActive = true

    }
    
    private func setupUI() {
        // Add your view configuration code here
        contentView.addSubview(containerView)
        containerView.addSubview(borderView)
        borderView.addSubview(backgroundImageView)
        containerView.addSubview(weatherImageView)
        containerView.addSubview(locationLabel)
        containerView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }

    func setLayout() {
        weatherImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16).isActive = true
        weatherImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16).isActive = true
        weatherImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16).isActive = true
        locationLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16).isActive = true
        locationLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16).isActive = true
        locationLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16).isActive = true

    }
    
    func updateData(_ size: WidgetSize, 
                    location: String,
                    weatherIcon: String) {
        switch size {
        case .iPhoneMedium:
            weatherImageView.contentMode = .left
        default:
            weatherImageView.contentMode = .scaleAspectFit
        }
        
        self.weatherImageView.kf.setImage(with: URL(string: weatherIcon),
                                          placeholder: nil)
        
        
        let shadow = NSShadow()
        shadow.shadowColor = UIColor.black
        shadow.shadowBlurRadius = 10
        
        locationLabel.attributedText = NSAttributedString(
            string: location,
            attributes: [
                NSAttributedStringKey.font: UIFont.systemFont(
                    ofSize: size.rawValue,
                    weight: .bold
                ),
                NSAttributedStringKey.foregroundColor: UIColor.white,
                NSAttributedStringKey.shadow: shadow
            ])
    }
    
}

extension UICollectionViewCell {
    static var reuseIdentifier: String {
        String(describing: self)
    }
}
