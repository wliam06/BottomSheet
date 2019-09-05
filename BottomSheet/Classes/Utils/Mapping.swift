//
//  Mapping.swift
//  BottomSheet
//
//  Created by William_itmi on 05/09/19.
//  Copyright © 2019 William. All rights reserved.
//

import Foundation

// Error Handler
enum ErrorType: Error {
  case Parser
}

// Result Acceptable
enum Result<T, E: Error> {
  case Success(T)
  case Failed(E)
}

protocol Mapping {
  static func mapToModel(result: Any) -> Result<Self, ErrorType>
}

// MARK: - Mapping
func parse<T: Mapping>(data: Data, completion: (Result<[T], ErrorType>) -> Void) {
  let decodedData: Result<Any, ErrorType> = decodeData(data: data)

  switch decodedData {
  case .Success(let result):
    guard let arr = result as? [Any] else { completion(.Failed(.Parser))
      return
    }
    let result: Result<[T], ErrorType> = arrayToModel(objects: arr)
    completion(result)
  case .Failed:
    completion(.Failed(.Parser))
  }
}

// MARK: Convert array to model
private func arrayToModel<T: Mapping>(objects: [Any]) -> Result<[T], ErrorType> {
  var arr: [T] = []

  // Check model type
  for object in objects {
    guard case .Success(let model) = T.mapToModel(result: object) else { continue }
    arr.append(model)
  }

  return .Success(arr)
}

// MARK: - Decode data type
private func decodeData(data: Data) -> Result<Any, ErrorType> {
  do {
    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
    return .Success(json)
  } catch {
    return .Failed(.Parser)
  }
}
