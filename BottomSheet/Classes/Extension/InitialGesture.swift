//
//  InitialGesture.swift
//  BottomSheet
//
//  Created by William_itmi on 09/09/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

class InitialTouchPanGestureRecognizer: UIPanGestureRecognizer {
  var initialTouchLocation: CGPoint?
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
    super.touchesBegan(touches, with: event)
    initialTouchLocation = touches.first?.location(in: view)
  }
}
