//
//  LeafMarkerView.swift
//  Hotple
//
//  Created by SeongHoon Kim on 2023/05/25.
//


import Foundation
import UIKit
import NMapsMap
import SnapKit

class LeafMarkerView: UIView {
    
    // 컨테이너 영역 뷰
    private let containerView = UIView()
    
    private let markerImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        Log.debug("LeafMarkerView init")
        
        viewConfigure()
        constraintConfigure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        Log.debug("LeafMarkerView layoutSubviews")
        constraintConfigure()
    }
    
    private func viewConfigure() {

        // 컨테이너 뷰
        containerView.backgroundColor = .clear
        self.addSubview(containerView)
        
        markerImageView.image = UIImage(systemName: "pencil.circle.fill")
        containerView.addSubview(markerImageView)
        
        
        
    }
    
    func constraintConfigure() {

        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // 지역 지점 버튼
        markerImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    
    
}
