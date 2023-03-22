//
//  ProfileSettingMenuCell.swift
//  Hotple
//
//  Created by SeongHoon Kim on 2023/03/02.
//

import Foundation
import UIKit
import SnapKit
import Then

class ProfileSettingMenuCell: UITableViewCell {
    
    static let reuseIdentifier = "ProfileSettingMenuCell"
    
    private let titleLbl = UILabel().then {
        $0.textColor = .black
        
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        viewConfigure()
        constraintConfigure()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func viewConfigure() {
        self.contentView.addSubview(titleLbl)
    }
    
    private func constraintConfigure() {
        self.titleLbl.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(200)
        }
    }
    
    
    func setData(_ data: ProfileSettingMenuData) {
        titleLbl.text = data.title
    }
    
}
