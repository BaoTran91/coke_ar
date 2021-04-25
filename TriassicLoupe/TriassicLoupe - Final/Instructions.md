#  How to use this App
## Requriements

* 6s (A9 processor) or newer running iOS 12 and XCode 10.


## Image Tracking
### Setup
1. Print out one of the slides in the included keynote. 

### Usage
1. Run the app and point it at the image portion of the slide.
2. Watch an animated dinosaur (same for all images).

## Object Tracking
Your own objects will serve as stand-ins for dinosaur models that would be found in the dioramas a natural history museum. 

### Setup
You'll have to scan three objects using Apple's object scanning app. For best results, the lighting should be even and the object should have lots of color and detail, and be opaque and non-reflective. 

Make three scans and replace the `brachiosaurus`,  `iguanadon`, and `velociraptor` in the Assets catalog.   

### Scanning a New Object
Before object detection an be done, the app needs a reference for that object. The easiest way to get a reference is to scan the object using Apple's sample project, which can be downloaded here:

https://developer.apple.com/documentation/arkit/scanning_and_detecting_3d_objects

Follow the instructions to get 3 different `.arobject` files.

### Detecting the objects
Build and run the app and point at one of the objects previously scanned and added to the objects group. This may requires several tries, and it helps to move around the object, forward and back, around the sides, etc to give ARKit the best chance of realizing the shape. Be sure to move slow and steady.

Once an object is detected, the info will be displayed next to the object, and some dinosaur sounds will paly. 

