//
//  KYIndirectController.swift
//  KYImageViewer
//
//  Created by kyang on 2017/9/18.
//  Copyright © 2017年 kyang. All rights reserved.
//

import Foundation
import UIKit
import Photos

protocol KYImageResourceProtocol {
    var image : UIImage? { get }
    var imageURLString : String? { get }
}

public struct KYImageResource : KYImageResourceProtocol {
    var image: UIImage?
    var imageURLString: String?
    var imageAsset: PHAsset?
    
    
    public init(image: UIImage?, imageURLString: String?) {
        self.image = image
        self.imageURLString = imageURLString
    }
    
    public init(asset: PHAsset?) {
        self.image = nil
        self.imageURLString = nil
        self.imageAsset = asset
    }
}

class KYImageViewer: UIViewController , UIViewControllerTransitioningDelegate{
    
    //    var animateOver: (()->())!
    var presentAnimator: PresentAnimator = PresentAnimator()
    var dismissAnimator: DismisssAnimator = DismisssAnimator()
    
    private var fromRect: CGRect!
    var currenIndex: NSInteger = 0
    var imageUrlArray: [KYImageResource]!
    private var fromSenderRectArray: [CGRect] = []
    private var isPanRecognize: Bool = false
    
    fileprivate lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = UIScreen.main.bounds.size
        
        let collection = UICollectionView(frame: UIScreen.main.bounds, collectionViewLayout: layout)
        collection.delegate = self
        collection.dataSource = self
        collection.isPagingEnabled = true
        collection.allowsSelection = false
        collection.register(KYImageContainerCell.self, forCellWithReuseIdentifier: "KYImageContainerCell")
        collection.backgroundColor = UIColor.clear
        
        return collection
    }()
    
    fileprivate lazy var tabBar : KYImageViewBar = {
        let view = KYImageViewBar(frame: CGRect(x: 0 ,  y: KYImageViewerScreenHeight ,  width: KYImageViewerScreenWidth, height: KYImageViewBarHeight) ,
                                  saveTapBlock: {[unowned self] in
                                    self.saveCurrentImage();
        },
                                  closeTapBlock: { [unowned self] in
                                    self.animationOut()
        })
        view.alpha = 0
        return view
    }()
    
    public class func showImages(_ images : [KYImageResource] , atIndex : NSInteger , fromSenderArray: [UIView]){
        
        let target = KYImageViewer()
        target.modalPresentationStyle = .overCurrentContext

        target.fromSenderRectArray = []
        
        for i in 0 ... fromSenderArray.count-1 {
            let rect : CGRect = fromSenderArray[i].superview!.convert(fromSenderArray[i].frame, to:UIApplication.shared.keyWindow)
            target.fromSenderRectArray.append(rect)
        }
        
        target.currenIndex = atIndex
        target.imageUrlArray = images
        target.transitioningDelegate = target
        target.presentAnimator.originFrame = target.fromSenderRectArray[atIndex]

        
        UIApplication.shared.keyWindow?.ky_topMostController()?.present(target, animated: true, completion: {
            //
        })
    }
    
    func setupView(shouldAnimate: Bool) {
        
        collectionView.frame = UIScreen.main.bounds
        tabBar.frame = CGRect(x: 0 ,  y: KYImageViewerScreenHeight ,  width: KYImageViewerScreenWidth, height: KYImageViewBarHeight)
        
        if shouldAnimate {
            self.show()
        }else{
            self.collectionView.alpha = 1.0
            self.tabBar.alpha = 1
            self.tabBar.frame = CGRect(x: 0, y: KYImageViewerScreenHeight-KYImageViewBarHeight, width: KYImageViewerScreenWidth, height: KYImageViewBarHeight)
            self.tabBar.layoutIfNeeded()
            self.tabBar.countLabel.text = "\(self.currenIndex + 1)-\(self.imageUrlArray.count)"
            
            self.collectionView.scrollToItem(at: IndexPath(item: currenIndex, section: 0), at: .top, animated: false)
   
        }
        
    }
    func show() {
        
        self.addOrientationChangeNotification()
        
        UIView.animate(withDuration: KYImageViewerAnimationDuriation, animations: {[unowned self] () -> Void in
            self.collectionView.alpha = 1.0
            self.tabBar.alpha = 1
            self.tabBar.frame = CGRect(x: 0, y: KYImageViewerScreenHeight-KYImageViewBarHeight, width: KYImageViewerScreenWidth, height: KYImageViewBarHeight)
            self.tabBar.countLabel.text = "\(self.currenIndex + 1)-\(self.imageUrlArray.count)"
            

        }, completion: {(finished: Bool) -> Void in
//            self.beginAnimationView.isHidden = true
        })
        
        let contentOffSet = CGPoint(x: CGFloat(self.currenIndex) * KYImageViewerScreenWidth, y: 0)
        self.collectionView.setContentOffset( contentOffSet, animated: false)
    }
    
    func animationOut() {
        
        dismissAnimator.originFrame = self.fromSenderRectArray[currenIndex]
        
        dismiss(animated: true) { 
            //
        }
    }
    
    //MARK: - saveCurrentImage
    
    fileprivate func saveCurrentImage(){
        var imageToSave : UIImage? = nil;
        
        let cell = collectionView.visibleCells.first as? KYImageContainerCell
        
        imageToSave = cell?.kyImageView.imageView.image

        if imageToSave != nil {
            UIImageWriteToSavedPhotosAlbum(imageToSave!, self, #selector(self.saveImageDone(_:error:context:)), nil)
        }
    }
    
    //MARK: - saveImageDone
    
    @objc func saveImageDone(_ image : UIImage, error: Error, context: UnsafeMutableRawPointer?) {
        self.tabBar.countLabel.text = NSLocalizedString("Save image done.", comment: "Save image done.")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(1.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
            self.tabBar.countLabel.text = "\(self.currenIndex+1)/\(self.imageUrlArray.count)"
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = KYImageViewerBackgroundColor

        view.addSubview(collectionView)
        view.addSubview(tabBar)
        self.setupView(shouldAnimate: true)
    }
    
    deinit {
        print("🔥🔥")
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return presentAnimator
    }
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return dismissAnimator
    }
    
    
}

