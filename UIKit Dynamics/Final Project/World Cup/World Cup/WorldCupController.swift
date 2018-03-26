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
  let groups = ["Group A": ["Russia", "Uruguay", "Egypt", "Saudi Arabia"], "Group B": ["Spain", "Portugal", "Iran", "Morocco"], "Group C": ["France", "Denmark", "Australia", "Peru"],
                "Group D": ["Argentina", "Croatia", "Iceland", "Nigeria"], "Group E": ["Brazil", "Switzerland", "Serbia", "Costa Rica"], "Group F": ["Germany", "Sweden", "Mexico", "South Korea"],
                "Group G": ["England", "Belgium", "Tunisia", "Panama"], "Group H": ["Poland", "Colombia", "Japan", "Senegal"]]
  
  let sky = UIColor(red: 116 / 255, green: 124 / 255, blue: 191 / 255, alpha: 1)
  let grass = UIColor(red: 61 / 255, green: 170 / 255, blue: 87 / 255, alpha: 1)

  var offset: CGFloat = 400
  var previousPoint = CGPoint.zero
  var center = CGPoint.zero
  var centers = [CGPoint]()
  
  var draggingView = false
  var pinnedView = false
  var subviews = [UIView]()
  
  var animator: UIDynamicAnimator!
  let gravity = UIGravityBehavior()
  var snap: UISnapBehavior!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    animator = UIDynamicAnimator(referenceView: view)
    animator.addBehavior(gravity)
    gravity.magnitude = 4
    
    let names = Array(groups.keys).sorted()
    for name in names {
      guard let index = names.index(of: name), let subview = addGroup(name: name, index: index, offset: offset) else {
        continue
      }
      subviews.append(subview)
      centers.append(subview.center)
      offset -= 50
    }
  }
  
  func addGroup(name: String, index: Int, offset: CGFloat) -> UIView? {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let controller = storyboard.instantiateViewController(withIdentifier: "group") as! GroupController
    let frame = view.bounds.offsetBy(dx: 0, dy: view.bounds.size.height - offset)
    controller.view.frame = frame
    
    guard let teams = groups[name] else {
      return nil
    }
    let group = Group(name: name, teams: teams)
    controller.color = index % 2 == 0 ? .green : .blue
    controller.view.backgroundColor = index % 2 == 0 ? sky: grass
    controller.setLabels(group: group)
   
    addChildViewController(controller)
    view.addSubview(controller.view)
    controller.didMove(toParentViewController: self)
    
    let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(recognizer:)))
    controller.view.addGestureRecognizer(pan)
    
    let collision = UICollisionBehavior(items: [controller.view])
    animator.addBehavior(collision)
    
    let boundary = controller.view.frame.origin.y + controller.view.frame.size.height
    var start = CGPoint(x: 0, y: boundary)
    var stop = CGPoint(x: self.view.bounds.size.width, y: boundary)
    collision.addBoundary(withIdentifier: "1" as NSCopying, from: start, to: stop)
    
    start.y = 0
    stop.y = 0
    collision.addBoundary(withIdentifier: "2" as NSCopying, from: start, to: stop)
    
    collision.collisionDelegate = self
    gravity.addItem(controller.view)
    
    let itemBehavior = UIDynamicItemBehavior(items: [controller.view])
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
        if dragPoint.y < 350 {
          draggingView = true
          previousPoint = touchPoint
          guard let index = subviews.index(of: recognizerView) else {
            break
          }
          center = centers[index]
        }
      case .changed:
        if draggingView {
          let offset = touchPoint.y - previousPoint.y
          let yCenter = recognizerView.center.y + offset
          let yCoordinate: CGFloat
          switch yCenter {
            case center.y...:
              yCoordinate = center.y
            default:
              yCoordinate = yCenter
          }
         recognizerView.center = CGPoint(x: center.x, y: yCoordinate)
         previousPoint = touchPoint
        }
      case .ended:
        if draggingView {
          pin(subview: recognizerView)
          addVelocity(recognizer: recognizer, subview: recognizerView)
          animator.updateItem(usingCurrentState: recognizerView)
          draggingView = false
         }
      default:
        break
    }
  }
  
 func getBehavior(subview: UIView) -> UIDynamicItemBehavior? {
    for behavior in animator.behaviors {
      guard let item = behavior as? UIDynamicItemBehavior else {
        continue
      }
      if item.items.first as! UIView == subview {
        return item
      }
    }
    return nil
  }
  
  func addVelocity(recognizer: UIPanGestureRecognizer, subview: UIView) {
    var velocity = recognizer.velocity(in: view)
    velocity.x = 0
    guard let behavior = getBehavior(subview: subview) else {
      return
    }
    behavior.addLinearVelocity(velocity, for: subview)
   }
  
  func pin(subview: UIView) {
    let pinView = subview.frame.origin.y < 100
    if pinView {
      if !pinnedView {
        snap = UISnapBehavior(item: subview, snapTo: view.center)
        animator.addBehavior(snap)
        setVisible(alpha: 0, subview: subview)
        pinnedView = true
      }
    } else {
      if pinnedView {
        animator.removeBehavior(snap)
        setVisible(alpha: 1, subview: subview)
        pinnedView = false
      }
    }
  }
  
  func setVisible(alpha: CGFloat, subview: UIView) {
    _ = subviews.filter{$0 != subview}.map{$0.alpha = alpha}
  }
}

// MARK: - UICollisionBehaviorDelegate
extension WorldCupController: UICollisionBehaviorDelegate {
  func collisionBehavior(_ behavior: UICollisionBehavior, beganContactFor item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?, at p: CGPoint) {
    switch identifier as! String {
      case "1":
        let subview = item as! UIView
        guard let behavior = getBehavior(subview: subview) else {
          break
        }
        var velocity = behavior.linearVelocity(for: subview)
        velocity.x = 0
        let otherSubviews = subviews.filter{$0 != subview}
        for otherView in otherSubviews {
          guard let otherBehavior = getBehavior(subview: otherView) else {
            continue
          }
          let bounce = 0.5 * velocity.y + CGFloat(arc4random() % 50)
          velocity.y = bounce
          otherBehavior.addLinearVelocity(velocity, for: otherView)
        }
      case "2":
        pin(subview: item as! UIView)
      default:
        break
    }
  }
}
