//
//  BKPhotoBrowser.swift
//  BKPhotoBrowser
//
//  Created by LinXunFeng on 2018/11/20.
//  Copyright © 2018 LinXunFeng. All rights reserved.
//

import SKPhotoBrowser
import Kingfisher

// MARK:- BKPhotoBrowser
final class BKPhotoBrowser: NSObject {
    static let shared: BKPhotoBrowser = BKPhotoBrowser()
    
    fileprivate let imageCache = KingfisherManager.shared.cache
    fileprivate var browser : SKPhotoBrowser?
    
    override private init() {
        super.init()
        
        // 默认使用的是 NSCache，可以修改为 Kingfisher 的 ImageCache
        SKCache.sharedCache.imageCache = SYImageCache()
    }
}

// MARK:- Tools
extension BKPhotoBrowser {
    func handle(
        _ resources: [BKPhotoProtocol],
        holder: UIImage? = nil,
        holders: [BKPhotoProtocol] = [],
        shouldCache: Bool = true
    ) -> [SKPhoto] {
        var bkPhotos : [SKPhoto] = []
        if holders.isEmpty {
            bkPhotos = resources.map {
                let p = $0.fetchPhoto(holder: holder)
                p.shouldCachePhotoURLImage = shouldCache
                return p
            }
        } else {
            let delta = resources.count - holders.count
            if delta > 0 {
                holders.enumerated().forEach {
                    // underlyingImage : 如果有对应缓存则取缓存后的的 image，否则返回 holer
                    let holderImage = $0.element.fetchPhoto(holder: holder).underlyingImage
                    let photoImage = resources[$0.offset].fetchPhoto(holder: holderImage)
                    photoImage.shouldCachePhotoURLImage = shouldCache
                    bkPhotos.append(photoImage)
                }
                for i in holders.count..<resources.count {
                    let p = resources[i].fetchPhoto(holder: holder)
                    p.shouldCachePhotoURLImage = shouldCache
                    bkPhotos.append(p)
                }
            }
        }
        return bkPhotos
    }
}

// MARK: Base
extension BKPhotoBrowser {
    /// 获取AssociateBrowser
    ///
    /// - Parameters:
    ///   - originImage: 用于动画的 Image 对象
    ///   - photos: 资源数组（String | UIImage）
    ///   - animatedFromView: 用于定位的视图
    ///   - holder: 占位图
    ///   - holders: 占位图数组（String | UIImage）
    ///   - shouldCache: 缓存 (仅网络请求的数据有效)
    /// - Returns: BKPhotoBrowser
    func fetchAssociateBrowser(
        originImage: UIImage,
        resources: [BKPhotoProtocol],
        animatedFromView: UIView,
        holder: UIImage? = nil,
        holders: [BKPhotoProtocol] = [],
        shouldCache: Bool = true
    ) -> BKPhotoBrowser {
        let bkPhotos = BKPhotoBrowser.shared.handle(
            resources,
            holder: holder,
            holders: holders,
            shouldCache: shouldCache
        )
        
        let browser = SKPhotoBrowser(
            originImage: originImage,
            photos: bkPhotos,
            animatedFromView: animatedFromView
        )
        BKPhotoBrowser.shared.browser = browser
        return BKPhotoBrowser.shared
    }
    
    // MARK: from [BKPhotoProtocol]
    @discardableResult
    func fetchHybridBrowser(
        resources: [BKPhotoProtocol],
        holder: UIImage? = nil,
        holders: [BKPhotoProtocol] = [],
        pageIndex: Int = 0,
        shouldCache: Bool = true
    ) -> BKPhotoBrowser {
        if resources.count == 0 { return BKPhotoBrowser.shared }
        
        let bkPhotos = BKPhotoBrowser.shared.handle(
            resources,
            holder: holder,
            holders: holders,
            shouldCache: shouldCache
        )
        
        let browser = SKPhotoBrowser(photos: bkPhotos)
        browser.initializePageIndex(pageIndex)
        BKPhotoBrowser.shared.browser = browser
        return BKPhotoBrowser.shared
    }
    
