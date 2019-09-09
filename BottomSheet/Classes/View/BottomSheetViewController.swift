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
  case semiFullScreen
  case lowScreen
}

class BottomSheetViewController: UIViewController {
  public private(set) var childViewController: UIViewController!

  @IBOutlet weak var containerView: UIView!
  @IBOutlet weak var dismissAreaView: UIView!
  @IBOutlet weak var containerHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var containerBottomConstraint: NSLayoutConstraint!

  private weak var childScrollView: UIScrollView?
  private var panGesture: InitialTouchPanGestureRecognizer!

  private var firstPanPoint: CGPoint = CGPoint.zero

  /// If true, tapping on the overlay above the sheet will dismiss the sheet view controller
  public var dismissOnBackgroundTap: Bool = true

  /// If true, sheet may be dismissed by panning down
  public var dismissOnPan: Bool = true

  // Set overlay color
  private var overlayColor: UIColor = UIColor(white: 0, alpha: 0.7) {
    didSet {
      if self.isViewLoaded && self.view.window != nil {
        self.view.backgroundColor = self.overlayColor
      }
    }
  }

  private var safeAreaInsets: UIEdgeInsets {
    var insets = UIEdgeInsets.zero
    if #available(iOS 11.0, *) {
      insets = UIApplication.shared.keyWindow?.safeAreaInsets ?? insets
    }

