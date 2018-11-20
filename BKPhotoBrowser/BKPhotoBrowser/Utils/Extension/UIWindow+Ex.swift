//
//  UIWindow+Ex.swift
//  BKPhotoBrowser
//
//  Created by LinXunFeng on 2018/11/20.
//  Copyright © 2018 LinXunFeng. All rights reserved.
//

import UIKit

extension UIWindow {
    var currentRootViewController : UIViewController? {
        var vc = self.rootViewController
        while ((vc?.presentedViewController) != nil) {
            vc = vc?.presentedViewController
            if vc!.isKind(of: UINavigationController.classForCoder()) {
                vc = (vc as! UINavigationController).visibleViewController
            } else if vc!.isKind(of: UITabBarController.classForCoder()) {
                vc = (vc as! UITabBarController).selectedViewController
            }
        }
        return vc
    }
}
