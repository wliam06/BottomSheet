//
//  TableView.swift
//  BottomSheet
//
//  Created by William_itmi on 04/09/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

class CustomTableViewController: UIViewController {
  @IBOutlet weak var handlerView: UIView!
  @IBOutlet weak var vStackView: UIStackView!
  @IBOutlet weak var headerContainerView: CustomHeaderView!
  @IBOutlet weak var tableView: UITableView!

  var isShowHeader = false

  // MARK: - Initialize
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  convenience init(isShowHeader: Bool) {
    self.init()
    self.isShowHeader = isShowHeader
    loadViewIfNeeded()
  }

  // MARK: Lifecycle
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    // Show or hide header
    headerContainerView.isHidden = !isShowHeader
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    tableView.register(UINib(nibName: ProductCell.reuseIdentifier(), bundle: nil),
                       forCellReuseIdentifier: ProductCell.reuseIdentifier())
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  }
}

extension CustomTableViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 30
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: ProductCell.reuseIdentifier(),
                                             for: indexPath)

    cell.textLabel?.text = "Item \(indexPath.row)"
    return cell
  }

}
