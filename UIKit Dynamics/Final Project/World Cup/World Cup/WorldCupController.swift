/// Copyright (c) 2018 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit

class WorldCupController: UIViewController {
  
  var offset = Dynamics.height
  var previousPoint = Dynamics.zero
 
  var draggingView = Dynamics.undragged
  var pinnedView = Dynamics.unpinned
  var subviews = [UIView]()
  
  var animator: UIDynamicAnimator!
  let gravity = UIGravityBehavior()
  var snap: UISnapBehavior!
  
  enum Data {
    static let groups = ["Group A": ["Russia", "Uruguay", "Egypt", "Saudi Arabia"], "Group B": ["Spain", "Portugal", "Iran", "Morocco"], "Group C": ["France", "Denmark",
                         "Australia",  "Peru"],  "Group D": ["Argentina", "Croatia", "Iceland", "Nigeria"], "Group E": ["Brazil", "Switzerland", "Serbia", "Costa Rica"],
                         "Group F": ["Germany", "Sweden", "Mexico", "South Korea"], "Group G": ["England", "Belgium", "Tunisia", "Panama"], "Group H": ["Poland", "Colombia", "Japan", "Senegal"]]
    static let noTeams: UIView? = nil
  }
  
  enum Storyboard {
    static let name = "Main"
    static let groupController = "group"
    static let mainBundle: Bundle? = nil
    static let noView: UIView? = nil
  }
  
  enum Colors {
    static let sky = UIColor(red: 116 / 255, green: 124 / 255, blue: 191 / 255, alpha: 1)
    static let grass = UIColor(red: 61 / 255, green: 170 / 255, blue: 87 / 255, alpha: 1)
    static let denominator = 2
    static let remainder = 0
  }
  
  enum Dynamics {
    static let height: CGFloat = 400
    static let zero = CGPoint.zero
    static let groupOffset: CGFloat = 50
    static let dragOffset: CGFloat = 350
    static let pinOffset: CGFloat = 100
    static let boundaryOffset: CGFloat = 3
    static let xOffset: CGFloat = 0
    static let magnitude: CGFloat = 4
    static let dragged = true
    static let undragged = false
    static let velocity: CGFloat = 0.5
    static let random = 50
    static let pinned = true
    static let unpinned = false
    static let pinConstraint: CGFloat = 30
    static let unpinConstraint: CGFloat = 15
    static let transparent: CGFloat = 0
    static let opaque: CGFloat = 1
    static let noBehavior: UIDynamicItemBehavior? = nil
    static let noRotation = false
  }
  
  enum Boundary: String {
    case up
    case down
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    animator = UIDynamicAnimator(referenceView: view)
    animator.addBehavior(gravity)
    gravity.magnitude = Dynamics.magnitude
    
    let names = Array(Data.groups.keys).sorted()
    _ = names.map{guard let index = names.index(of: $0), let subview = addGroup(name: $0, index: index, offset: offset) else {return}
                  subviews.append(subview)
                  offset -= Dynamics.groupOffset}
    }
  
