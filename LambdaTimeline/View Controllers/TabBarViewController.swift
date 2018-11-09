//
//  TabBarViewController.swift
//  LambdaTimeline
//
//  Created by Moin Uddin on 11/8/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

protocol PostControllerDelegate {
    var postController: PostController! {get set}
}

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        passPostControllertoViews()
    }
    
    
    private func passPostControllertoViews() {
        for childVC in children {
            for vc in childVC.children {
                if var vc = vc as? PostControllerDelegate {
                    vc.postController = postController
                }
            }
            if let childVC = childVC as? MapViewController {
                childVC.postController = postController
            }
        }
    }
    
    let postController = PostController()

}