extension KYImageViewer: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageUrlArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "KYImageContainerCell", for: indexPath) as? KYImageContainerCell
        
        cell?.kyImageView.KYImageViewHandleTap = {[unowned self] in
            self.animationOut()
        }
        cell?.kyImageView.panGesture.delegate = self;
        cell?.kyImageView.panGesture.addTarget(self, action: #selector(self.panGestureRecognized(_:)))

        cell?.kyImageView.tag = indexPath.row
        cell?.kyImageView.imageResource = imageUrlArray[indexPath.row]
        
        return cell!
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset
        //MARK: 切换！
        currenIndex = Int(roundf(Float(offset.x / KYImageViewerScreenWidth)))
        tabBar.countLabel.text = "\(currenIndex + 1) - \(imageUrlArray.count)"
    }
}
extension KYImageViewer: UIGestureRecognizerDelegate
{
    
    //MARK: - gestureRecognizerShouldBegin
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if let kImageView = gestureRecognizer.view as? KYImageView{
            
            let imageViewSize = kImageView.imageView.frame.size
            let size1 = kImageView.contentOffset
            
            if size1.y == 0 || size1.y + KYImageViewerScreenHeight == imageViewSize.height {
                let translatedPoint = (gestureRecognizer as! UIPanGestureRecognizer).translation(in: gestureRecognizer.view)
                return fabs(translatedPoint.y) > fabs(translatedPoint.x);
            }
            return false
        }
        return true
    }
    
    //MARK: - panGestureRecognized
    
    @objc func panGestureRecognized(_ gesture : UIPanGestureRecognizer){
        let currentItem : UIView = gesture.view!
        let translatedPoint = gesture.translation(in: currentItem)
        let newAlpha = CGFloat(1 - fabsf(Float(translatedPoint.y/KYImageViewerScreenHeight)))

        if (gesture.state == UIGestureRecognizerState.began || gesture.state == UIGestureRecognizerState.changed){
            
            collectionView.isScrollEnabled = false
            print("设置背景颜色  \(newAlpha)")

            currentItem.frame = CGRect(x: currentItem.frame.origin.x, y: translatedPoint.y, width: currentItem.frame.size.width, height: currentItem.frame.size.height)
            self.tabBar.frame = CGRect(x: 0, y: KYImageViewerScreenHeight-KYImageViewBarHeight*newAlpha, width: KYImageViewerScreenWidth, height: KYImageViewBarHeight)
            self.view.backgroundColor = KYImageViewerBackgroundColor.withAlphaComponent(newAlpha)
        }else if (gesture.state == UIGestureRecognizerState.ended ){
            
            collectionView.isScrollEnabled = true
            if (fabs(translatedPoint.y) >= KYImageViewerScreenHeight*0.2){

                UIView.animate(withDuration: KYImageViewerAnimationDuriation, animations: {[unowned self] () -> Void in
                    if (translatedPoint.y > 0){
                        currentItem.frame = CGRect(x: currentItem.frame.origin.x, y: KYImageViewerScreenHeight, width: currentItem.frame.size.width, height: currentItem.frame.size.height)
                    }else{
                        currentItem.frame = CGRect(x: currentItem.frame.origin.x, y: -KYImageViewerScreenHeight, width: currentItem.frame.size.width, height: currentItem.frame.size.height)
                    }
                    
                    self.tabBar.frame = CGRect(x: 0, y: KYImageViewerScreenHeight, width: KYImageViewerScreenWidth, height: KYImageViewBarHeight)
                }, completion: { [unowned self] (finished: Bool) -> Void in
                    if  (finished == true){
                        self.removeOrientationChangeNotification()
                        
                        self.dismiss(animated: false, completion: {
                            //
                        })
                    }
                })
            }else{
                print("设置背景颜色2")
                UIView.animate(withDuration: KYImageViewerAnimationDuriation, animations: { [unowned self] () -> Void in
                    self.view.backgroundColor = KYImageViewerBackgroundColor
                    currentItem.frame = CGRect(x: currentItem.frame.origin.x, y: 0, width: currentItem.frame.size.width, height: currentItem.frame.size.height)
                    self.tabBar.frame = CGRect(x: 0, y: KYImageViewerScreenHeight-KYImageViewBarHeight, width: KYImageViewerScreenWidth, height: KYImageViewBarHeight)
                }, completion: {  (finished: Bool) -> Void in
                    
                })
            }
        }
    }
}

extension KYImageViewer {
    
    fileprivate func addOrientationChangeNotification() {
        NotificationCenter.default.addObserver(self,selector: #selector(onChangeStatusBarOrientationNotification(notification:)),
                                               name: NSNotification.Name.UIApplicationDidChangeStatusBarOrientation,
                                               object: nil)
        
    }
    
    fileprivate func removeOrientationChangeNotification() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc fileprivate func onChangeStatusBarOrientationNotification(notification : Notification) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
            //            self.setupView(shouldAnimate: false)
        })
    }
}


class KYImageContainerCell: UICollectionViewCell {
    
    var kyImageView: KYImageView!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        kyImageView = KYImageView(frame: CGRect(x: 0, y: 0, width: KYImageViewerScreenWidth, height: KYImageViewerScreenHeight))
        
        contentView.addSubview(kyImageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
