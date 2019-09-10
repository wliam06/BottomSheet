//
//  FirstPageViewController.swift
//  BottomSheet
//
//  Created by William_itmi on 04/09/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

class FirstPageViewController: UIViewController {
  // MARK: - Lifecycle
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    self.navigationController?.setNavigationBarHidden(true, animated: true)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
  }

  // MARK: - Action
  @IBAction func showMeHeaderDidTapped(_ sender: Any) {
    let customTableView = CustomTableViewController(isShowHeader: true)
    let bottomSheet = BottomSheetViewController(withController: customTableView, sizes: [.fullScreen, .lowScreen])
    self.navigationController?.present(bottomSheet, animated: true, completion: nil)
  }

  @IBAction func showMeTableDidTapped(_ sender: Any) {
    let customTableView = CustomTableViewController(isShowHeader: false)
    let bottomSheet = BottomSheetViewController(withController: customTableView, sizes: [.lowScreen, .halfScreen])
    self.navigationController?.present(bottomSheet, animated: true, completion: nil)
  }
  
  @IBAction func forceClosed(_ sender: Any) {
    let customTableView = CustomTableViewController(isShowHeader: true)
    let bottomSheet = BottomSheetViewController(withController: customTableView, sizes: [.halfScreen, .lowScreen])
    bottomSheet.forceClosed = true
    self.navigationController?.present(bottomSheet, animated: true, completion: nil)
  }
}
