//
//  KYNineImagesController.swift
//  MutiPhotoPicker
//
//  Created by 杨凯 on 2017/4/24.
//  Copyright © 2017年 Kyang. All rights reserved.
//

import Foundation
import UIKit
import Photos

class KYSquaredPickerView: UIView {
    
    let kNineImageViewIdentifier = "KYAddImageCell"
    
    fileprivate var dataSource: [Any] = [""] // 表格的数据源
    fileprivate var collectionView: UICollectionView!
    
    let kPadding: CGFloat = 8 //边距
    let count: Int = 4 // 数目
    var itemSize: CGSize {
        get{
            let imageWidth: CGFloat = (collectWidth - CGFloat(count + 1) * kPadding) / CGFloat(count)
            return CGSize(width: imageWidth, height: imageWidth)
        }
    }
    fileprivate var collectWidth: CGFloat{
        get{
            return frame.size.width - 2 * self.kPadding
        }
    }
    
    func getSelectImages() -> [UIImage] {
        
        var images: [UIImage] = []
        
        //遍历selectAssets 返回未压缩的图片对象
        selectAssets.forEach { (element) in
            //PHImageManagerMaximumSize
            
            let options = PHImageRequestOptions()
            options.resizeMode = .exact
            options.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
            options.isSynchronous = true
            
            PHImageManager.default().requestImage(for: element, targetSize: PHImageManagerMaximumSize, contentMode: PHImageContentMode.default, options: options, resultHandler: { (img, nil) in
                
                images.append(img!)
            })
        }
        
        return images
    }
    
    ///已选的数据源，当图库选择回来之后需要重置dataSource
    var selectAssets: [PHAsset] = [] {
        didSet{
            dataSource.removeAll()
            selectAssets.forEach{ [unowned self] in self.dataSource.append($0)}
            //设置选中数据源，并重置添加数据的数据源
            if dataSource.count < 9 {
                dataSource.append("add")
            }
            collectionView.reloadData()
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let line = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: 0.5))
        line.backgroundColor = UIColor.lightGray
        
        self.addSubview(line)
        
        makeCollectionView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

//MARK: 添加图片的Cell代理
extension KYSquaredPickerView: KYAddImageDelegate
{
    func deleteImage(_ cell: KYAddImageCell) {
        //1.获取当前删除的cell
        let indexPath = collectionView.indexPath(for: cell)
        
        //2.删除dataSource中数据，dataSource---存放着表格的数据源，因为不满9的的时候有一个空白的添加的cell，所以和selectAssets 分开存放了
        dataSource.remove(at: (indexPath?.row)!)
        
        //4.表格删除数据
        collectionView.deleteItems(at: [indexPath!])
        
        //5. 当删除后，数量==8，并且最后一个是phasset类型,在后面加一个add,表格也加一个
        if dataSource.count == 8 && ((dataSource.last as? PHAsset) != nil){
            dataSource.append("add")
            collectionView.insertItems(at: [IndexPath(item: 8, section: 0)])
        }
        //666.删除selectAsset中数据, selectAssets---存放着图片的数据，
        selectAssets.remove(at: (indexPath?.row)!)
        
    }
}

//MARK: CollectionView + CollectionViewDelegate,UICollectionViewDataSource
extension KYSquaredPickerView: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    //创建collectionView
    func makeCollectionView() {
        
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = itemSize
        layout.scrollDirection = UICollectionViewScrollDirection.vertical
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        
        
        let collectionView = UICollectionView(frame: CGRect(x: kPadding, y: kPadding, width: collectWidth, height: collectWidth), collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.white
        
        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = true
        
        
        collectionView.register(UINib(nibName: kNineImageViewIdentifier, bundle: nil), forCellWithReuseIdentifier: kNineImageViewIdentifier)
        
        self.collectionView = collectionView
        addSubview(collectionView)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(kPadding,kPadding,kPadding,kPadding)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kNineImageViewIdentifier, for: indexPath) as! KYAddImageCell
        // 设置代理
        cell.delegate = self
        //FIXME: 根据asset拿出预览图片,图片大小需另行配置，
        if let imageAsset = dataSource[indexPath.row] as? PHAsset{
            PHImageManager.default().requestImage(for: imageAsset, targetSize: itemSize, contentMode: PHImageContentMode.default, options: nil, resultHandler: { (image, nil) in
                if imageAsset.mediaType == .image {
                    cell.timeLabel.isHidden = true
                }else
                {
                    cell.timeLabel.isHidden = false
                    cell.timeLabel.text = "\(imageAsset.duration)"
                }
                cell.setImage(image: image)
            })
        }else
        {
            //找不到图片的设置为添加，添加的话，隐藏删除按钮
            cell.setImage(image: nil)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //取消选择
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let cell = collectionView.cellForItem(at: indexPath) as! KYAddImageCell
        // 如果已经有图片了，那么返回
        if cell.hasAdd {
            
            var imagesArr: [KYImageResource] = []
            var viewsArr: [UIView] = []
            for j in 0..<self.selectAssets.count { // 需要比dataSoruce个数少一个
                
                imagesArr.append(KYImageResource(asset: (dataSource[j] as! PHAsset)))
                
                let cell = collectionView.cellForItem(at: IndexPath(row: j, section: 0))
                
                viewsArr.append(cell!)
            }
            KYImageViewer.showImages(imagesArr, atIndex: indexPath.row, fromSenderArray: viewsArr)
            
            return
        }
        // MARK: - 弹出选择视图
        alertCameraOrLibrary(view: cell)
    }
}

extension KYSquaredPickerView : UINavigationControllerDelegate,UIImagePickerControllerDelegate
{
    
