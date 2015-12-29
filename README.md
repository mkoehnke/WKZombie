# Headless
Headless is an *experimental* iOS web browser without a graphical user interface. It was written in Swift, incorporating functional concepts such as *Futures/Promises* and *Function Currying*.  

## Example

### Web-Browser Navigation

Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.

<p align="center">
<img src="https://raw.githubusercontent.com/mkoehnke/Headless/develop/Resources/Headless-Web-Demo.gif?token=ABXNjfam11l2jWAHXADeARCGeuMnKTI5ks5Wi8zrwA%3D%3D" />
</p>


### Automation with Headless

Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.

<p align="center">
<img src="https://raw.githubusercontent.com/mkoehnke/Headless/develop/Resources/Headless-Simulator-Demo.gif?token=ABXNjTsRwVOmj1xb8Qzfp9-UvXKoVgzGks5Wi803wA%3D%3D" />
</p>

Easy navigation by linking actions >>> (demo)

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


# Usage
A web session equates to a headless instance, which can be created using the following line:

```swift
let headless = Headless(name: "Demo")
```

Web page navigation is based on *Actions*, which can be executed explicitly by calling the *start()* method

```swift
let action : Action<HTMLPage> = headless.get(url)

action.start { result in
    switch result {
    case .Success(let page): // process page
    case .Error(let error):  // handle error
    }
}
```

or implicitly when linking actions using the **>>>** operator

```swift
// Helper method
func getLink(page: HTMLPage) -> Action<HTMLLink> {
  return Action(result: page.firstLinkWithAttribute("href", value: "/account/"))
}

// Linking actions
let combined : Action<HTMLPage> = headless.get(url) >>> getLink >>> headless.click
```
Starting *combined* will implicitly execute all chained actions passing each result to the next action.


## Basic Actions
### Open a Website

```swift
headless.get(url).start { result in
    switch result {
    case .Success(let page): // process page
    case .Error(let error):  // handle error
    }
}
```

### Submit a Form

```swift
func submitLoginForm(page: HTMLPage) -> Action<HTMLPage> {
    switch page.formWithName("form2") {
    case .Success(let form):
        form["username"] = "username"
        form["password"] = "password"
        return headless.submit(form)

    case .Error(let error):
        return Action(error: error)
    }
}

submitLoginForm.start { result in
  // handle result
}
```

### Click a Link

```swift
let result = page.firstLinkWithAttribute("href", value: "/account/")
switch result {
case .Success(let link):
    headless.click(link).start { // handle result }
case .Error(let error):
    // handle error
}
```

## Advanced Actions

### Batch

### Repeat

## Linking Actions


## Conditions

* experimenting with functional concepts such as Futures/Promises and Function Currying. This is far from feature complete, but it works great and functionality can be easily added.

* Condition / Wait


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




# What can be improved?
* HTMLImage
* ScreenCapture

# Author
Mathias Köhnke [@mkoehnke](http://twitter.com/mkoehnke)

# License
Headless is available under the MIT license. See the LICENSE file for more info.

# Recent Changes
The release notes can be found [here](https://github.com/mkoehnke/Headless/releases).
