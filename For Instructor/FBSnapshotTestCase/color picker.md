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

Before we begin, I would like to thank Cosmin Pupăză for preparing the materials for this screencast and David Worsham for acting as tech editor. Don't forget to check them out on Twitter! :]

All right, back to the framework! `FBSnapshotTestCase` tests your app's user interface by taking a snapshot of the UI and comparing it to a reference one. If both images are the same, the test succeeds. Otherwise, it fails. It's as simple as that! You just add the framework as a `Carthage` dependency to your app's testing target and you are ready to go.

The app you are going to test in this screencast is a simple color picker. It generates a custom color and uses it to set the app's main screen background. Let's write some tests for it! :]

## Demo

 
Before running any test, you should first define the folder paths where the snapshots will be saved. Add the `FB_REFERENCE_IMAGE_DIR` and `IMAGE_DIFF_DIR` environment variables to the `Color Picker` scheme's run settings and configure their values. The former sets the reference snapshots folder, while the latter takes care of the test images location:

```
FB_REFERENCE_IMAGE_DIR  $(SOURCE_ROOT)/Tests/Original Images
IMAGE_DIFF_DIR          $(SOURCE_ROOT)/Tests/Different Images
```

Next import the `FBSnapshotCase` framework and `Color Picker` module in `Tests.swift` and make your custom `Tests` class extend `FBSnapshotTestCase`. Everything works just fine, so we've got autocomplete! :]

```
import FBSnapshotTestCase
@testable import Color_Picker

class Tests: FBSnapshotTestCase {
    
}
```

Now store a reference to the app's main view controller from the storyboard by adding the following line of code to the `Tests` class. It will come in handy later on:

    let controller = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() as! ColorController


You create reference snapshots in recording mode, so you have to set this up for all tests in the `Tests` class. Add the `setUp()` method to the class and set the framework's `recordMode` property to `true` inside it:

```
override func setUp() {
	super.setUp()
   	recordMode = true
  }
```

Time to write your first test! Add the `testView()` method to your `Tests` class - it uses the framework's `FBSnapshotVerifyView(_:)` function to test the view controller's view.

```
func testView() {
	FBSnapshotVerifyView(controller.view)
 }
```

Run the test - it fails because you are creating the view's reference snapshot now. Check the reference snapshots folder and there it is - way to go! :] Notice that the test method's name appears in the snapshot's name, so it's very clear which test generated which snapshot - really cool! :]

Now set the `recordMode` property to `false` in the `setUp()` method and run the test again - it succeeds this time because you haven't changed the view's background color yet. Go ahead and set it to white in Interface Builder. Run the test once more - it fails, so check the test snapshots folder to see what went wrong. The view reference snapshot has three corresponding view testing images: the right one, the wrong one and one that highligts the differences between the previous two. Notice each test method's name in the corresponding test image - you can't ever mix them up! :]

You can test just a certain subview in the view's hierarchy instead of the whole view. Give it a try with the switch by adding the `testSwitch()` test method to the `Tests` class. You need to load the view controller's view first in order to access its subviews by calling the view controller's `view` property. Then you test the switch as you would do with any other view.  

```
func testSwitch() {
 	_ = controller.view
	FBSnapshotVerifyView(controller.alphaSwitch)
}
```  

Next set the `recordMode` property to `true` in the `setUp()` method and run the test. It fails and the switch reference snapshot is created in its corresponding folder. Set the `recordMode` property to `false` and run the test again - it works this time. Change the switch's state to `On` in the storyboard and run it once more. It fails now and the switch's three test snapshots are created at the specific location. 

You may test multiple subviews in the same test method. Try it out on the labels by adding the `testLabels()` test method to the `Tests` class. Load the view controller's view first like before and then add an unique identifier for each label test function call. 

```
func testLabels() {
	_ = controller.view
    
	FBSnapshotVerifyView(controller.redLabel, identifier: "red")
	FBSnapshotVerifyView(controller.greenLabel, identifier: "green")
	FBSnapshotVerifyView(controller.blueLabel, identifier: "blue")
}
```

Now set the `recordMode` property to `true` and run the test. It fails and the labels reference snapshots are created in their corresponding folder. Notice that the identifiers appear in the snapshots names - nice! :]      

Set the `recordMode` property to `false` and run the test again - it works this time. Change the red label's color to green, the green's one to blue and the blue one's to red in Interface Builder and run it once more. It fails now and the labels test snapshots are created at the specific location. Notice the identifiers in the images names - really cool! :]

You can add the device type, operating system version and screen size to the snapshot images names. Give it a shot with the sliders by adding the `testSliders()` test method to the `Tests` class. Set the framework's `isDeviceAgnostic` property to `true` first to add more info to the snapshots names. Then load the view controller's view and test the sliders by adding an identifier to each slider test function call as before.  

