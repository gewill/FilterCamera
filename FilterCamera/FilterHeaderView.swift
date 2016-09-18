//
//  FilterHeaderView.swift
//  FilterCamera
//
//  Created by Will on 9/10/16.
//
//

import UIKit

@objc protocol FilterHeaderViewDelegate: class {
    optional func filterHeaderViewDidClickDoneButton(header: UICollectionReusableView, doneButton: UIButton)
}

class FilterHeaderView: UICollectionReusableView {
    
    @IBOutlet var doneButton: UIButton!
    
    var delegate: FilterHeaderViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    // MARK: - response methods
    
    @IBAction func doneButtonClick(sender: UIButton) {
        delegate?.filterHeaderViewDidClickDoneButton?(self, doneButton: sender)
    }
    
}
