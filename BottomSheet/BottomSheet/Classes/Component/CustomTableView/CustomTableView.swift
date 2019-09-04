//
//  TableView.swift
//  BottomSheet
//
//  Created by William_itmi on 04/09/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

class CustomTableView: UIView {
  @IBOutlet var contentView: UIView!
  @IBOutlet weak var handlerView: UIView!
  @IBOutlet weak var vStackView: UIStackView!
  @IBOutlet weak var headerContainerView: UIView!
  @IBOutlet weak var tableView: UITableView!

  override init(frame: CGRect) {
    super.init(frame: frame)

    loadNib()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)

    loadNib()
  }

  private func loadNib() {
    Bundle.main.loadNibNamed(String(describing: CustomTableView.self), owner: self, options: nil)

    guard let content = contentView else { return }
    content.frame = self.bounds
    content.autoresizingMask = [.flexibleWidth, .flexibleHeight]

    addSubview(content)

    configureLayout()
  }

  private func configureLayout() {
    
  }
}
