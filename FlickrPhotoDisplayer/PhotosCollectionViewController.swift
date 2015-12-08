//
//  PhotosCollectionViewController.swift
//  FlickrPhotoDisplayer
//
//  Created by Harry on 4/12/2015.
//  Copyright © 2015 Snaptee. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class PhotosCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    var photos = [Photo]() {
        didSet {
            beginDownloadImages()
        }
    }

    var thumbnailImages = [UIImage]()

    // REVIEW: Please group the methods in a certain area

    func beginDownloadImages() {
        // REVIEW: If no change in var, use let or empty it in this case.
        for var photoInfo in photos {
            downloadImage(photoInfo.thumbnailURL, usingBlock: { (image) -> Void in
                self.thumbnailImages.append(image!)
                self.collectionView?.reloadData()
            })
        }
    }

    func getDataFromUrl(url:NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            completion(data: data, response: response, error: error)
            }.resume()
    }

    func downloadImage(url: NSURL, usingBlock: (UIImage?) -> Void) {
        getDataFromUrl(url) { (data, response, error)  in
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                guard let data = data where error == nil else { return }
                usingBlock(UIImage(data: data))
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return thumbnailImages.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCollectionViewCell", forIndexPath: indexPath) as! FlickrPhotoCollectionViewCell

        // Configure the cell
        cell.imageView.image = thumbnailImages[indexPath.row]

        return cell
    }

    // MARK: UICollectionViewDelegateFlowLayout


    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let image = thumbnailImages[indexPath.row]
        return CGSize(width: image.size.width, height: image.size.height)
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        // REVIEW: No need to write `.0`, it will be auto translate into CGFloat.
        return UIEdgeInsets(top: 20.0, left: 10.0, bottom: 20.0, right: 10.0)
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.

        if segue.identifier == "ShowImageSegue" {
            // REVIEW: You can use `segue.destinationViewController as? ImageViewController` instead
            //         of using `isKindOfClass()`
            if segue.destinationViewController.isKindOfClass(ImageViewController) {
                let imageVC = segue.destinationViewController as! ImageViewController
                let index = collectionView?.indexPathForCell(sender as! FlickrPhotoCollectionViewCell)?.row
                imageVC.title = "\(thumbnailImages.count) Photos"
                downloadImage(photos[index!].imageURL, usingBlock: { (image) -> Void in
                    imageVC.image = image!
                })
            }
        }

    }


}
