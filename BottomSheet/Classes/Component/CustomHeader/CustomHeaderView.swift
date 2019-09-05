//
//  CustomHeaderView.swift
//  BottomSheet
//
//  Created by William_itmi on 04/09/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

class CustomHeaderView: UIView {
  @IBOutlet var contentView: UIView!
  @IBOutlet weak var headerLabel: UILabel!
  @IBOutlet weak var searchBar: CustomSearchBar!

  override init(frame: CGRect) {
    super.init(frame: frame)

    loadNib()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)

    loadNib()
  }

  private func loadNib() {
    Bundle.main.loadNibNamed(String(describing: CustomHeaderView.self), owner: self, options: nil)

    guard let content = contentView else { return }
    content.frame = self.bounds
    content.autoresizingMask = [.flexibleWidth, .flexibleHeight]

    addSubview(content)
  }
}
