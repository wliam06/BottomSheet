//
//  BottomSheetViewController.swift
//  BottomSheet
//
//  Created by William_itmi on 04/09/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

enum SheetSize {
  case fixed(CGFloat)
  case fullScreen
  case halfScreen
}

class BottomSheetViewController: UIViewController {
  public private(set) var childViewController: UIViewController!

  override func viewDidLoad() {
    super.viewDidLoad()
  }

  
}
