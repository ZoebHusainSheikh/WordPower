//
//  WordCollectionViewCell.swift
//  Word Share
//
//  Created by Best Peers on 18/10/17.
//  Copyright © 2017 www.Systango.Skeleton. All rights reserved.
//

import UIKit

class WordCollectionViewCell: UICollectionViewCell {
    var textLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        textLabel = UILabel(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        textLabel.font = UIFont.systemFont(ofSize: UIFont.labelFontSize)
        textLabel.textAlignment = .center
        textLabel.textColor = UIColor.lightGray
        contentView.addSubview(textLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
