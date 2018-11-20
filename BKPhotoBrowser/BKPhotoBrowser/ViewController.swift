//
//  ViewController.swift
//  BKPhotoBrowser
//
//  Created by LinXunFeng on 2018/11/20.
//  Copyright © 2018 LinXunFeng. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
//        BKPhotoBrowser.shared.fetchImagesBrowser([UIImage(named: "lxf")]).show()
//
//        BKPhotoBrowser.shared.showImagesBrowser([UIImage(named: "lxf")])
        
        let resources: [BKPhotoProtocol] = [
            "https://b-ssl.duitang.com/uploads/item/201502/26/20150226210346_nGRKM.jpeg",
            UIImage(named: "pic1")!,
            "https://b-ssl.duitang.com/uploads/item/201803/20/20180320215828_kxwrj.jpg",
            UIImage(named: "pic2")!,
            "https://b-ssl.duitang.com/uploads/item/201602/21/20160221153608_cXFzY.png",
            UIImage(named: "pic3")!
        ]
        
        BKPhotoBrowser.shared.showHybridBrowser(resources: resources)
    }
}

