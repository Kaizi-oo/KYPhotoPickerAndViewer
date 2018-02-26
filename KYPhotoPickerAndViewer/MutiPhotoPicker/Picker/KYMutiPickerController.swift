//
//  KYMutiPickerController.swift
//  MutiPhotoPicker
//
//  Created by Kyang on 2017/4/23.
//  Copyright © 2017年 Kyang. All rights reserved.
//

import UIKit
import Photos
import AVKit

typealias  KYCompleteHandler = (_ Assets: [PHAsset])->Void


class KYMutiPickerController: UIViewController {

    
    let kMutiPickerCellIndetifier = "KYImagePickerCell"
    
    var dataSource: PHFetchResult<PHAsset> = PHFetchResult()
    var collectionView: UICollectionView!
    
    var selectAssets: [PHAsset] = []
    
    var tabBar: KYMutiPickerBar!
    
    var completeHandler: KYCompleteHandler?
    
    var isImageOnly: Bool = false
    
    var maxCount: Int = 9
    
    init(maxCount: Int) {
        super.init(nibName: nil, bundle: nil)
        self.maxCount = maxCount
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.white

        navigationItem.title = "选择照片或视频"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(dismissSelf))
        
        makeCollectionView()
        makeBar()
        fetchAuthority()
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        fetchSelects()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @objc func dismissSelf() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
}



extension KYMutiPickerController {
    
    func makeBar() {
        
        tabBar = KYMutiPickerBar(frame: CGRect(x: 0, y: view.frame.height - 44, width: view.frame.size.width, height: 44), previewHandler: { [unowned self] in
            self.previewSelected()
        }) { [unowned self] in
            self.finishSelected()
        }
        
        view.addSubview(tabBar)
    }
    
    func previewSelected() {
        
    }
    
    func finishSelected()  {
        //3. 执行闭包
        if completeHandler != nil{
            
            completeHandler!(selectAssets)
        }
        //4. 隐藏界面
        self.navigationController?.dismiss(animated: true) {
            //
        }
    }
}

