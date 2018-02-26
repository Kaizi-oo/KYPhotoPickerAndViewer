//
//  Double+Time.swift
//  KYPhotoPickerAndViewer
//
//  Created by kyang on 2017/12/28.
//  Copyright © 2017年 kyang. All rights reserved.
//

import Foundation

extension Double {
    
    func toTimeScope() -> String {
        
        var seconds: Double = self
        seconds += 1
        var hhmmss: String
        if seconds < 0 {
            return "00:00:00"
        }
        let second = lround(seconds)
        
        let h = Int(second % 86400 / 3600)
        let m = Int(second % 3600 / 60)
        let s = Int(second % 60)
        
        hhmmss = String(format: "%02d:%02d:%02d", h,m,s)
        
        return hhmmss
    }
    
}
