//
//  KYPreviewViewController.swift
//  KYImageViewer
//
//  Created by kyang on 2017/9/19.
//  Copyright © 2017年 kyang. All rights reserved.
//

import Foundation
import UIKit
import Photos

class KYPreviewViewController: UIViewController , UIViewControllerTransitioningDelegate{
    
    var presentAnimator: PresentAnimator = PresentAnimator()
    var dismissAnimator: DismisssAnimator = DismisssAnimator()
    
    var currenIndex: NSInteger = 0
    var assets: [PHAsset]!
    var selectAssets: [PHAsset] = []
    var maxCount: Int = 0
    var fromSenderRectArray: [CGRect] = []
    var isPanRecognize: Bool = false
    
    var completeHandler: ((_ selectedAssets: [PHAsset])->Void)?
    
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
    
    fileprivate lazy var tabBar : KYPreviewBar = {
        let view = KYPreviewBar(frame: CGRect(x: 0 ,  y: KYImageViewerScreenHeight ,  width: KYImageViewerScreenWidth, height: KYImageViewBarHeight) ,
                                selectTapBlock: {[unowned self] (oldState) in
                                    return self.selectedImageAction(oldState)
            },
                                closeTapBlock: { [unowned self] in
                                    self.animationOut()
        })
        view.alpha = 0
        return view
    }()
    
    /// 弹出preview，
    ///
    /// - Parameters:
    ///   - assets: 数据源
    ///   - atIndex: 初始位置
    ///   - fromSenderArray: 动画位移
    ///   - selectedAssets: 已选中图片
    ///   - maxCount: 最大个数
    public class func showImages(_ assets : [PHAsset] , atIndex : NSInteger , fromSenderArray: [UIView], selectedAssets: [PHAsset], maxCount: Int, completation: ((_ selectedAssets: [PHAsset])->Void)?){
        
        let target = KYPreviewViewController()
        target.modalPresentationStyle = .overCurrentContext
        target.selectAssets = selectedAssets
        target.maxCount = maxCount
        target.fromSenderRectArray = []
        
        target.completeHandler = completation
        for i in 0 ... fromSenderArray.count-1 {
            let rect : CGRect = fromSenderArray[i].superview!.convert(fromSenderArray[i].frame, to:UIApplication.shared.keyWindow)
            target.fromSenderRectArray.append(rect)
        }
        
        target.currenIndex = atIndex
        target.assets = assets
        target.transitioningDelegate = target
        target.presentAnimator.originFrame = target.fromSenderRectArray[atIndex]
        
        UIApplication.shared.keyWindow?.ky_topMostController()?.present(target, animated: true, completion: nil)
    }
    
    /// life-circle
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
    
    func setupView(shouldAnimate:Bool) {
        
        collectionView.frame = UIScreen.main.bounds
        tabBar.frame = CGRect(x: 0 ,  y: KYImageViewerScreenHeight ,  width: KYImageViewerScreenWidth, height: KYImageViewBarHeight)
        
        if shouldAnimate {
            self.show()
        }else{
            self.collectionView.alpha = 1.0
            self.tabBar.alpha = 1
            self.tabBar.frame = CGRect(x: 0, y: KYImageViewerScreenHeight-KYImageViewBarHeight, width: KYImageViewerScreenWidth, height: KYImageViewBarHeight)
            self.tabBar.layoutIfNeeded()
            self.tabBar.countLabel.text = "\(self.currenIndex + 1)-\(self.assets.count)"
            let contentOffSet = CGPoint(x: CGFloat(self.currenIndex - 1) * KYImageViewerScreenWidth, y: 0)
            self.collectionView.setContentOffset( contentOffSet, animated: false)
        }
    }
    func show() {
        
        self.addOrientationChangeNotification()
        
        UIView.animate(withDuration: KYImageViewerAnimationDuriation, animations: {[unowned self] () -> Void in
            self.collectionView.alpha = 1.0
            self.tabBar.alpha = 1
            self.tabBar.frame = CGRect(x: 0, y: KYImageViewerScreenHeight-KYImageViewBarHeight, width: KYImageViewerScreenWidth, height: KYImageViewBarHeight)
            self.tabBar.countLabel.text = "\(self.currenIndex + 1)-\(self.assets.count)"
            
            
            }, completion: {(finished: Bool) -> Void in
                //            self.beginAnimationView.isHidden = true
                
        })
        
        let contentOffSet = CGPoint(x: CGFloat(self.currenIndex - 1) * KYImageViewerScreenWidth, y: 0)
        self.collectionView.setContentOffset( contentOffSet, animated: false)
    }
    
    func animationOut() {
        
        dismissAnimator.originFrame = self.fromSenderRectArray[currenIndex]
        
        dismiss(animated: true) {[unowned self] in
            self.completeHandler?(self.selectAssets)
        }
    }
    
    //MARK: - selectedImageAction
    fileprivate func selectedImageAction(_ oldState: Bool)-> Bool {
        let asset = assets[currenIndex]
        if !oldState { //要选择！
            if let asset = self.selectAssets.first {
                if asset.mediaType == .video {
                    let message =  "视频与图片只能选择一种"
                    self.showMessage(message)
                    return false
                }
            }
            if self.selectAssets.count >= self.maxCount {
                
                self.showMessage("最多能选择\(self.maxCount)张图片")
                return false
            }else
            {
                self.selectAssets.append(asset)
                return true
            }
        }else
        {//未选中
            if let index = self.selectAssets.index(of: asset){
                self.selectAssets.remove(at: index)
            }
            return true
        }
    }
    
