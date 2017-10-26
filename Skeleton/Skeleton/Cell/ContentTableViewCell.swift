//
//  ContentTableViewCell.swift
//  Word Share
//
//  Created by Best Peers on 24/10/17.
//  Copyright © 2017 www.Systango.Skeleton. All rights reserved.
//

import UIKit

class ContentTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateContent(title:String, subtitle:String = "", searchText:String) {
        if title.contains(searchText){
            makeMatchingPartBold(searchText: searchText, title: title)
        }
        else{
            self.titleLabel.text = title
        }
        
        if self.subtitleLabel != nil{
            self.subtitleLabel.text = subtitle
        }
    }
    
    func updateTranslationContent(title:Any?) {
        
        self.titleLabel.text = title as? String
        
        if self.subtitleLabel != nil{
            self.subtitleLabel.text = ""
        }
    }
    
    func makeMatchingPartBold(searchText: String, title:String?) {
        
        // check label text & search text
        guard
            let labelText = title
            else {
                return
        }
        
        // bold attribute
        let boldAttr = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: titleLabel.font.pointSize)]
        
        // check if label text contains search text
        if let matchRange: Range = labelText.lowercased().range(of: searchText.lowercased()) {
            
            // get range start/length because NSMutableAttributedString.setAttributes() needs NSRange not Range<String.Index>
            let matchRangeStart: Int = labelText.distance(from: labelText.startIndex, to: matchRange.lowerBound)
            let matchRangeEnd: Int = labelText.distance(from: labelText.startIndex, to: matchRange.upperBound)
            let matchRangeLength: Int = matchRangeEnd - matchRangeStart
            
            // create mutable attributed string & bold matching part
            let newLabelText = NSMutableAttributedString(string: labelText)
            newLabelText.setAttributes(boldAttr, range: NSMakeRange(matchRangeStart, matchRangeLength))
            
            // set label attributed text
            titleLabel.attributedText = newLabelText
        }
    }

}
