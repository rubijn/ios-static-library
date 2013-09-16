Tutorial for create a static library on ios
==================


This is help for video http://youtu.be/f7lxkv-sZA0

[1. Create Static Library](https://github.com/rubijn/ios-static-library/blob/master/README.md#1-create-static-library)<br/>
[2. Create Project who use the library](https://github.com/rubijn/ios-static-library/blob/master/README.md#2-create-a-new-project-who-use-the-library)<br/>
[3. Use categories in library](https://github.com/rubijn/ios-static-library/blob/master/README.md#3-use-categories-in-library)<br/>
[4. Add Automate for merging categories](https://github.com/rubijn/ios-static-library/blob/master/README.md#4-automate-the-merge-for-iphone-and-simulator)

###1. Create static library

####1.1 Create from template 
First we must create a static library project
* File > New > Project
* Chose iOs / Framework & Library
* Select Cocoa Touch Static Library
* Name the project MyStaticLibrary

####1.2 Create a custom object
* File > New > File
* Choose iOs / Cocoa Touch 
* Select Objective-C class 
* Name the file MyCustomObject
* Add this method to the @interface and @implementation

_MyCustomObject.h_

    @interface MyCustomObject : NSObject
      -(void)aMethod;
    @end

_MyCustomObject.m_

    @implementation MyCustomObject
      -(void)aMethod {
        NSLog(@"call MyCustomObject method !");
    }
    @end

* Add MyCustomObject.h to build phase 
  * Select target MyStaticLibrary
  * Select Build Phases tab
  * Expend Copy Files 
  * Click on + to add MyCustomObject.h

* Add MyCustomObject.h to MyStaticLibrary.h (optional) 

_MyStaticLibrary.h_

    #import <Foundation/Foundation.h>
    #import "MyCustomObject.h"

    @interface MyStaticLibrary : NSObject
    @end

####1.3 Compile the lib for ios et simulator
We need now to build .a file (compiled library file)

We must compile for ios device **AND** for ios simulator (i386 arch)
* Select MyStaticLibrary > iOs Device and Build (&#x2318; + B)
* Select MyStaticLibrary > iPhone 6.1 Simulator and Build (&#x2318; + B)

####1.4 Look at the directory we must merge the two library 
* Expand Products in File Browser view 
* Select libMyStaticLibrary.a
* Right Button > Show in Finder 
* Move up in directory

You must have this hierarchy
* Products/Debug-iphoneos/libMyStaticLibrary.a
* Products/Debug-iphonesimulator/libMyStaticLibrary.a

For using this two library in a new project, we must merge it in one single file .a

* open Terminal
* cd <directory of library>/Products/

Launch this command
   
    lipo -create Products/Debug-iphoneos/libMyStaticLibrary.a Products/Debug-iphonesimulator/libMyStaticLibrary.a -output libMyStaticLibrary.a
    
After that we can use this new merged library in a new project     


==================
###2. Create a new project who use the library

####2.1 Create from simple view
* File > New > Project
* Chose Application / Single View Application
* Name the project MyAppUsingCustomLibrary

####2.2 Drag the .a file and include from the build directory
* Drag merged library libMyStaticLibrary.a into project 
* Drag include from Debug-iponeos or Debug-iphonesimulator in the project

####2.3 in Viewcontroller add a call to MyCustomObject
Edit _Viewcontroller.m_
    
    MyCustomObject *obj = [[MyCustomObject alloc] init];
    [obj aMethod];
    [obj release];    

####2.4 compile it's work
Look at the output pannel 

    2013-09-16 23:38:27.838 MyAppUsingCustomLibrary[1138:c07] call MyCustomObject method !

==================
###3. Use categories in library 

When we want to use a custom category in your library follow this method.

####3.1 create a UIImage-Custom class
* File > New > File
* Choose iOs / Cocoa Touch 
* Select Objective-C class 
* Name the file UIImage-Custom
* Add this method to the @interface and @implementation

_UIImage-Custom.h_

    @interface UIImage (Alpha)
    -(BOOL)hasAlpha;
    @end
    
_UIImage-Custom.m_

    @implementation UIImage (Alpha)
    -(BOOL)hasAlpha {
      return NO;
    }
    @end

####3.2 import the UIKit in library project
* Select MyStaticLibrary Target
* Select Build Phases 
* Expend Link Binary
* Add UIKit

####3.3 compile for iphone an simulator 
* Build / iOs Device
* Build / iPhone Simulator
* Merge the two .a with the lipo command see at 1.4

####3.4 return to app who use the library 
Add usage of UIImage hasAlpha

Edit _Viewcontroller.m_
    
    UIImage *img = [[UIImage alloc] init];
    NSLog(@"hasAlpha ? %i", [img hasAlpha]);
    [img release];

####3.5 Compile = Error

    *** Terminating app due to uncaught exception 'NSInvalidArgumentException', 
    reason: '-[UIImage hasAlpha]: unrecognized selector sent to instance 0x8a437a0'

We need to add flags to the Build Settings

####3.6 Add -ObjC -all_load to Other link flags 
* Select Target 
* Select Build Settings tab
* In the search input enter "other linker"
* Select Other Linker Flags 
* Add -ObjC and -all_load

####3.7 Compile it's work 
Build and now the categroy working

    2013-09-16 23:51:44.621 MyAppUsingCustomLibrary[1289:c07] hasAlpha ? 0

==================
###4. Automate the merge for iphone and simulator 

####4.1 Add a Aggregate target to library project MyStaticLibraryAggregate
* File > New > Target 
* Select Other
* Select Aggregate
* Enter name MyStaticLibraryAggregate

####4.2 Add Build Script 
* Select target MyStaticLibraryAggregate
* Select Build Phases Tab
* Click on Add Build Phase (bottom right)
* Add Run Scripts

####4.3 Enter the scripts bellow

    # set target for final .a file
    TARGET_OUTPUT=${BUILD_DIR}/${CONFIGURATION}-universal

    # compile projet in 2 version iphoneos and iphonesimulator
    xcodebuild -target MyStaticLib ONLY_ACTIVE_ARCH=NO -configuration ${CONFIGURATION} -sdk iphoneos BUILD_DIR="${BUILD_DIR}" BUILD_ROOT="${BUILD_ROOT}"
    xcodebuild -target MyStaticLib -arch i386 -configuration ${CONFIGURATION} -sdk iphonesimulator BUILD_DIR="${BUILD_DIR}" BUILD_ROOT="${BUILD_ROOT}"

    # create universal directory if not exists
    mkdir -p "${TARGET_OUTPUT}"

    # merge two lib in universal one
    lipo -create "${BUILD_DIR}/${CONFIGURATION}-iphoneos/lib${PROJECT_NAME}.a" "${BUILD_DIR}/${CONFIGURATION}-iphonesimulator/lib${PROJECT_NAME}.a" -output "${TARGET_OUTPUT}/lib${PROJECT_NAME}.a"

    # copy header to universal lib
    cp -R "${BUILD_DIR}/${CONFIGURATION}-iphoneos/include" "${TARGET_OUTPUT}/"

####4.4 Compile and go to build dir for see new directory
* Build > MyStaticLibraryAggregate

Check if no error come from sh script<br/>
Now whe have a new Directory 

    Products/Debug-universal/

Containing merged (universal) library and headers 

####4.5 Change link in app project for use the new directory 
* Return to MyAppUsingCustomLibrary
* Remove old libMyStaticLibrary.a and includes link
* Add from Products/Debug-universal/libMyStaticLibrary.a and Products/Debug-universal/includes

That all !

Inspired from 
http://www.raywenderlich.com/41377/creating-a-status-library-in-ios-tutorial<br/>
and<br/>
http://blog.coderow.com/2012/08/23/building-an-ios-universal-static-library/


 