    func alertCameraOrLibrary(view: UIView) {
        //MARK: 1.选择了第几个Cell
        //        selectIndex = indexPath.row
        //        DLog("点击了第几个：\(selectIndex)")
        let alert = UIAlertController(title: "请选择相册或相机", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        alert.popoverPresentationController?.sourceView = view
        alert.popoverPresentationController?.sourceRect = view.bounds
        
        alert.addAction(UIAlertAction(title: "相册", style: UIAlertActionStyle.default, handler: {[unowned self] (action) in
            //打开相册
            let mutipicker = KYMutiPickerController(maxCount: 9 - self.selectAssets.count)
            let nav = UINavigationController(rootViewController: mutipicker)
            //如果已经存在选中，那么只能继续选择图片
            if self.selectAssets.count > 0 {
                mutipicker.isImageOnly = true
            }
            
            mutipicker.completeHandler = {(assets) in
                // 设置选中的图片
                self.selectAssets.append(contentsOf: assets)
            }
            UIApplication.shared.keyWindow?.ky_topMostController()?.present(nav, animated: true, completion: {
                //
            })
        }))
        
        alert.addAction(UIAlertAction(title: "相机", style: UIAlertActionStyle.default, handler: {[unowned self] (action) in
            //打开相机
            
//            let record = VideoRecordViewController()
//
//            UIApplication.shared.keyWindow?.ky_topMostController()?.present(record, animated: false, completion: nil)

            
//            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
//                let picker = UIImagePickerController()
//                picker.sourceType = UIImagePickerControllerSourceType.camera
//                picker.allowsEditing = false
//                picker.delegate = self
//
//                UIApplication.shared.keyWindow?.ky_topMostController()?.present(picker, animated: false, completion: nil)
//            }
            
        }))
        alert.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.cancel, handler: {(action) in
            //
            
        }))
        
        DispatchQueue.main.async {
            UIApplication.shared.keyWindow?.ky_topMostController()?.present(alert, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        // 设置筛选条件
        let allPhotosOptions = PHFetchOptions()
        // 按图片生成时间排序
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        //选择普通照片
        allPhotosOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        
        //本地路径，代替ReferenceURL
        var localIdentifier: String = ""
        
        //通过存储图片到本地路径，顺便拿到Url
        PHPhotoLibrary.shared().performChanges({
            //获取根据change对象拿到localIndentifier
            let createdAssetID = PHAssetChangeRequest.creationRequestForAsset(from: image).placeholderForCreatedAsset?.localIdentifier
            localIdentifier = createdAssetID!
            
            print("createdAssetID:\(createdAssetID ?? "nil")")
        }) { (success, error) in
            //通过localIdentifier 拿到PHAsset对象
            let assets = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: allPhotosOptions)
            if assets.firstObject != nil
            {
                //插入一个新对象
                self.dataSource.insert(assets.firstObject!, at: self.dataSource.count - 1)
                
                //最终多余9个，那么删了最后一个。肯定是一个add
                if self.dataSource.count > 9
                {
                    self.dataSource.removeLast()
                }
                
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    //直接appand， 断绝了修改图片的问题，只能删除然后新增～所以直接appand
                    self.selectAssets.append(assets.firstObject!)
                }
            }
        }
        
        picker.dismiss(animated: true) {
            //
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        //
        picker.dismiss(animated: true, completion: nil)
    }
}

