//
//  ViewExtensions.swift
//  BottomSheet
//
//  Created by William_itmi on 05/09/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

extension UIView {
  @nonobjc func addSubview(firstView: UIView, secondView: UIView) {
    [firstView, secondView].forEach { addSubview($0) }
  }
}