    //MARK: - saveImageDone
    @objc func saveImageDone(_ image : UIImage, error: Error, context: UnsafeMutableRawPointer?) {
        self.tabBar.countLabel.text = NSLocalizedString("Save image done.", comment: "Save image done.")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(1.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
            self.tabBar.countLabel.text = "\(self.currenIndex+1)/\(self.assets.count)"
        })
    }
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return presentAnimator
    }
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return dismissAnimator
    }
    
    func showMessage(_ message: String) {
        let alert = UIAlertController(title: "温馨提示", message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        self.present(alert, animated: true, completion: {
            //
            sleep(1)
            alert.dismiss(animated:true, completion: nil)
        })
    }
    
}

// MARK: - collectionView delegate,datasource
extension KYPreviewViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "KYImageContainerCell", for: indexPath) as? KYImageContainerCell
        
        cell?.kyImageView.KYImageViewHandleTap = nil
        cell?.kyImageView.panGesture.delegate = self;
        cell?.kyImageView.panGesture.addTarget(self, action: #selector(self.panGestureRecognized(_:)))
        
        cell?.kyImageView.tag = indexPath.row
        cell?.kyImageView.imageResource = KYImageResource(asset: assets[indexPath.row])
        
        return cell!
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset
        //MARK: 切换！
        currenIndex = Int(roundf(Float(offset.x / KYImageViewerScreenWidth)))
        tabBar.countLabel.text = "\(currenIndex + 1) - \(assets.count)"
        
        //更新bar的内容
        let contain = selectAssets.contains(assets[currenIndex])
        tabBar.updateSelectButton(selected: contain)
    }
}

//MARK: extension, 滑动事件
extension KYPreviewViewController: UIGestureRecognizerDelegate
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
                            
                            self.dismiss(animated: false, completion: {[unowned self] in
                                self.completeHandler?(self.selectAssets)
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

//MARK: extension, 屏幕翻转
extension KYPreviewViewController {
    
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

//MARK: KYPreviewBar
/// KYPreviewBar
class KYPreviewBar: UIView {
    
    var selectedButtonTapBlock : ((_ oldState: Bool) -> Bool)!
    var closeButtonTapBlock : (() ->())!
    
    lazy var closeButton : UIButton = {
        let button = UIButton(frame: CGRect(x: KYImageViewBarDefaultMargin, y: (self.frame.height-KYImageViewBarButtonWidth)/2, width: KYImageViewBarButtonWidth, height: KYImageViewBarButtonWidth))
        button.backgroundColor = UIColor.clear
        button.contentMode = UIViewContentMode.scaleAspectFill
        button.addTarget(self, action: #selector(KYImageViewBar.onCloseButtonTapped), for: UIControlEvents.touchUpInside)
        return button
    }()
    
    
    lazy var selectButton : UIButton = {
        let button = UIButton(frame: CGRect(x: self.frame.width-KYImageViewBarButtonWidth-KYImageViewBarDefaultMargin, y: (self.frame.height-KYImageViewBarButtonWidth)/2, width: KYImageViewBarButtonWidth, height: KYImageViewBarButtonWidth))
        button.backgroundColor = UIColor.clear
        button.contentMode = UIViewContentMode.scaleAspectFill
        button.addTarget(self, action: #selector(onSelectButtonTapped(_:)), for: UIControlEvents.touchUpInside)
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
    
    public convenience init(frame: CGRect , selectTapBlock: @escaping (_ oldState: Bool) ->Bool , closeTapBlock: @escaping ()->()) {
        self.init(frame: frame)
        self.backgroundColor = KYImageViewBarBackgroundColor
        
        selectedButtonTapBlock = selectTapBlock
        closeButtonTapBlock = closeTapBlock

        closeButton.setImage(KYMutiPickerHeader().bundleImage("close"), for: UIControlState())
        self.addSubview(closeButton)
        
        //设置图片
        selectButton.setImage(KYMutiPickerHeader().bundleImage("NO"), for: UIControlState.normal)
        selectButton.setImage(KYMutiPickerHeader().bundleImage("YES"), for: UIControlState.selected)
        self.addSubview(selectButton)
        
        self.addSubview(countLabel)
    }
    
    /// 更新Bar的选中状态
    func updateSelectButton(selected: Bool){
        selectButton.isSelected = selected
    }
    
    public override func layoutIfNeeded() {
        super.layoutIfNeeded()
        
        self.closeButton.frame = CGRect(x: KYImageViewBarDefaultMargin, y: (self.frame.height-KYImageViewBarButtonWidth)/2, width: KYImageViewBarButtonWidth, height: KYImageViewBarButtonWidth)
        self.selectButton.frame = CGRect(x: self.frame.width-KYImageViewBarButtonWidth-KYImageViewBarDefaultMargin, y: (self.frame.height-KYImageViewBarButtonWidth)/2, width: KYImageViewBarButtonWidth, height: KYImageViewBarButtonWidth)
        self.countLabel.frame = CGRect(x: KYImageViewBarButtonWidth+KYImageViewBarDefaultMargin*2, y: 0, width: self.frame.width-(KYImageViewBarButtonWidth+KYImageViewBarDefaultMargin*2)*2, height: self.frame.height)
    }
    
    //MARK: - onCloseButtonTapped
    
    func onCloseButtonTapped(){
        self.closeButtonTapBlock();
    }
    
    //MARK: - onSaveButtonTapped
    
    @objc func onSelectButtonTapped(_ sender: UIButton){
        let success = self.selectedButtonTapBlock(sender.isSelected)
        if success {
            sender.isSelected = !sender.isSelected
        }
    }
}

