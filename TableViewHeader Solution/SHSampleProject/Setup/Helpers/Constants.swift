//
//  Constants.swift
//  ProjectSetup
//
//  Created by Shezad Ahamed on 02/10/19.
//  Copyright © 2019 Shezad Ahamed. All rights reserved.
//

import Foundation
import UIKit

struct DeviceConstants{
    static let deviceWidth = UIScreen.main.bounds.width
    static let deviceHeight = UIScreen.main.bounds.height
    static let is5sOrLess = deviceWidth <= 320 ? true : false
    static let isIphoneX = deviceHeight >= 812 ? true : false
}

class getSafeAreaInsets{
    let top:CGFloat
    let bottom:CGFloat
    init(){
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.windows.first
            top = (window?.safeAreaInsets.top) ?? 0
            bottom = (window?.safeAreaInsets.bottom) ?? 0
        }
        else{
            top = 0
            bottom = 0
        }
    }
}
