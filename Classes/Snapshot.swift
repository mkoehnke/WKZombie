//
//  Snapshot.swift
//  WKZombie
//
//  Created by Mathias Köhnke on 10/05/16.
//  Copyright © 2016 Mathias Köhnke. All rights reserved.
//

#if os(iOS)
import UIKit

public typealias SnapshotHandler = Snapshot -> Void
public typealias SnapshotImage = UIImage

public class Snapshot {
    public let page : NSURL?
    public let file : NSURL
    public lazy var image : UIImage? = {
        if let path = self.file.path {
            return UIImage(contentsOfFile: path)
        }
        return nil
    }()
    
    internal init(file: NSURL, page: NSURL? = nil) {
        self.page = page
        self.file = file
    }
}
#endif