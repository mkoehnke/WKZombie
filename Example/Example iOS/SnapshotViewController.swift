//
//  ScreenshotViewController.swift
//  Example
//
//  Created by Mathias Köhnke on 20/05/16.
//  Copyright © 2016 Mathias Köhnke. All rights reserved.
//

import UIKit
import WKZombie

class SnapshotCell : UICollectionViewCell {
    static let cellIdentifier = "snapshotCell"
    @IBOutlet weak var imageView : UIImageView!
}

class SnapshotViewController: UICollectionViewController {
    
    var snapshots : [Snapshot]?
    
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return snapshots?.count ?? 0
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(SnapshotCell.cellIdentifier, forIndexPath: indexPath)
        if let cell = cell as? SnapshotCell {
            cell.imageView.image = snapshots?[indexPath.row].image
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width = (view.bounds.size.width / 2) - 1
        let height = (view.bounds.size.height * width) / view.bounds.size.width
        return CGSize(width: width, height: height)
    }
}

extension SnapshotViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1.0
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 2.0
    }
}