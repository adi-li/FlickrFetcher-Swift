//
//  ImageViewController.swift
//  FlickrPhotoDisplayer
//
//  Created by Harry on 3/12/2015.
//  Copyright © 2015 Snaptee. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    var image = UIImage.init()


    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.image = image
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
