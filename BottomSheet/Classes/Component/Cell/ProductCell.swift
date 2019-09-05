//
//  ProductCell.swift
//  BottomSheet
//
//  Created by William_itmi on 05/09/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

class ProductCell: UITableViewCell {
  
  static func reuseIdentifier() -> String {
    return String(describing: ProductCell.self)
  }

  override func awakeFromNib() {
      super.awakeFromNib()
      // Initialization code
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
      super.setSelected(selected, animated: animated)

      // Configure the view for the selected state
  }
  
}
