//
//  Storyboards.swift
//  ProjectSetup
//
//  Created by Shezad Ahamed on 02/10/19.
//  Copyright © 2019 Shezad Ahamed. All rights reserved.
//

import UIKit


class Storyboards{
    
    static let shared = Storyboards()
    let mainStoryboard : UIStoryboard

    init(){
        mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
    }
    
}