```
func testSliders() {
	isDeviceAgnostic = true
 	_ = controller.view
    
	FBSnapshotVerifyView(controller.redSlider, identifier: "red")
	FBSnapshotVerifyView(controller.greenSlider, identifier: "green")
	FBSnapshotVerifyView(controller.blueSlider, identifier: "blue")
}
```

Next set the `recordMode` property to `true` and run the test. It fails and the sliders reference snapshots are created in their corresponding folder. Notice the extra info in the snapshots names - how cool is that! :]

Set the `recordMode` property to `false` and run the test again - it works this time. Change the sliders value to 127 in the storyboard and run it once more. It fails now and the sliders test snapshots are created at the specific location. Notice the extra info in the images names - way to go! :]  

You can also test layers besides views. Try it on the switch by adding the `testSwitchLayer()` test method to the `Tests` class. Load the view controller's view first as usual and then test the switch's layer with the framework's `FBSnapshotVerifyLayer(_:)` function. 

```
func testSwitchLayer() {
	_ = controller.view
	FBSnapshotVerifyLayer(controller.alphaSwitch.layer)
}
```

Now set the `recordMode` property to `true` and run the test. It fails and the switch layer's reference snapshot is created in its corresponding folder.

Set the `recordMode` property to `false` and run the test again - it works this time. Change the switch layer's corner radius by adding a user defined runtime attribute in Interface Builder. Type `layer.cornerRadius` for `Key Path`, select `Number` for `Type` and enter `30` for `Value`. Check the switch's 'Clip to Bounds' option and run the test once more. It fails now and the switch layer's test images are created at the specific location.

You may test the switch's view and layer in the same test method. To do this, first uncheck the switch's 'Clip to Bounds' option in the storyboard and change its state to `Off`. Then add the `testSwitchViewAndLayer()` to the `Tests` class. Load the view controller's view and add identifiers to both the view and layer test function calls like before. 
        
``` 
func testSwitchViewAndLayer() {
	_ = controller.view
    
	FBSnapshotVerifyView(controller.alphaSwitch, identifier: "view")
	FBSnapshotVerifyLayer(controller.alphaSwitch.layer, identifier: "layer")
 }
``` 
 
Next set the `recordMode` property to `true` and run the test. It fails and the switch view and layer reference snapshots are created in their corresponding folder. Notice the identifiers in the snapshots names - really cool! :]

Set the `recordMode` property to `false` and run the test again - it works this time. Check the switch's 'Clip to Bounds' option in Interface Builder and revert it to its previous state. Run the test once more - it fails and the switch view and layer test images are created at their specific location. Notice the identifiers in the images names - good job! :]

`FBSnapshotTestCase` works well with the `UIAppearance` proxy. Add the `viewDidLoad()` method to the `ColorController` class - it uses the `UIAppearance` proxy to set all of the labels text color to gray in one go: 

```
override func viewDidLoad() {
	super.viewDidLoad()
	UILabel.appearance().textColor = UIColor.gray
}
```

Now switch back to your `Tests` class and add the `testLabelsAppearance()` test method to it. Set the framework's `usesDrawViewHierarchyInRect` property  to `true` first in order to render the view's hierarchy properly and enable the `UIAppearance` proxy while testing. Then load the view controller's view and test the labels by adding an identifier to each label test function call. 

```
func testLabelsAppearance() {
	usesDrawViewHierarchyInRect = true
    _ = controller.view
    
    FBSnapshotVerifyView(controller.redLabel, identifier: "red")
    FBSnapshotVerifyView(controller.greenLabel, identifier: "green")
    FBSnapshotVerifyView(controller.blueLabel, identifier: "blue")
}
```
Next set the `recordMode` property to `true` and run the test. It fails and the labels reference snapshots are created in their corresponding folder. Notice that their text is gray now - way to go! :]

Set the `recordMode` property to `false` and run the test again - it works this time. Now switch to the `ColorController` class and change the labels text color to orange in the `viewDidLoad()` method like this:

    UILabel.appearance().textColor = UIColor.orange
    
Go back to your `Tests` class and run the test once more. It fails and the labels test snapshots are created at their specific location. Notice that their text is orange now - good work! :] 
    
## Conclusion

All right, that’s everything I’d like to cover in this video. 

At this point, you should know how to test your app's UI with `FBSnapshotTestCase`. If you want to learn more about the framework, check out its GitHub page:

https://github.com/facebookarchive/ios-snapshot-test-case

Speaking of testing, do you know how many testers it takes to change a light bulb? None: testers do not fix problems - they just find them! :]

All right, I'm out! :]


 
 
 