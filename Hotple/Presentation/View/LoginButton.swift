//
//  LoginButton.swift
//  Hotple
//
//  Created by SeongHoon Kim on 2023/02/01.
//

import Foundation
import UIKit

class LoginButton: UIButton {
    private let stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.alignment = .center
        view.distribution = .fill
        view.spacing = 12
        view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let btnImageView: UIImageView = {
        let view = UIImageView()
        view.isUserInteractionEnabled = false
        
        return view
    }()
    
    private let btnLabel: UILabel = {
        let label = UILabel()
        label.text = "title"
        label.textColor = UIColor(red: 19/255, green: 19/255, blue: 19/255, alpha: 1.0)
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
        
    }()
    
    var text: String? {
        didSet {
            btnLabel.text = text
        }
    }
    
    var normalImage: UIImage? {
        didSet {
            self.updateStateUI()
        }
    }
    
    var highlightedImage: UIImage? {
        didSet {
            self.updateStateUI()
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            self.updateStateUI()
        }
    }
    
    var backColor: UIColor = UIColor.black
    
    var imageSize: CGFloat = 22.5
    
    private func updateStateUI() {
        switch state {
        case .normal:
            btnLabel.alpha = 1
            btnImageView.image = normalImage
            self.backgroundColor = backColor.withAlphaComponent(1.0)
            
        case .highlighted:
            btnLabel.alpha = 0.5
            btnImageView.image = highlightedImage
            self.backgroundColor = backColor.withAlphaComponent(0.5)
            
        default:
            break
        }
    }
    
    init() {
        super.init(frame: .zero)
        viewConfigure()
        constraintConfigure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func viewConfigure() {
        
        self.addSubview(self.stackView)
        
        [btnImageView, btnLabel].forEach(self.stackView.addArrangedSubview(_:))
        
        
        
    }
    
    private func constraintConfigure() {
        self.stackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            
        }
        
        self.btnImageView.snp.makeConstraints { make in
            make.width.height.equalTo(imageSize)
        }
        
    }
    
    func setBackgroundColor(color: UIColor) {
        self.backgroundColor = color
        self.backColor = color
    }
    
    func setSpacing(size: CGFloat) {
        stackView.spacing = size
    }
    
    func setImageSize(ptSize: CGFloat) {
        self.imageSize = ptSize
        self.btnImageView.snp.remakeConstraints { make in
            make.width.height.equalTo(imageSize)
        }
    }
    
    override func setImage(_ image: UIImage?, for state: UIControl.State) {
        switch state {
        case .normal:
            normalImage = image
        case .highlighted:
            highlightedImage = image
            
        default:
            break
        }
    }
    
    override func setTitle(_ title: String?, for state: UIControl.State) {
        btnLabel.text = title
    }
}