extension KYMutiPickerController {
 
//    权限判断
    func fetchAuthority() {
        //相册权限
            
        let author = PHPhotoLibrary.authorizationStatus()
        
        if (author == PHAuthorizationStatus.notDetermined){
            //无权限 引导去开启
            PHPhotoLibrary.requestAuthorization({ (sta) in
                if sta == .authorized {
                    
                    DispatchQueue.main.async {
                        //
                        self.fetchImages()
                    }
                    
                }
            })
        }else if author == .denied || author == .restricted
        {
            let alert = UIAlertController(title: "我们没有权限访问您的相册", message: "请到系统 设置->隐私->照片 以允许我们访问您的相册", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
            
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        }
        else
        {
            fetchImages()
        }
    }
    
    
    func fetchImages()  {

        let allPhotosOptions = PHFetchOptions()
        // 按图片生成时间排序
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        //选择普通照片
        allPhotosOptions.includeAssetSourceTypes = .typeUserLibrary
        
        if isImageOnly {
            allPhotosOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        }else
        {
            allPhotosOptions.predicate = NSPredicate(format: "mediaType = %d OR mediaType = %d", PHAssetMediaType.image.rawValue,PHAssetMediaType.video.rawValue)
        }
        
        // 获取图片
        let allResult = PHAsset.fetchAssets(with: allPhotosOptions)
        //设置数据源
        dataSource = allResult
        // 刷新表格
        collectionView.reloadData()
    }
    
    func fetchSelects() {
//        self.sureButton.setTitle("(\(selectAssets.count))确定", for: UIControlState.normal)
        //便利选择器，设置选择
        for asset in selectAssets
        {
          let row = dataSource.index(of: asset)
            collectionView.selectItem(at: IndexPath(item: row, section: 0), animated: true, scrollPosition: UICollectionViewScrollPosition.top)
        }
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


extension KYMutiPickerController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    ///创建表格
    func makeCollectionView() {
        
        let layout = UICollectionViewFlowLayout()
        //一行显示4个，一行4个，间距为4
        layout.itemSize = CGSize(width: (view.frame.width - 4 * 5) * 0.25, height: (view.frame.width - 4 * 5) * 0.25)
        layout.scrollDirection = UICollectionViewScrollDirection.vertical
        layout.minimumLineSpacing = 4
        layout.minimumInteritemSpacing = 4
        
        
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height - 44), collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.white
        
        collectionView.register(UINib(nibName: kMutiPickerCellIndetifier, bundle: nil), forCellWithReuseIdentifier: kMutiPickerCellIndetifier)
        
        self.collectionView = collectionView
        view.addSubview(collectionView)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(4, 4, 4, 4)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kMutiPickerCellIndetifier, for: indexPath) as! KYImagePickerCell
        //从数据源中取出图片，并设置图片尺寸为200* 200
        let imageAsset = dataSource[indexPath.row]
        cell.selectButton.isSelected = selectAssets.contains(imageAsset)

        if imageAsset.mediaType == .image {
            
            cell.timeLabel.isHidden = true
            cell.imageSelect = { [unowned self] (selected) in
                if !selected { //选中
                    
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
                        self.selectAssets.append(imageAsset)
                        
                        let count: Int = self.selectAssets.count
                        self.tabBar.selectedCount = count
//                        self.sureButton.setTitle("(\(count))确定", for: UIControlState.normal)
                        
                        return true
                    }
                }else
                {//未选中
                    if let index = self.selectAssets.index(of: imageAsset){
                        self.selectAssets.remove(at: index)
                    }
                    let count: Int = self.selectAssets.count
                    self.tabBar.selectedCount = count

//                    self.sureButton.setTitle("(\(count))确定", for: UIControlState.normal)
                    return true
                }
                
            }
        }else if imageAsset.mediaType == .video
        {
            cell.timeLabel.isHidden = false
            cell.timeLabel.text =  "\(imageAsset.duration.toTimeScope())"// Date.intervalToTime(length: Int(imageAsset.duration))
                cell.imageSelect = { [unowned self] (selected) in
                    if !selected { //选中
                        
                        if let asset = self.selectAssets.first {
                            var message: String
                            if asset.mediaType == .video {
                                message =  "只能选择一个视频"
                            }else
                            {
                                message = "视频与图片只能选择一种"
                            }
                            self.showMessage(message)
                            return false
                        }else
                        {
                            //FIXME: 相册中选取的视频的长度判断被干掉了！！ 需要选中视频时，查看视频长度，让她去截取[unowned self]
/**
                            if imageAsset.duration > 60 {

                                let alert = UIAlertController(title: "提示", message: "视频长度不能超过30分钟，是否去进行裁剪？", preferredStyle: .alert)

                                alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
                                alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { action in
                                    // go EditorController
                                    let option = PHVideoRequestOptions()
                                    option.version = .current
                                    option.deliveryMode = .automatic;

                                    PHImageManager.default().requestAVAsset(forVideo: imageAsset, options: option, resultHandler: { (avAsset, audioMix, hashValue) in
                                        if let urlAsset = avAsset as? AVURLAsset {
                                            print("\(urlAsset.url)")
                                            let editor = VideoEditViewController()
                                            editor.videoPath = urlAsset.url.absoluteString
                                            self.navigationController?.pushViewController(editor, animated: true)
                                        }

                                    })
                                }))

                                self.present(alert, animated: true, completion: nil)
                                return false
                            }else {
                            }
 */
                            self.selectAssets.append(imageAsset)
                            
                            let count: Int = self.selectAssets.count
                            self.tabBar.selectedCount = count
                            return true
                        }
                    }else
                    {//未选中
                        if let index = self.selectAssets.index(of: imageAsset){
                            self.selectAssets.remove(at: index)
                        }
                        let count: Int = self.selectAssets.count
                        self.tabBar.selectedCount = count
                        return true
                    }
            }
            cell.selectButton.isSelected = selectAssets.contains(imageAsset)

        }
        
