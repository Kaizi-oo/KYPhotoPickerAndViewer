//
//  KYMutiPickerHeader.swift
//  YanXunSwift
//
//  Created by 杨凯 on 2017/4/25.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import Foundation
import UIKit

let KYImageViewerAnimationDuriation : TimeInterval =  0.3
let KYImageViewerBackgroundColor =  UIColor.black
let KYImageViewBarBackgroundColor =  UIColor.black.withAlphaComponent(0.3)
let KYImageViewBarHeight : CGFloat =  40.0
let KYImageViewBarButtonWidth : CGFloat =  30.0
let KYImageViewBarDefaultMargin : CGFloat =  5.0
let KYImageGridViewImageMargin : CGFloat = 2.0
let KCOLOR_BACKGROUND_WHITE = UIColor(red:241/255.0, green:241/255.0, blue:241/255.0, alpha:1.0)
var KYImageViewerScreenWidth : CGFloat { return UIScreen.main.bounds.width }
var KYImageViewerScreenHeight : CGFloat { return UIScreen.main.bounds.height }


class KYMutiPickerHeader: NSObject {
    
    // 获取 main bundle 路径
    func bundleImage(_ name: String) -> UIImage {
    
        let mainPath = Bundle.main.resourcePath! + "/KYMutiPhotoPicker.bundle"
        
        let sourceBudle = Bundle(path: mainPath)
        
        let imagePath = sourceBudle?.path(forResource: name+"@3x", ofType: "png")
        
        return UIImage(contentsOfFile: imagePath!)!
    }
}

/** @abstract UIWindow hierarchy category.  */
extension UIWindow {
    
    /** @return Returns the current Top Most ViewController in hierarchy.   */
    public func ky_topMostController()->UIViewController? {
        
        var topController = rootViewController
        
        while let presentedController = topController?.presentedViewController {
            topController = presentedController
        }
        
        return topController
    }
    
    /** @return Returns the topViewController in stack of topMostController.    */
    public func ky_currentViewController()->UIViewController? {
        
        var currentViewController = ky_topMostController()
        
        while currentViewController != nil && currentViewController is UINavigationController && (currentViewController as! UINavigationController).topViewController != nil {
            currentViewController = (currentViewController as! UINavigationController).topViewController
        }
        
        return currentViewController
    }
}
