# Screencast Metadata

## Screencast Title

`FBSnapshotTestCase`: Testing the UI

## Screencast Description

Learn all you need to know about `FBSnapshotTestCase`, a very popular UI snapshot testing framework developed by Facebook.

## Language, Editor and Platform versions used in this screencast

* **Language:** Swift 4
* **Platform:** iOS 11
* **Editor**: Xcode 9

# FBSnapshotTestCase: Testing the UI

## Introduction

Hey what’s up everybody, this is Brian. In today's screencast I'm going to introduce you to a very popular UI testing framework developed by Facebook called `FBSnapshotTestCase`.

`FBSnapshotTestCase` tests your app's user interface by taking a snapshot of the UI and comparing it to a reference one. If both images are the same, the test succeeds. Otherwise, it fails. It's as simple as that! 

Before we begin, if you do not have any unit testing experience, then check out our course. Testing in iOS. This will get you up to speed in no time.

Also, I would like to thank Cosmin Pupăză for preparing the materials for this screencast and David Worsham for acting as tech editor. Don't forget to check them out on Twitter! :]

## Demo

The app you are going to test in this screencast is a simple color picker. It generates a custom color and uses it to set the app's main screen background. I'm going to write some tests for it.

To get started, I first need to install FBSnapshotTestCase. I'll do this by way of Cocoa. First I open terminal and navigate to the project folder and type `podfile init'.

This creates a new podfile. Next, I open my podfile in my text editor.

```
open podfile
```

At this point, I need to speficy the target to use frameworks instead of static libaries and then I add the FBSnapshotTestCase dependency. I save the pod, return to my terminal and install the pods.

```
pod install
```

With FBSnapshot installed, I open my workspace and update my project to the reccommended settings. I compile both my targets. You'll notice that compiling the FBSnapshotTestCase produces a lot of warnings, but it doesn't cause any issues with the running it. 
 
Before running any test, I need to define some folder paths where the snapshots will be saved. To do this, I click the Edit Scheme button. I Add the `FB_REFERENCE_IMAGE_DIR` and `IMAGE_DIFF_DIR` environment variables to the `Color Picker` scheme's run settings and configure their values. The former sets the reference snapshots folder, while the latter takes care of the test images location:

```
FB_REFERENCE_IMAGE_DIR  $(SOURCE_ROOT)/Tests/Original Images
IMAGE_DIFF_DIR          $(SOURCE_ROOT)/Tests/Different Images
```

Next I open Tests.swift and import the `FBSnapshotCase` framework. I also import the `ColorPicker` module making sure to make it @testable. Finally I make the`Tests` class extend `FBSnapshotTestCase`.

```
import FBSnapshotTestCase
@testable import Color_Picker

class Tests: FBSnapshotTestCase {
    
}
```
I'll be using the same view controller in each of my tests, so instead of creating a new view controller for each test case, I store a view controller in an instance variable. 

```
    let controller = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() as! ColorPicker.ColorController
```

Next I need to set recording mode to true. This will create reference snapshots which is what I'll test again. A good place for this in the setUp method. 

```
override func setUp() {
	super.setUp()
   	recordMode = true
  }
```

Now for the first test. I add the `testView()` method to my `Tests` class - it uses the framework's `FBSnapshotVerifyView(_:)` function to test the view controller's view.

```
func testView() {
	FBSnapshotVerifyView(controller.view)
 }
```

Now I run the test - it fails. Although I've run the test, I'm not actually doing any testing. I'm actually creating my baseline image which I will test against. 

When I check the reference snapshots folder, I see that I have my snapshot. Notice that the test method's name appears in the snapshot's name, so it's very clear which test generated which 
snapshot.

Now I want to properly run my test. so I set the `recordMode` property to `false` in the `setUp()` method. 

Following the red - green refactor metholology, I make sure my new test fails. I open Interface Builder and set the view background color to white.  

I run the test. As expected, it fails. I check the test snapshots folder to see what went wrong. The view reference snapshot has three corresponding view testing images: the right one, the wrong one and one that highligts the differences between the previous two. Notice each test method's name in the corresponding test image - you can't ever mix them up.

Now I want the test to pass so I return back to my main storyboard and set the view's color back to black. Now I run my test, and this time, it succeeds. 

## Camera

As you can see, FBSnapshotTestCase is another useful tool in our testing toolbox to make sure our UI looks as we intended. It also comes with other features. You can also test subviews in the view hierarchy, you can test layers, and it works great the UIApperrance proxy.

Let's see these in action.

## Demo

Okay, now to take the FBSnapshotTestCase to the next level by 
testing a certain subview in the view's hierarchy instead of the whole view. I'll do this by adding the `testSwitch()` test method to the `Tests` class. I need need to load the view controller's view first in order to access its subviews by calling the view controller's `view` property. Then I test the switch as I would do with any other view.  

```
func testSwitch() {
 	_ = controller.view
	FBSnapshotVerifyView(controller.alphaSwitch)
}
```  

Next I set the `recordMode` property to `true` in the `setUp()` method and run the test. Since I'm recording, the test fails as expected. Remember, when I set the recordMode to true, I'm not actually testing, but getting a reference snapshot to run my tests against.

With that done, I need to get to my red state for my test. I set the `recordMode` property to `false`, then open the main storyboard. I change the switch's state to `On` in the storyboard and run it once more. It fails now. Like the previous test, I can review the switch's three test snapshots are created at the specific location to see why the test is failing.

Now for the green state. Back in my main storyboard, I set the switch's state to off. I run the test and now I'm in the green. 

I can also test multiple subviews in the same test method. I do this by adding the `testLabels()` test method. I load the view controller's view first like before and then add an unique identifier for each label test function call. 

