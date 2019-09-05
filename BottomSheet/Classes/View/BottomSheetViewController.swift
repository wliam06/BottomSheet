//
//  BottomSheetViewController.swift
//  BottomSheet
//
//  Created by William_itmi on 04/09/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

enum SheetSize {
  case semiFullScreen
  case halfScreen
}

class BottomSheetViewController: UIViewController {
  public private(set) var childViewController: UIViewController!
  @IBOutlet weak var containerView: UIView!

  @IBOutlet weak var dismissAreaView: UIView!
  @IBOutlet weak var containerHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var containerBottomConstraint: NSLayoutConstraint!

  /// If true, tapping on the overlay above the sheet will dismiss the sheet view controller
  public var dismissOnBackgroundTap: Bool = true

  /// If true, sheet may be dismissed by panning down
  public var dismissOnPan: Bool = true

  public var willDismiss: ((BottomSheetViewController) -> Void)?
  public var didDismiss: ((BottomSheetViewController) -> Void)?
  /// If true, sheet's dismiss view will be generated, otherwise sheet remains fixed and will need to be dismissed programatically
  public var dismissable: Bool = true {
    didSet {
      guard isViewLoaded else { return }
    }
  }

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

  // MARK: - Initialized
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }

  convenience init(withController viewController: UIViewController, sizes: SheetSize) {
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

    UIView.animate(withDuration: 0.5, delay: 0,
                   options: .curveEaseOut,
                   animations: { [weak self] in
                    guard let self = self else { return }
                    self.view.backgroundColor = self.overlayColor
                    self.containerView.transform = CGAffineTransform.identity
    }, completion: nil)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.view.backgroundColor = .clear
    configureContainerView()

    configureChildViewController()

    // Setup dismiss view when tapped
    handleDismissView()
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
    case .semiFullScreen:
      let insets = self.safeAreaInsets
      return UIScreen.main.bounds.height - insets.top - 120
    case .halfScreen:
      return (UIScreen.main.bounds.height) / 2 + 24
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
}
