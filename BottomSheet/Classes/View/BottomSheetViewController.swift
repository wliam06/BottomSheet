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

  private(set) var containerSize: SheetSize = .fixed(0)
  private(set) var actualContainerSize: SheetSize = .fixed(0)
  private(set) var orderedSheetSizes: [SheetSize] = [.fixed(0), .fullScreen]

  var forceClosed = false

  // MARK: - Initialized
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }

  convenience init(withController viewController: UIViewController,
                   sizes: [SheetSize] = []) {
    self.init(nibName: nil, bundle: nil)
    self.childViewController = viewController

    if sizes.count > 0 {
      self.setSizes(sizes)
    }

    self.modalPresentationStyle = .overFullScreen
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  // MARK: - Lifecycle
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    self.view.backgroundColor = .clear

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

    configureContainerView()

    configureChildViewController()

    // Setup dismiss view when tapped
    handleDismissView()

    // Setup gesture
    panGesture = InitialTouchPanGestureRecognizer(target: self, action: #selector(panned(_:)))
    panGesture.delegate = self
    self.view.addGestureRecognizer(panGesture)
  }

  // MARK: - Handle pan gesture when scroll
  public func handleScrollView(_ scrollView: UIScrollView) {
    scrollView.panGestureRecognizer.require(toFail: panGesture)
    self.childScrollView = scrollView
  }

  // MARK: - Set sizes
  private func setSizes(_ sizes: [SheetSize]) {
    guard sizes.count > 0 else { return }

    self.orderedSheetSizes = sizes.sorted(by: {self.viewHeight(forSize: $0) < self.viewHeight(forSize: $1) })
    self.resize(toSize: sizes[0], animated: false)
  }

  // MARK: - Resize
  private func resize(toSize size: SheetSize, animated: Bool = true) {
    if animated {
      UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut, animations: { [weak self] in
        guard let self = self, let constraint = self.containerHeightConstraint else { return }
        constraint.constant = self.viewHeight(forSize: size)
        self.view.layoutIfNeeded()
      }, completion: nil)
    } else {
      self.containerHeightConstraint?.constant = viewHeight(forSize: size)
    }

    self.containerSize = size
    self.actualContainerSize = size
  }

  private func configureContainerView() {
    self.view.addSubview(self.containerView)
    self.containerHeightConstraint.constant = viewHeight(forSize: self.containerSize)

    self.containerView.layer.masksToBounds = true
    self.containerView.backgroundColor = .clear
    self.containerView.transform = CGAffineTransform(translationX: 0, y: 100)

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
    case .halfScreen:
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

  @objc private func panned(_ gesture: UIPanGestureRecognizer) {
    let translation = gesture.translation(in: gesture.view?.superview)
    let velocity = (0.2 * gesture.velocity(in: self.view).y)

    let size = viewHeight(forSize: self.actualContainerSize)

    // First gesture track
    if gesture.state == .began {
      self.firstPanPoint = translation
      self.actualContainerSize = .fixed(self.containerView.frame.height)
    }

    let minHeight = min(size, viewHeight(forSize: self.orderedSheetSizes.first))
    let maxHeight = max(size, viewHeight(forSize: self.orderedSheetSizes.last))

    var newHeight = max(0, viewHeight(forSize: self.actualContainerSize) +
      (self.firstPanPoint.y - translation.y))

    var offset: CGFloat = 0

    if newHeight < minHeight {
      offset = minHeight - newHeight
      newHeight = minHeight
    }

    if newHeight > maxHeight {
      newHeight = maxHeight
    }

    // Start tracking
    if gesture.state == .cancelled || gesture.state == .failed {
      UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
        self.containerView.transform = CGAffineTransform.identity
        self.containerHeightConstraint.constant = self.viewHeight(forSize: self.containerSize)
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
        newSize = self.orderedSheetSizes.last ?? self.containerSize

        for size in self.orderedSheetSizes.reversed() {
          if finalHeight < self.viewHeight(forSize: size) {
            newSize = size
          } else {
            break
          }
        }
      } else {
        newSize = self.orderedSheetSizes.first ?? self.containerSize

        for size in self.orderedSheetSizes {
          if finalHeight > self.viewHeight(forSize: size) {
            newSize = size
          } else {
            break
          }
        }
      }

      self.containerSize = newSize

      UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
        self.containerView.transform = CGAffineTransform.identity
        self.containerHeightConstraint.constant = self.viewHeight(forSize: newSize)
        self.view.layoutIfNeeded()
      }, completion: { [weak self] complete in
        guard let self = self else { return }
        self.actualContainerSize = .fixed(self.containerView.frame.height)
      })
    } else {
      containerHeightConstraint.constant = newHeight

      if offset > 0 && dismissOnPan {
        self.containerView.transform = CGAffineTransform(translationX: 0, y: offset)
      } else {
        self.containerView.transform = CGAffineTransform.identity
      }
    }
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
      let containerHeight = viewHeight(forSize: self.containerSize)
      return viewHeight(forSize: self.orderedSheetSizes.last) > containerHeight &&
        containerHeight < viewHeight(forSize: .fullScreen)
    } else {
      return true
    }
  }
}
