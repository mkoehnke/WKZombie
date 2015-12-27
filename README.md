# Headless
Headless is an *experimental* iOS web browser without a graphical user interface. It was written in Swift, incorporating functional concepts such as *Futures/Promises* and *Function Currying*.  

## What is a headless browser?
link of all headless browsers

* HTML and rudimentary JSON support
* functional, actions can be chained
* uses WebKit and hpple for parsing
* written in Swift
* easily chainable

# Use Cases
* Scraping web sites for data.
* Automating interaction of web pages.
* Manipulation of websites using JavaScript
* Tests
* etc.

# Setup
## CocoaPods
[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate the Headless into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!

pod 'Headless'
```

Then, run the following command:

```bash
$ pod install
```



* experimenting with functional concepts such as Futures/Promises and Function Currying. This is far from feature complete, but it works great and functionality can be easily added.

* Condition / Wait


# What can be improved?
* HTMLImage
* ScreenCapture

# Author
Mathias Köhnke [@mkoehnke](http://twitter.com/mkoehnke)

# License
Headless is available under the MIT license. See the LICENSE file for more info.

# Recent Changes
The release notes can be found [here](https://github.com/mkoehnke/Headless/releases).
