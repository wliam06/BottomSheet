//
//  OverlayView.swift
//  BottomSheet
//
//  Created by William_itmi on 04/09/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

class OverlayView: UIView {
  override init(frame: CGRect) {
    super.init(frame: frame)

    configureLayout()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func configureLayout() {
    self.backgroundColor = UIColor.black
    self.alpha = 0.5
  }
}
