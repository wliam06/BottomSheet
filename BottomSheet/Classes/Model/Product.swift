//
//  Product.swift
//  BottomSheet
//
//  Created by William_itmi on 05/09/19.
//  Copyright © 2019 William. All rights reserved.
//

import Foundation

struct Product {
  let productName: String
}

extension Product: Mapping {
  static func mapToModel(result: Any) -> Result<Product, ErrorType> {
    guard let dict = result as? [String: Any],
      let name = dict["product_name"] as? String else {
      return .Failed(.Parser)
    }

    return .Success(Product(productName: name))
  }
}