  func addGroup(name: String, index: Int, offset: CGFloat) -> UIView? {
    let storyboard = UIStoryboard(name: Storyboard.name, bundle: Storyboard.mainBundle)
    guard let controller = storyboard.instantiateViewController(withIdentifier: Storyboard.groupController) as? GroupController else {
      return Storyboard.noView
    }
    let frame = view.bounds.offsetBy(dx: Dynamics.xOffset, dy: view.bounds.size.height - offset)
    controller.view.frame = frame
    
    guard let teams = Data.groups[name] else {
      return Data.noTeams
    }
    let group = Group(name: name, teams: teams)
    controller.color = index % Colors.denominator == Colors.remainder ? .green : .blue
    controller.view.backgroundColor = index % Colors.denominator == Colors.remainder ? Colors.sky: Colors.grass
    controller.setLabels(group: group)
   
    addChildViewController(controller)
    view.addSubview(controller.view)
    controller.didMove(toParentViewController: self)
    
    let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(recognizer:)))
    controller.view.addGestureRecognizer(pan)
    
    let collision = UICollisionBehavior(items: [controller.view])
    animator.addBehavior(collision)
    
    let boundary = controller.view.frame.origin.y + controller.view.frame.size.height
    var start = CGPoint(x: Dynamics.xOffset, y: boundary)
    var stop = CGPoint(x: view.bounds.size.width, y: boundary)
    collision.addBoundary(withIdentifier: Boundary.down.rawValue as NSCopying, from: start, to: stop)
    
    start.y = -Dynamics.boundaryOffset
    stop.y = -Dynamics.boundaryOffset
    collision.addBoundary(withIdentifier: Boundary.up.rawValue as NSCopying, from: start, to: stop)
    
    collision.collisionDelegate = self
    gravity.addItem(controller.view)
    
    let itemBehavior = UIDynamicItemBehavior(items: [controller.view])
    itemBehavior.allowsRotation = Dynamics.noRotation
    animator.addBehavior(itemBehavior)
    
    return controller.view
  }
  
  @objc func handlePan(recognizer: UIPanGestureRecognizer) {
    let touchPoint = recognizer.location(in: view)
    guard let recognizerView = recognizer.view else {
      return
    }
    switch recognizer.state {
      case .began:
        let dragPoint = recognizer.location(in: recognizerView)
        if dragPoint.y < Dynamics.dragOffset {
          draggingView = Dynamics.dragged
          previousPoint = touchPoint
        }
      case .changed:
        if draggingView {
          let offset = touchPoint.y - previousPoint.y
          let yCenter = recognizerView.center.y + offset
          recognizerView.center = CGPoint(x: recognizerView.center.x, y: yCenter)
          previousPoint = touchPoint
        }
      case .ended:
        if draggingView {
          pin(subview: recognizerView)
          addVelocity(recognizer: recognizer, subview: recognizerView)
          animator.updateItem(usingCurrentState: recognizerView)
          draggingView = Dynamics.undragged
        }
      default:
        break
    }
  }
  
  func getItemBehavior(subview: UIView) -> UIDynamicItemBehavior? {
    let itemBehaviors = animator.behaviors.filter{guard let itemBehavior = $0 as? UIDynamicItemBehavior, let item = itemBehavior.items.first, item as? UIView == subview else {return false}
                                                  return true}
    guard let behavior = itemBehaviors.first, let itemBehavior = behavior as? UIDynamicItemBehavior else {
      return Dynamics.noBehavior
    }
    return itemBehavior
  }
  
  func addVelocity(recognizer: UIPanGestureRecognizer, subview: UIView) {
    var velocity = recognizer.velocity(in: view)
    velocity.x = Dynamics.xOffset
    guard let itemBehavior = getItemBehavior(subview: subview) else {
      return
    }
    itemBehavior.addLinearVelocity(velocity, for: subview)
   }
  
  func updateConstraint(subview: UIView, value: CGFloat) {
    guard let controller = childViewControllers.filter({$0.view == subview}).first, let group = controller as? GroupController else {
      return
    }
    group.constraint.constant = value
  }
  
  func setVisible(alpha: CGFloat, subview: UIView) {
    _ = subviews.filter{$0 != subview}.map{$0.alpha = alpha}
  }
  
  func pin(subview: UIView) {
    let pinView = subview.frame.origin.y < Dynamics.pinOffset
    if pinView {
      if !pinnedView {
        let point = CGPoint(x: view.center.x, y: view.center.y - Dynamics.boundaryOffset)
        snap = UISnapBehavior(item: subview, snapTo: point)
        animator.addBehavior(snap)
        updateConstraint(subview: subview, value: Dynamics.pinConstraint)
        setVisible(alpha: Dynamics.transparent, subview: subview)
        pinnedView = Dynamics.pinned
      }
    } else {
      if pinnedView {
        animator.removeBehavior(snap)
        updateConstraint(subview: subview, value: Dynamics.unpinConstraint)
        setVisible(alpha: Dynamics.opaque, subview: subview)
        pinnedView = Dynamics.unpinned
      }
    }
  }
}

// MARK: - UICollisionBehaviorDelegate
extension WorldCupController: UICollisionBehaviorDelegate {
  func collisionBehavior(_ behavior: UICollisionBehavior, beganContactFor item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?, at p: CGPoint) {
    guard let value = identifier as? String, let boundary = Boundary(rawValue: value) else {
      return
    }
    switch boundary {
      case .up:
        guard let subview = item as? UIView else {
          break
        }
        pin(subview: subview)
      case .down:
        guard let subview = item as? UIView, let itemBehavior = getItemBehavior(subview: subview) else {
          break
        }
        var velocity = itemBehavior.linearVelocity(for: subview)
        velocity.x = Dynamics.xOffset
        velocity.y = Dynamics.velocity * velocity.y + CGFloat(Int(arc4random()) % Dynamics.random)
        _ = subviews.filter{$0 != subview}.map{guard let otherItemBehavior = getItemBehavior(subview: $0) else {return}
                                               otherItemBehavior.addLinearVelocity(velocity, for: $0)}
    }
  }
}
