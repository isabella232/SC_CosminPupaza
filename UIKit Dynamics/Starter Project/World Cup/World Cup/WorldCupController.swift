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
  var offset: CGFloat = Dynamics.height
  
  enum Data {
    static let groups = ["Group A": ["Russia", "Uruguay", "Egypt", "Saudi Arabia"], "Group B": ["Spain", "Portugal", "Iran", "Morocco"], "Group C": ["France", "Denmark",
                         "Australia",  "Peru"],  "Group D": ["Argentina", "Croatia", "Iceland", "Nigeria"], "Group E": ["Brazil", "Switzerland", "Serbia", "Costa Rica"],
                         "Group F": ["Germany", "Sweden", "Mexico", "South Korea"], "Group G": ["England", "Belgium", "Tunisia", "Panama"], "Group H": ["Poland", "Colombia", "Japan", "Senegal"]]
  }
  
  enum Storyboard {
    static let name = "Main"
    static let groupController = "group"
    static let mainBundle: Bundle? = nil
  }
  
  enum Colors {
    static let sky = UIColor(red: 116 / 255, green: 124 / 255, blue: 191 / 255, alpha: 1)
    static let grass = UIColor(red: 61 / 255, green: 170 / 255, blue: 87 / 255, alpha: 1)
    static let denominator = 2
    static let remainder = 0
  }
  
  enum Dynamics {
    static let height: CGFloat = 400
    static let groupOffset: CGFloat = 50
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let names = Array(Data.groups.keys).sorted()
    _ = names.map{guard let index = names.index(of: $0) else {return}
                  addGroup(name: $0, index: index, offset: offset)
                  offset -= Dynamics.groupOffset}
    }
    
  func addGroup(name: String, index: Int, offset: CGFloat) {
    let storyboard = UIStoryboard(name: Storyboard.name, bundle: Storyboard.mainBundle)
    guard let controller = storyboard.instantiateViewController(withIdentifier: Storyboard.groupController) as? GroupController else {return}
    let frame = view.bounds.offsetBy(dx: 0, dy: view.bounds.size.height - offset)
    controller.view.frame = frame
    
    guard let teams = Data.groups[name] else {return}
    let group = Group(name: name, teams: teams)
    controller.color = index % Colors.denominator == Colors.remainder ? .green : .blue
    controller.view.backgroundColor = index % Colors.denominator == Colors.remainder ? Colors.sky: Colors.grass
    controller.setLabels(group: group)
    
    addChildViewController(controller)
    view.addSubview(controller.view)
    controller.didMove(toParentViewController: self)
  }
}
