//
//  FirstPageViewController.swift
//  BottomSheet
//
//  Created by William_itmi on 04/09/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

class FirstPageViewController: UIViewController {
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)

      self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    @IBAction func animateButtonDidTapped(_ sender: Any) {
      // Show bottom sheet page
    }
}