    insets.top = max(insets.top, 20)
    return insets
  }

  private(set) var sheetSize: SheetSize = .semiFullScreen
  private(set) var actualContainerSize: SheetSize = .fixed(0)

  var forceClosed = false

  // MARK: - Initialized
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }

  convenience init(withController viewController: UIViewController,
                   sizes: SheetSize) {
    self.init(nibName: nil, bundle: nil)

    self.childViewController = viewController
    self.sheetSize = sizes

    self.modalPresentationStyle = .overFullScreen
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  // MARK: - Lifecycle
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    UIView.animate(withDuration: 0.3, delay: 0,
                   options: .curveEaseOut,
                   animations: { [weak self] in
                    guard let self = self else { return }
                    self.view.backgroundColor = self.overlayColor
                    self.containerView.transform = CGAffineTransform.identity
                    self.actualContainerSize = .fixed(self.containerView.frame.height)
    }, completion: nil)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.view.backgroundColor = .clear
    configureContainerView()

    configureChildViewController()

    // Setup dismiss view when tapped
    handleDismissView()

    // Setup gesture
    panGesture = InitialTouchPanGestureRecognizer(target: self, action: #selector(panned(_:)))
    panGesture.delegate = self
    self.view.addGestureRecognizer(panGesture)
  }

  public func handleScrollView(_ scrollView: UIScrollView) {
    scrollView.panGestureRecognizer.require(toFail: panGesture)
    self.childScrollView = scrollView
  }

  private func configureContainerView() {
    self.view.addSubview(self.containerView)
    self.containerHeightConstraint.constant = viewHeight(forSize: self.sheetSize)

    self.containerView.layer.masksToBounds = true
    self.containerView.backgroundColor = .clear
    self.containerView.transform = CGAffineTransform(translationX: 0, y: UIScreen.main.bounds.height)

    self.view.addSubview(UIView(frame: .zero))
  }

  private func configureChildViewController() {
    self.childViewController.didMove(toParent: self)
    self.addChild(self.childViewController)

    self.containerView.addSubview(self.childViewController.view)

    self.childViewController.view.layer.masksToBounds = true
    self.childViewController.didMove(toParent: self)
  }

  private func viewHeight(forSize size: SheetSize?) -> CGFloat {
    guard let size = size else { return 0 }

    switch size {
    case .fixed(let height):
      return height
    case .fullScreen:
      let insets = self.safeAreaInsets
      return UIScreen.main.bounds.height - insets.top
    case .semiFullScreen:
      let insets = self.safeAreaInsets
      return UIScreen.main.bounds.height - insets.top - 120
    case .lowScreen:
      return (UIScreen.main.bounds.height) / 2 + 20
    }
  }

  private func handleDismissView() {
    self.view.addSubview(firstView: dismissAreaView, secondView: containerView)
    dismissAreaView.backgroundColor = .clear
    dismissAreaView.isUserInteractionEnabled = true
    
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissViewTapped(completion:)))
    dismissAreaView.addGestureRecognizer(tapGesture)
  }

  @objc private func panned(_ gesture: UIPanGestureRecognizer) {
    let translation = gesture.translation(in: gesture.view?.superview)
    let velocity = (0.2 * gesture.velocity(in: self.view).y)
//    let y = gesture.view?.superview?.frame.minY ?? 0

    let size = viewHeight(forSize: self.actualContainerSize)

    if gesture.state == .began {
      self.firstPanPoint = translation
      self.actualContainerSize = .fixed(self.containerView.frame.height)
    }

    let minHeight = min(size, viewHeight(forSize: .lowScreen))
    let maxHeight = max(size, viewHeight(forSize: .fullScreen))

    var newHeight = max(0, viewHeight(forSize: self.actualContainerSize) +
      (self.firstPanPoint.y - translation.y))

    var offset: CGFloat = 0

    if newHeight < minHeight {
      offset = minHeight - newHeight
      debugPrint("offset", offset)
      newHeight = minHeight
    }

    if newHeight > maxHeight {
      newHeight = maxHeight
    }

//    // Check gesture Y position
//    if translation.y >= 0 {
//      // Scroll Down
//
//      // Check if sheet size is Low screen type
//      UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseOut, animations: { [weak self] in
//        guard let self = self else { return }
//        self.containerView.transform = CGAffineTransform.identity
//        self.containerHeightConstraint.constant = newHeight
//        }, completion: nil)
//    } else {
//      // Scroll Top
//
//      // Check sheet size
//      if size == viewHeight(forSize: .lowScreen) {
//        debugPrint("Low screen", (y + translation.y))
//        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseOut, animations: { [weak self] in
//          guard let self = self else { return }
//          self.containerView.transform = CGAffineTransform.identity
//          self.containerHeightConstraint.constant = newHeight
//        }, completion: nil)
//      } else {
//        debugPrint("Bigger screen")
//      }
//    }

    // Start tracking
    if gesture.state == .cancelled || gesture.state == .failed {
      UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
        self.containerView.transform = CGAffineTransform.identity
        self.containerHeightConstraint.constant = self.viewHeight(forSize: self.sheetSize)
      }, completion: nil)
    } else if gesture.state == .ended {
      var finalHeight = newHeight - offset - velocity
      if velocity > 500 {
        finalHeight = -1
      }

      let animationDuration = TimeInterval(abs(velocity*0.0002) + 0.2)

      guard finalHeight >= (minHeight / 2) || !dismissOnPan else {
        // Dismiss
        UIView.animate(withDuration: animationDuration,
                       delay: 0,
                       options: .curveEaseOut,
                       animations: { [weak self] in
                        self?.containerView.transform = CGAffineTransform(translationX: 0,
                                                                          y: self?.containerView.frame.height ?? 0)
                        self?.view.backgroundColor = .clear
          }, completion: { [weak self] complete in
            self?.dismiss(animated: false, completion: nil)
        })
        
        return
      }

      var newSize: SheetSize = .fixed(0)

      if translation.y < 0 {
        // new size
        if finalHeight < viewHeight(forSize: .semiFullScreen) {
          debugPrint("BIGGER")
//          newSize = viewHeight(forSize: .semiFullScreen)
          newSize = .semiFullScreen
        } else {
          return
        }
      } else {
        // small size or dismiss
        if finalHeight > viewHeight(forSize: .lowScreen) {
          // Resize into smaller
          debugPrint("SMALLER")
//          newSize = viewHeight(forSize: .lowScreen)
          newSize = .lowScreen
        }

        // force to close
        if forceClosed && finalHeight < viewHeight(forSize: .semiFullScreen) {
          // force to dismiss not into smaller size
          debugPrint("ALREADY CLOSED")
        }

        else {
          return
        }
      }

      self.sheetSize = newSize

      UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
        self.containerView.transform = CGAffineTransform.identity
        self.containerHeightConstraint.constant = self.viewHeight(forSize: newSize)
        self.view.layoutIfNeeded()
      }, completion: { [weak self] complete in
        guard let self = self else { return }
        self.actualContainerSize = .fixed(self.containerView.frame.height)
      })

    } else {
      if offset > 0 && dismissOnPan {
        self.containerView.transform = CGAffineTransform(translationX: 0, y: offset)
      } else {
        self.containerView.transform = CGAffineTransform.identity
      }
    }

    // 1
