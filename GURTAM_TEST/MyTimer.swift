//
//  MyTimer.swift
//  GURTAM_TEST
//
//  Created by Yra on 15.10.2018.
//  Copyright © 2018 Yuriy Kudreika. All rights reserved.
//

import Foundation
import CoreFoundation

class MyTimer {
    
    let startTime: CFAbsoluteTime
    var endTime: CFAbsoluteTime?
    
    init() {
        startTime = CFAbsoluteTimeGetCurrent()
    }
    
    func stop() -> CFAbsoluteTime {
        endTime = CFAbsoluteTimeGetCurrent()
        return duration!
    }
    
    var duration: CFAbsoluteTime? {
        if let endTime = endTime {
            return endTime - startTime
        } else {
            return nil
        }
    }
}
