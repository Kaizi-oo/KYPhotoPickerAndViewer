//
//  KYImageViewBar.swift
//  KYImageViewer
//
//  Created by kyang on 2017/9/18.
//  Copyright © 2017年 kyang. All rights reserved.
//

import Foundation
import UIKit


//MARK: - KYImageViewBar -

public class KYImageViewBar : UIView {
    
    var saveButtonTapBlock : (() ->())!
    var closeButtonTapBlock : (() ->())!
    
    lazy var closeButton : UIButton = {
        let button = UIButton(frame: CGRect(x: KYImageViewBarDefaultMargin, y: (self.frame.height-KYImageViewBarButtonWidth)/2, width: KYImageViewBarButtonWidth, height: KYImageViewBarButtonWidth))
        button.backgroundColor = UIColor.clear
        button.contentMode = UIViewContentMode.scaleAspectFill
        button.addTarget(self, action: #selector(KYImageViewBar.onCloseButtonTapped), for: UIControlEvents.touchUpInside)
        return button
    }()
    
    
    lazy var saveButton : UIButton = {
        let button = UIButton(frame: CGRect(x: self.frame.width-KYImageViewBarButtonWidth-KYImageViewBarDefaultMargin, y: (self.frame.height-KYImageViewBarButtonWidth)/2, width: KYImageViewBarButtonWidth, height: KYImageViewBarButtonWidth))
        button.backgroundColor = UIColor.clear
        button.contentMode = UIViewContentMode.scaleAspectFill
        button.addTarget(self, action: #selector(KYImageViewBar.onSaveButtonTapped), for: UIControlEvents.touchUpInside)
        return button
    }()
    
    lazy var countLabel : UILabel = {
        let label = UILabel(frame: CGRect(x: KYImageViewBarButtonWidth+KYImageViewBarDefaultMargin*2, y: 0, width: self.frame.width-(KYImageViewBarButtonWidth+KYImageViewBarDefaultMargin*2)*2, height: self.frame.height))
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 13)
        label.textAlignment = NSTextAlignment.center
        label.text = "-/-"
        return label
    }()
    
    //MARK: - convenience init
    
    public convenience init(frame: CGRect , saveTapBlock: @escaping ()->() , closeTapBlock: @escaping ()->()) {
        self.init(frame: frame)
        self.backgroundColor = KYImageViewBarBackgroundColor
        
        saveButtonTapBlock = saveTapBlock
        closeButtonTapBlock = closeTapBlock
        
        var imageBundle : Bundle = Bundle.main
        
        if let bundleURL : String = Bundle(for: KYImageViewer.classForCoder()).path(forResource: "KYImageViewer", ofType: "bundle") {
            if let bundle : Bundle = Bundle(path: bundleURL){
                imageBundle = bundle;
            }
        }
        closeButton.setImage(UIImage(named: "close", in: imageBundle, compatibleWith: nil), for: UIControlState())
        self.addSubview(closeButton)
        
        saveButton.setImage(UIImage(named: "save", in: imageBundle, compatibleWith: nil), for: UIControlState())
        self.addSubview(saveButton)
        
        self.addSubview(countLabel)
    }
    
    public override func layoutIfNeeded() {
        super.layoutIfNeeded()
        
        self.closeButton.frame = CGRect(x: KYImageViewBarDefaultMargin, y: (self.frame.height-KYImageViewBarButtonWidth)/2, width: KYImageViewBarButtonWidth, height: KYImageViewBarButtonWidth)
        self.saveButton.frame = CGRect(x: self.frame.width-KYImageViewBarButtonWidth-KYImageViewBarDefaultMargin, y: (self.frame.height-KYImageViewBarButtonWidth)/2, width: KYImageViewBarButtonWidth, height: KYImageViewBarButtonWidth)
        self.countLabel.frame = CGRect(x: KYImageViewBarButtonWidth+KYImageViewBarDefaultMargin*2, y: 0, width: self.frame.width-(KYImageViewBarButtonWidth+KYImageViewBarDefaultMargin*2)*2, height: self.frame.height)
    }
    
    //MARK: - onCloseButtonTapped
    
    @objc func onCloseButtonTapped(){
        self.closeButtonTapBlock();
    }
    
    //MARK: - onSaveButtonTapped
    
    @objc func onSaveButtonTapped(){
        self.saveButtonTapBlock();
    }
}