//    if gesture.state == .began {
//      self.firstPanPoint = translation
//      self.actualContainerSize = .fixed(self.containerView.frame.height)
//    }
//
//    let minHeight = min(size, viewHeight(forSize: .lowScreen))
//    let maxHeight = max(size, viewHeight(forSize: .semiFullScreen))
//
//    var newHeight = max(0, viewHeight(forSize: self.actualContainerSize) + (self.firstPanPoint.y - translation.y))
//    var offset: CGFloat = 0
//
//    if newHeight < minHeight {
//      offset = minHeight - newHeight
//      newHeight = minHeight
//    }
//
//    if newHeight > maxHeight {
//      newHeight = maxHeight
//    }
//
//    if gesture.state == .cancelled || gesture.state == .failed {
//      UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseOut, animations: {
//        self.containerView.transform = CGAffineTransform.identity
//        self.containerHeightConstraint.constant = self.viewHeight(forSize: self.sheetSize)
//      }, completion: nil)
//    } else if gesture.state == .ended {
//      var finalHeight = newHeight - offset - velocity
//      if velocity > 500 {
//        finalHeight = -1
//      }
//
//      let animationDuration = TimeInterval(abs(velocity*0.0002) + 0.2)
//
//      guard finalHeight >= (minHeight / 2) || !dismissOnPan else {
//        // Dismiss
//        UIView.animate(withDuration: animationDuration,
//                       delay: 0,
//                       options: .curveEaseOut,
//                       animations: { [weak self] in
//          self?.containerView.transform = CGAffineTransform(translationX: 0,
//                                                            y: self?.containerView.frame.height ?? 0)
//          self?.view.backgroundColor = .clear
//        }, completion: { [weak self] complete in
//          self?.dismiss(animated: false, completion: nil)
//        })
//
//        return
//      }
//
//      var newSize: CGFloat = 0
//
//      if translation.y < 0 {
//        // new size
//        if finalHeight < viewHeight(forSize: .semiFullScreen) {
//          debugPrint("BIGGER")
//          newSize = viewHeight(forSize: .semiFullScreen)
//        } else {
//          return
//        }
//      } else {
//        // small size or dismiss
//        if finalHeight > viewHeight(forSize: .lowScreen) {
//          // Resize into smaller
//          debugPrint("SMALLER")
//          newSize = viewHeight(forSize: .lowScreen)
//        }
//
//        // force to close
//        if forceClosed && finalHeight < viewHeight(forSize: .semiFullScreen) {
//          // force to dismiss not into smaller size
//          debugPrint("ALREADY CLOSED")
//        }
//
//        return
//      }
//
//      self.containerView.frame.size.height = newSize
//
//      UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseOut, animations: {
//        self.containerView.transform = CGAffineTransform.identity
//        self.containerHeightConstraint.constant = newSize
//        self.view.layoutIfNeeded()
//      }, completion: { [weak self] complete in
//        guard let self = self else { return }
//        self.actualContainerSize = .fixed(self.containerView.frame.height)
//      })
//    } else {
//      if offset > 0 && dismissOnPan {
//        self.containerView.transform = CGAffineTransform(translationX: 0, y: offset)
//      } else {
//        self.containerView.transform = CGAffineTransform.identity
//      }
//    }
    
  }

  @objc private func dismissViewTapped(completion: (() -> Void)? = nil) {
    guard dismissOnBackgroundTap else { return }

    // Close bottom sheet
    UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseIn], animations: { [weak self] in
      self?.containerView.transform = CGAffineTransform(translationX: 0, y: self?.containerView.frame.height ?? 0)
      self?.view.backgroundColor = .clear
      }, completion: { [weak self] complete in
        self?.dismiss(animated: true, completion: nil)
    })
  }
}


extension BottomSheetViewController: UIGestureRecognizerDelegate {
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
    guard let view = touch.view else { return true }
    // Allowing gesture recognition on a button seems to prevent it's events from firing properly sometimes
    return !(view is UIControl)
  }

  public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    let panGestureRecognizer1 = gestureRecognizer as? InitialTouchPanGestureRecognizer
    let childScrollViews = self.childScrollView
    let points = panGestureRecognizer1?.initialTouchLocation

    guard let panGestureRecognizer = gestureRecognizer as? InitialTouchPanGestureRecognizer,
      let childScrollView = self.childScrollView,
      let point = panGestureRecognizer.initialTouchLocation else { return true }
    
    let pointInChildScrollView = self.view.convert(point, to: childScrollView).y - childScrollView.contentOffset.y
    
    let velocity = panGestureRecognizer.velocity(in: panGestureRecognizer.view?.superview)
    guard pointInChildScrollView > 0, pointInChildScrollView < childScrollView.bounds.height else {
//      if keyboardHeight > 0 {
//        childScrollView.endEditing(true)
//      }
      return true
    }
    
    guard abs(velocity.y) > abs(velocity.x),
      childScrollView.contentOffset.y == 0 else {
        return false }

    if velocity.y < 0 {
      let containerHeight = viewHeight(forSize: .fullScreen)
      debugPrint("sheet sizes", viewHeight(forSize: self.sheetSize))
      return viewHeight(forSize: .fullScreen) > viewHeight(forSize: self.sheetSize) &&
        viewHeight(forSize: self.sheetSize) < viewHeight(forSize: .fullScreen)
    } else {
      return true
    }
  }
}
