//
//  ClusteredMarkerView.swift
//  Hotple
//
//  Created by SeongHoon Kim on 2023/05/22.
//

import Foundation
import UIKit
//import SnapKit

class ClusteredMarkerView: UIView {
    
    // 컨테이너 영역 뷰
    private let containerView = UIView()
    
    private let countLbl = UILabel()

    // 지역 클러스터링 개수
    var count: String?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        Log.debug("ClusteredMarkerView init")
        viewConfigure()
        constraintConfigure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        Log.debug("ClusteredMarkerView layoutSubviews")
        constraintConfigure()
    }
    
    private func viewConfigure() {
        
        // 컨테이너 뷰
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.green.cgColor
        containerView.layer.cornerRadius = bounds.size.height / 2
        containerView.backgroundColor = .black
        self.addSubview(containerView)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        // 지역 지점 버튼
        countLbl.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        countLbl.textColor = .white
        containerView.addSubview(countLbl)
        
        countLbl.translatesAutoresizingMaskIntoConstraints = false
        
    }
    
    func constraintConfigure() {
        
        containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        containerView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        countLbl.centerXAnchor.constraint(equalTo: self.containerView.centerXAnchor).isActive = true
        countLbl.centerYAnchor.constraint(equalTo: self.containerView.centerYAnchor).isActive = true
        countLbl.widthAnchor.constraint(equalToConstant: 100).isActive = true
        countLbl.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
//        containerView.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
//        }
//
//        // 지역 지점 버튼
//        countLbl.snp.makeConstraints { make in
//            make.width.height.equalTo(100)
//            make.edges.equalToSuperview()
//        }
    }
    
    func setCount(count: String) {
        DispatchQueue.main.async {
            // 지역명 설정
            self.countLbl.text = count
        }
        
    }
    
}
