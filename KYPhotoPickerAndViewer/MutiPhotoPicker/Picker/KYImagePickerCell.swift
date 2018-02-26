//
//  KYImagePickerCell.swift
//  MutiPhotoPicker
//
//  Created by Kyang on 2017/4/23.
//  Copyright © 2017年 Kyang. All rights reserved.
//

import UIKit
import Photos

typealias KYImageSelecthandler = (Bool)->Bool


class KYImagePickerCell: UICollectionViewCell {
    
    @IBOutlet weak var timeLabel: UILabel!
    
    override var isSelected: Bool {
        
        didSet{
            //设置选中样式
            
//            if isSelected {
//                self.selectButton.layer.borderColor = UIColor(hex: "29a79e", alpha: 1).cgColor
//            }else
//            {
//                self.selectButton.layer.borderColor = UIColor.clear.cgColor
//            }
        }
    }
    
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var selectButton: UIButton!
    
    var imageSelect: KYImageSelecthandler?
    
    @IBAction func imgSelected(_ sender: Any) {
        
        let result = self.imageSelect!(self.selectButton.isSelected)
        
        if result {
            self.selectButton.isSelected = !selectButton.isSelected
        }
        
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.imageView.image = KYMutiPickerHeader().bundleImage("YES")
        
        //设置图片
        self.selectButton.setImage(KYMutiPickerHeader().bundleImage("NO"), for: UIControlState.normal)
        self.selectButton.setImage(KYMutiPickerHeader().bundleImage("YES"), for: UIControlState.selected)
    }

}
