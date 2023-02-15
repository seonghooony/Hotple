//
//  TestCell.swift
//  Hotple
//
//  Created by SeongHoon Kim on 2023/02/15.
//


import Foundation
import UIKit
import SnapKit

class InteriorAdItemCell: UITableViewCell {
    
    static let reuseIdentifier = "InteriorAdItemCell"
    
    let containerView = UIView()
    
    let imgView = UIImageView()
    
    let footerView = UIView()
    
    let titleLbl = UILabel()

    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        viewConfigure()
        constraintConfigure()
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    

    
    private func viewConfigure() {
        self.backgroundColor = .clear
        
        containerView.isUserInteractionEnabled = true
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 8
        containerView.clipsToBounds = true
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor(red: 222/255, green: 222/255, blue: 222/255, alpha: 1.0).cgColor
        contentView.addSubview(containerView)
        
        imgView.backgroundColor = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1.0)
        imgView.contentMode = .scaleAspectFill
        imgView.clipsToBounds = true
        containerView.addSubview(imgView)
        
        titleLbl.textColor = UIColor(red: 37/255, green: 37/255, blue: 37/255, alpha: 1.0)
        titleLbl.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        titleLbl.textAlignment = .left
        containerView.addSubview(titleLbl)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()

        imgView.image = UIImage()
        titleLbl.text = ""

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layoutIfNeeded()
        
    }
    
    private func constraintConfigure() {
        containerView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview().offset(-10)
        }
        
        imgView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(104)
        }
        
        titleLbl.snp.makeConstraints { make in
            make.top.equalTo(imgView.snp.bottom).offset(7)
            make.leading.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-8)
        }
    }
    
   
}
