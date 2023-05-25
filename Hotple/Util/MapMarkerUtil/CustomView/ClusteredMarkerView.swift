//
//  ClusteredMarkerView.swift
//  Hotple
//
//  Created by SeongHoon Kim on 2023/05/22.
//

import Foundation
import UIKit
import NMapsMap
import SnapKit

class ClusteredMarkerView: UIView {
    
    // 컨테이너 영역 뷰
    private let containerView = UIView()
    
    private let countLbl = UILabel()


    
    // 지역 클러스터링 개수
    var count: Int = 0
    
    init(frame: CGRect, count: Int) {
        super.init(frame: frame)
        Log.debug("ClusteredMarkerView init")
        self.count = count
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
//        containerView.layer.borderColor = UIColor.green.cgColor
        containerView.layer.cornerRadius = bounds.size.height / 2
        containerView.backgroundColor = .clear
        self.addSubview(containerView)
        
        
        
        // 지역 지점 버튼
        self.countLbl.text = ("\(self.count) 개")
        countLbl.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        countLbl.textColor = .black
        containerView.addSubview(countLbl)
        
        
    }
    
    func constraintConfigure() {

        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // 지역 지점 버튼
        countLbl.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    
    
}
