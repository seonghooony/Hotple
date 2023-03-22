//
//  ProfileSettingDataSource.swift
//  Hotple
//
//  Created by SeongHoon Kim on 2023/03/02.
//

import Foundation
import RxDataSources

struct ProfileSettingSection {
    typealias Model = SectionModel<SectionType, ItemType>
    
    
    enum SectionType: Equatable {
        case normal
    }
    
    enum ItemType: Equatable {
        case info(ProfileSettingMenuData)
    }
    
}
