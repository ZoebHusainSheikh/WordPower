//
//  WordCollectionViewCell.swift
//  Word Share
//
//  Created by Best Peers on 18/10/17.
//  Copyright © 2017 www.Systango.Skeleton. All rights reserved.
//

import UIKit

class WordCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var backgroungTabImageView: UIImageView!
    @IBOutlet weak var textLabel: UILabel!
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