    // MARK: from URLs
    @discardableResult
    func fetchUrlsBrowser(
        _ urls: [String],
        holder: UIImage? = nil,
        holders: [BKPhotoProtocol] = [],
        pageIndex: Int = 0,
        shouldCache: Bool = true
    ) -> BKPhotoBrowser {
        if urls.count == 0 { return BKPhotoBrowser.shared }
        
        let bkPhotos = BKPhotoBrowser.shared.handle(
            urls,
            holder: holder,
            holders: holders,
            shouldCache: shouldCache
        )
        
        let browser = SKPhotoBrowser(photos: bkPhotos)
        browser.initializePageIndex(pageIndex)
        BKPhotoBrowser.shared.browser = browser
        return BKPhotoBrowser.shared
    }
    
    // MARK: from UIImages
    @discardableResult
    func fetchImagesBrowser(
        _ images: [UIImage?],
        pageIndex: Int = 0
    ) -> BKPhotoBrowser {
        if images.count == 0 { return BKPhotoBrowser.shared }
        
        var imgs = [SKPhoto]()
        let images = images.compactMap { $0 }
        images.forEach {
            imgs.append($0.fetchPhoto(holder: nil))
        }
        
        let browser = SKPhotoBrowser(photos: imgs)
        browser.initializePageIndex(pageIndex)
        BKPhotoBrowser.shared.browser = browser
        return BKPhotoBrowser.shared
    }
    
    func show(completion: (() -> Void)? = nil) {
        guard let browser = BKPhotoBrowser.shared.browser else { return }
        UIApplication.shared.keyWindow?.currentRootViewController?.present(browser, animated: true, completion: completion)
    }
}


// MARK: Convenience
extension BKPhotoBrowser {
    func showAssociateBrowser(
        originImage: UIImage,
        resources: [BKPhotoProtocol],
        animatedFromView: UIView,
        holder: UIImage? = nil,
        holders: [BKPhotoProtocol] = [],
        shouldCache: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        BKPhotoBrowser.shared.fetchAssociateBrowser(
            originImage: originImage,
            resources: resources,
            animatedFromView: animatedFromView,
            holder: holder,
            holders: holders,
            shouldCache: shouldCache
        ).show(completion: completion)
    }
    
    func showHybridBrowser(
        resources: [BKPhotoProtocol],
        holder: UIImage? = nil,
        holders: [BKPhotoProtocol] = [],
        pageIndex: Int = 0,
        shouldCache: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        BKPhotoBrowser.shared.fetchHybridBrowser(
            resources: resources,
            holder: holder,
            holders: holders,
            pageIndex: pageIndex,
            shouldCache: shouldCache
        ).show(completion: completion)
    }
    
    func showUrlsBrowser(
        _ urls: [String],
        pageIndex: Int = 0,
        shouldCache: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        BKPhotoBrowser.shared.fetchUrlsBrowser(
            urls,
            pageIndex: pageIndex,
            shouldCache: shouldCache
        ).show(completion: completion)
    }
    
    func showImagesBrowser(
        _ images: [UIImage?],
        pageIndex: Int = 0,
        completion: (() -> Void)? = nil
    ) {
        BKPhotoBrowser.shared.fetchImagesBrowser(
            images,
            pageIndex: pageIndex
        ).show(completion: completion)
    }
}

// MARK:- SYImageCache
fileprivate class SYImageCache: SKImageCacheable {
    func imageForKey(_ key: String) -> UIImage? {
        guard let image = BKPhotoBrowser.shared.imageCache.retrieveImageInMemoryCache(forKey: key)
            else {
                return BKPhotoBrowser.shared.imageCache.retrieveImageInDiskCache(forKey: key)
        }
        return image
    }
    func setImage(_ image: UIImage, forKey key: String) {
        BKPhotoBrowser.shared.imageCache.store(image, forKey: key)
    }
    func removeImageForKey(_ key: String) {
        BKPhotoBrowser.shared.imageCache.removeImage(forKey: key)
    }
    func removeAllImages() {
        BKPhotoBrowser.shared.imageCache.clearMemoryCache()
    }
}

// MARK:- BKPhotoProtocol
protocol BKPhotoProtocol {
    func fetchPhoto(holder: UIImage?) -> SKPhoto
}
extension UIImage: BKPhotoProtocol {
    func fetchPhoto(holder: UIImage?) -> SKPhoto {
        return .photoWithImage(self)
    }
}
extension String: BKPhotoProtocol {
    func fetchPhoto(holder: UIImage?) -> SKPhoto {
        return .photoWithImageURL(self, holder: holder)
    }
}