        PHImageManager.default().requestImage(for: imageAsset, targetSize: CGSize(width: 200, height: 200), contentMode: PHImageContentMode.default, options: nil, resultHandler: { [unowned cell] (image, nil) in
            //
            cell.imageView.image = image
            
        })
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let currentAsset = dataSource[indexPath.row]
        if currentAsset.mediaType == .video {

            let requestOptions = PHVideoRequestOptions()

            PHImageManager.default().requestPlayerItem(forVideo: currentAsset, options: requestOptions, resultHandler: { (playerItem, hash) in
                
                let avPlayer = AVPlayerViewController()
                avPlayer.player = AVPlayer(playerItem: playerItem)
                
                self.present(avPlayer, animated: true, completion: {
                    
                    avPlayer.player?.play()
                })
            })
        }else
        {
            var imagesArr: [PHAsset] = []
            var viewsArr: [UIView] = []
            var startIndex: Int = 0
            //1. 遍历数据源，
            dataSource.enumerateObjects(using: { (asset, j, what) in
                if asset.mediaType == .image {
                    //2.选出所有assetType == image 的组成数组
                    imagesArr.append(asset)
                    if currentAsset == asset {
                        //3.当找到当前asset在新数组中的位置时，更新初始位置
                        startIndex = imagesArr.count
                    }
                    //3. 获得viewsArr
                    let cell = collectionView.cellForItem(at: indexPath)
                    
                    viewsArr.append(cell!)
                }
            })
            //MARK: 展示PreviewCOntroler
            KYPreviewViewController.showImages(imagesArr, atIndex: startIndex, fromSenderArray: viewsArr, selectedAssets: selectAssets, maxCount: maxCount,completation : {[ unowned self] (selecteds) in
                    self.selectAssets = selecteds
                    self.collectionView.reloadData()
                self.tabBar.selectedCount = self.selectAssets.count
            })
            
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
//        let count: Int = (collectionView.indexPathsForSelectedItems?.count)!
//
//        sureButton.setTitle("(\(count))确定", for: UIControlState.normal)
    }
    
}
class KYMutiPickerBar: UIView {
    
    typealias KYMPBarClosure = ()->()
    
    private var previewButton: UIButton!
    private var finishButton: UIButton!
    
    var previewClosure: KYMPBarClosure!
    var finishClosure: KYMPBarClosure!
    
    var isEnabled : Bool = false {
        didSet{
            previewButton.isEnabled = isEnabled
            finishButton.isEnabled = isEnabled
        }
    }
    
    init(frame: CGRect, previewHandler: @escaping KYMPBarClosure, finishHandler: @escaping KYMPBarClosure) {
        super.init(frame: frame)
        
        backgroundColor = UIColor(white: 0.3, alpha: 1)
        previewClosure = previewHandler
        finishClosure = finishHandler
        
        previewButton = UIButton(type: UIButtonType.custom)
        previewButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        previewButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        previewButton.frame = CGRect(x: 15, y: (frame.height - 35) * 0.5, width: 60, height: 35)
        
        previewButton.setTitle("预览", for: UIControlState.normal)
        previewButton.addTarget(self, action: #selector(previewAction), for: UIControlEvents.touchUpInside)
        previewButton.isEnabled = isEnabled
        addSubview(previewButton)
        
        finishButton = UIButton(type: UIButtonType.system)
        finishButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        
        finishButton.tintColor = UIColor.white
        finishButton.backgroundColor = UIColor.blue
        finishButton.layer.cornerRadius = 5
        finishButton.layer.masksToBounds = true
        finishButton.frame = CGRect(x: frame.width - 15 - 60, y: (frame.height - 35) * 0.5, width: 60, height: 35)
        
        finishButton.setTitle("完成", for: UIControlState.normal)
        finishButton.addTarget(self, action: #selector(finishAction), for: UIControlEvents.touchUpInside)
        finishButton.isEnabled = isEnabled
        addSubview(finishButton)
    }
    
    override init(frame: CGRect) {
        fatalError()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var selectedCount: Int = 0 {
        didSet{
            if selectedCount == 0 {
                self.finishButton.setTitle("完成", for: .normal)
                self.isEnabled = false
            }else {
                self.finishButton.setTitle("完成\(selectedCount)", for: .normal)
                self.isEnabled = true
            }
        }
    }
    
    @objc func previewAction() {
        previewClosure()
    }
    
    @objc func finishAction() {
        finishClosure()
    }
    
}
