//
//  BottomSheetProtocol.swift
//  BottomSheet
//
//  Created by William_itmi on 05/09/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

protocol BottomSheetProtocol: class {}

extension BottomSheetProtocol where Self: UIViewController {
  var bottomSheetVC: BottomSheetViewController? {
    var parent = self.parent
    while let currentParent = parent {
      if let bottomSheetVC = currentParent as? BottomSheetViewController {
        return bottomSheetVC
      } else {
        parent = currentParent.parent
      }
    }

    return nil
  }
}
