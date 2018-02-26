//
//  KYImageViewer.swikKY
//  KYImageViewer
//
//  Created by kyang on 2017/9/18.
//  Copyright © 2017年 kyang. All rights reserved.
//

import Foundation
import UIKit
import Photos

import Kingfisher

//MARK: - KYImageView -

/**
 KYImageView
 */

public class KYImageView: UIScrollView, UIScrollViewDelegate{
    
    var imageView: UIImageView!
    var activityIndicator: UIActivityIndicatorView!
    var KYImageViewHandleTap: (() -> ())?
    var singleTap : UITapGestureRecognizer!
    var doubleTap : UITapGestureRecognizer!
    var panGesture : UIPanGestureRecognizer!
    
    var imageResource: KYImageResource! {
        didSet{
            
            setZoomScale(minimumZoomScale, animated: false)
            
            if let img : UIImage = imageResource.image {
                imageView.image = img
            }else if let imageURL : String = imageResource.imageURLString {
                
                imageView.kf.setImage(with: URL(string: imageURL), placeholder: nil, options: nil, progressBlock: { (current, total) in
                    //
                }, completionHandler: { [unowned self](image, error, cacheType, url) in
                    //
                    self.activityIndicator.stopAnimating()
                    
                })
            }else if let asset: PHAsset = imageResource.imageAsset {
                PHImageManager.default().requestImage(for: asset, targetSize: UIScreen.main.bounds.size, contentMode: PHImageContentMode.default, options: nil, resultHandler: {[weak self] (image, nil) in
                    //
                    self?.activityIndicator.stopAnimating()
                    self?.imageView.image = image
                })
            }
        }
    }
    //MARK: - KYImageViewBar
    
    public override init(frame : CGRect){
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        self.decelerationRate = UIScrollViewDecelerationRateFast
        self.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        self.minimumZoomScale = 1.0
        self.maximumZoomScale = 3.0
        self.delegate = self
        //        self.tag = atIndex
        
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: (frame.width - KYImageViewBarHeight)/2, y: (frame.height - KYImageViewBarHeight)/2, width: KYImageViewBarHeight, height: KYImageViewBarHeight))
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.white
        activityIndicator.hidesWhenStopped = true
        self.addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
        
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        imageView.contentMode = UIViewContentMode.scaleAspectFit
        
        self.addSubview(imageView)
        
        self.setupGestures()
    }
    
    public convenience init(frame : CGRect, imageResource : KYImageResource, atIndex : NSInteger){
        self.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupGestures() {
        //gesture
        singleTap = UITapGestureRecognizer(target: self, action: #selector(self.handleSingleTap(_:)))
        singleTap.numberOfTapsRequired = 1
        singleTap.delaysTouchesBegan = true
        self.addGestureRecognizer(singleTap)
        
        doubleTap = UITapGestureRecognizer(target: self, action: #selector(self.handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delaysTouchesBegan = true
        self.addGestureRecognizer(doubleTap)
        
        singleTap.require(toFail: doubleTap)
        
        panGesture = UIPanGestureRecognizer()
        panGesture.maximumNumberOfTouches = 1
        panGesture.minimumNumberOfTouches = 1
        self.addGestureRecognizer(panGesture)
    }
    
    //MARK: - UIScrollViewDelegate
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView?{
        return imageView
    }
    
    public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat){
        let ws = scrollView.frame.size.width - scrollView.contentInset.left - scrollView.contentInset.right
        let hs = scrollView.frame.size.height - scrollView.contentInset.top - scrollView.contentInset.bottom
        let w = imageView.frame.size.width
        let h = imageView.frame.size.height
        var rct = imageView.frame
        rct.origin.x = (ws > w) ? (ws-w)/2 : 0
        rct.origin.y = (hs > h) ? (hs-h)/2 : 0
        imageView.frame = rct;
    }
    
    //MARK: - handleSingleTap
    
    @objc func handleSingleTap(_ sender: UITapGestureRecognizer){
        if (self.zoomScale == self.maximumZoomScale){
            self.setZoomScale(self.minimumZoomScale, animated: true)
        }else{
            self.KYImageViewHandleTap?()
        }
    }
    
    //MARK: - handleDoubleTap
    
    @objc func handleDoubleTap(_ sender: UITapGestureRecognizer){
        let touchPoint = sender.location(in: self)
        if (self.zoomScale == self.maximumZoomScale){
            self.setZoomScale(self.minimumZoomScale, animated: true)
        }else{
            self.zoom(to: CGRect(x: touchPoint.x, y: touchPoint.y, width: 1, height: 1), animated: true)
        }
    }
    
}