```
func testLabels() {
	_ = controller.view
    
	FBSnapshotVerifyView(controller.redLabel, identifier: "red")
	FBSnapshotVerifyView(controller.greenLabel, identifier: "green")
	FBSnapshotVerifyView(controller.blueLabel, identifier: "blue")
}
```

Now to get my baseline. I set the `recordMode` property to `true` and run the test. It fails and I check the the generated snapshots,  You'll notice that the identifiers appear in the snapshots names.

Now for the red state. I set the Set the `recordMode` property to `false`. In Interface Builder, I change the red label's color to green, the green's one to blue and the blue one's to red. I run the test and it fails as expected. Now back in Interface Builder, I revert my changes and run again. This time, I'm in the green. 

Keep in mind, I can add the device type, operating system version and screen size to the snapshot images names. I add the `testSliders()` test method and set the framework's `isDeviceAgnostic` property to `true`. This adds more info to the snapshots names. I then load the view controller's view and test the sliders by adding an identifier to each slider test function call as before.  

```
func testSliders() {
	isDeviceAgnostic = true
 	_ = controller.view
    
	FBSnapshotVerifyView(controller.redSlider, identifier: "red")
	FBSnapshotVerifyView(controller.greenSlider, identifier: "green")
	FBSnapshotVerifyView(controller.blueSlider, identifier: "blue")
}
```

Now for my baseline. I set the `recordMode` property to `true` and run the test. Now I check the snapshots and you'll notice the extra info in the snapshots names. 

To get to the red state, I set the `recordMode` property to `false` and in the storyboard, I set the sliders value to 127. I run the test and it fails. When I revert the change in the storyboard, it goes green.  We're cooking with gravy now. 

You can also test layers besides views. I'll try it on the switch by adding the `testSwitchLayer()` test method. First I load the view controller's view first and then test the switch's layer with the framework's `FBSnapshotVerifyLayer(_:)` function. 

```
func testSwitchLayer() {
	_ = controller.view
	FBSnapshotVerifyLayer(controller.alphaSwitch.layer)
}
```

Now set the `recordMode` property to `true` and run the test. It fails and the switch layer's reference snapshot is created in its corresponding folder.

Now for the rest state. I set the `recordMode` property to `false`. In interface builder, I change the switch layer's corner radius by adding a user defined runtime attribute. For the keypath, I use `layer.cornerRadius'. I set the 'Type' to be `Number`, and enter `30` for `Value`. I also Check the switch's 'Clip to Bounds' option and run the test once more. It fails now as I expect. Now I remove the User attibute and uncheck the clip to bounds and when I run, the test goes green.

I can also test the switch's view and layer in the same test method. To get started, I open my main storyboard, and change the state of my switch to `Off`. Back in Tests.swift, I add the `testSwitchViewAndLayer()`. First I load the view controller's view and add identifiers to both the view and layer test function calls like before. 
        
``` 
func testSwitchViewAndLayer() {
	_ = controller.view
    
	FBSnapshotVerifyView(controller.alphaSwitch, identifier: "view")
	FBSnapshotVerifyLayer(controller.alphaSwitch.layer, identifier: "layer")
 }
``` 
 
Next I set the `recordMode` property to `true` and get my baseline. 

Next, I set the `recordMode` property to `false`. I open my storyboard and set the 'Clip to Bounds' option. I also add back my runtime attribute. I run the test and I get the red state. I return back to my storyboard and uncheck the clips to bounds and remove the runtime attribute. Now when I run, my test goes green.

Finally, the `FBSnapshotTestCase` works well with the `UIAppearance` proxy. To get this working, I open ColorController.swift, and I add `viewDidLoad()`. It uses the `UIAppearance` proxy to set all of the labels text color to gray in one go: 

```
override func viewDidLoad() {
	super.viewDidLoad()
	UILabel.appearance().textColor = UIColor.gray
}
```

Now I switch back to Tests.swift and add the `testLabelsAppearance()` test method to it. I Set the framework's `usesDrawViewHierarchyInRect` property  to `true` first in order to render the view's hierarchy properly and enable the `UIAppearance` proxy while testing. Then I load the view controller's view and test the labels by adding an identifier to each label test function call. 

```
func testLabelsAppearance() {
	usesDrawViewHierarchyInRect = true
    _ = controller.view
    
    FBSnapshotVerifyView(controller.redLabel, identifier: "red")
    FBSnapshotVerifyView(controller.greenLabel, identifier: "green")
    FBSnapshotVerifyView(controller.blueLabel, identifier: "blue")
}
```
Now I set the `recordMode` property to `true` and run the test. It fails but I get my snapshots. Looking at the snapshots, you'll notice the grey text as designed. 

Now for my red state. I set the `recordMode` property to `false`. Next I open ColorController.swift and in viewDidLoad(), I change the labels text color to orange.

```
    UILabel.appearance().textColor = UIColor.orange
```

I run the test and it fails. Now, I go back to ColorCoontroller.swift and change the color back to grey. I run it one final time, and we are in the green. 
    
## Conclusion

`FBSnapshotTestCase` provides a lot of useful features that makes our testing easier. As the developers mention, you can handle issues by writing a lot of assert statements, but those are hard to visualize. Instead, you can see exactly what you can see exactly what is going on by a mere screenshot. 

 If you want to learn more about the framework, check out its GitHub page:

https://github.com/facebookarchive/ios-snapshot-test-case

For more screencasts and courses on iOS testing, keep on heading back to raywenderlich.com. But before you go, let me leave you with this nugget of wisdom. 

Do you know how many testers it takes to change a light bulb? None: testers do not fix problems - they just find them! Cheers!




 
 
 