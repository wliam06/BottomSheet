//
//  CustomSearchBar.swift
//  BottomSheet
//
//  Created by William_itmi on 04/09/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

class CustomSearchBar: UISearchBar {
  @IBInspectable var leftImage: UIImage? {
    didSet {
      configureSearchBarIcon()
    }
  }
  
  @IBInspectable var rightImage: UIImage? {
    didSet {
      configureSearchBarIcon()
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    updateSearchBar()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    updateSearchBar()
  }
  
  private func updateSearchBar() {
    self.layer.cornerRadius = 5
    self.layer.borderWidth = 2
    self.layer.borderColor = UIColor.lightGray.cgColor
    self.clipsToBounds = true
    self.setPositionAdjustment(UIOffset(horizontal: 0, vertical: 0), for: .search)
    self.placeholder = NSLocalizedString("Search Location", comment: "")
    
    self.setSearchFieldBackgroundImage(.imageWithColor(color: .clear,
                                                       size: CGSize(width: 30,
                                                                    height: 30)), for: .normal)
    // Set text position
    self.searchTextPositionAdjustment = UIOffset(horizontal: 20, vertical: 0)
    
    // Set cursor color
    self.tintColor = .green
    UITextField.appearance(whenContainedInInstancesOf: [type(of: self)]).tintColor = .green
    
    self.isUserInteractionEnabled = true
  }
  
  override func searchFieldBackgroundImage(for state: UIControl.State) -> UIImage? {
    return .imageWithColor(color: .clear, size: CGSize(width: 30, height: 30))
  }
  
  private func configureSearchBarIcon() {
    let searchTextField: UITextField = self.subviews[0].subviews.last as! UITextField
    let leftImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
    let rightImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 16, height: 16))
    
    leftImageView.image = leftImage
    leftImageView.contentMode = .scaleAspectFit
    searchTextField.leftView = leftImageView
    
    rightImageView.image = rightImage
    rightImageView.contentMode = .scaleAspectFit
    searchTextField.rightView = rightImageView
    searchTextField.rightViewMode = .always
    searchTextField.clearButtonMode = .never
    
    self.layoutIfNeeded()
    self.layoutSubviews()
  }
}
