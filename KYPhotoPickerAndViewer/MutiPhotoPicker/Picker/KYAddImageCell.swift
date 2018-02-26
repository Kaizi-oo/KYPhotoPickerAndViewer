//
//  CYJAddImageCell.swift
//  YanXunSwift
//
//  Created by 杨凯 on 2017/4/20.
//  Copyright © 2017年 Chinayoujiao. All rights reserved.
//

import UIKit

protocol KYAddImageDelegate {
    
    /// 删除当前图片
    ///
    /// - Parameter image: <#image description#>
    /// - Returns: <#return value description#>
    func deleteImage(_ cell: KYAddImageCell) -> Void
}



class KYAddImageCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    var delegate: KYAddImageDelegate?
    
    var hasAdd: Bool = false
    
    //MARK: 监听图片设置方法，
//    var image: UIImage? {
//        didSet{
//            //找不到图片的设置为添加，添加的话，隐藏删除按钮
//            deleteButton.isHidden = image == #imageLiteral(resourceName: "Add")
//            hasAdd = image == #imageLiteral(resourceName: "Add")
//            imageView.image = image
//        }
//    }
    
    func setImage(image: UIImage?) {
        
        if let image = image {
            imageView.image = image
            deleteButton.isHidden = false
            hasAdd = true
        }else
        {
            imageView.image = KYMutiPickerHeader().bundleImage("Add")
            deleteButton.isHidden = true
            hasAdd = false
        }
    }
    
    
    @IBAction func deleteAction(_ sender: Any) {
        
        if delegate != nil{
            delegate?.deleteImage(self)
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
//        self.deleteButton.layer.cornerRadius = 12
//        self.deleteButton.layer.masksToBounds = true
//        self.deleteButton.layer.backgroundColor = UIColor(hex: "000000", alpha: 0.4).cgColor

    }

}
