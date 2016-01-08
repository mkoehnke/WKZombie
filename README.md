# Headless
Headless is an iOS **web-browser without a graphical user interface**. It was developed as a mere *experiment* in order to familiarize myself with **using proven functional concepts** written in Swift have some fun with it. Some of those concepts are:

* *Futures/Promises* (for handling in asynchronous code)
* *Function Currying*
* *Custom Operators* (for chaining browser actions)

It uses [WebKit](https://webkit.org) (WKWebView) for rendering and [hpple](https://github.com/topfunky/hpple) (libxml2) for parsing the HTML content. Furthermore, it has rudimentary support for parsing JSON documents. Chaining asynchronous actions makes the code compact and easy to use.

For more information, see [Usage](#usage).

## Use Cases
* Scraping web sites for data
* Automating interaction of web pages
* Manipulation of websites
* Running automated tests
* etc.

## Example

### Web-Browser Navigation

Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.

<p align="center">
<img src="https://raw.githubusercontent.com/mkoehnke/Headless/develop/Resources/Headless-Web-Demo.gif?token=ABXNjQVdWqIq9FWdb42o8I09ERYprf7Mks5WmWgPwA%3D%3D" />
</p>


### Automation with Headless

Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.

<p align="center">
<img src="https://raw.githubusercontent.com/mkoehnke/Headless/develop/Resources/Headless-Simulator-Demo.gif?token=ABXNjWc-qmO9Vk7DUFWbnG1VE0LNM73Wks5WmWfXwA%3D%3D" />
</p>

Easy navigation by linking actions >>> (demo)




# Usage
A web session equates to a headless instance, which can be created using the following line:

```ruby
let 🌍 = Headless(name: "Demo")
```

```ruby
    🌍.open(url)
>>> 🌍.get(by: .Id("accountname"))
>>> 🌍.setAttribute("value", value: user)
>>> 🌍.get(by: .Id("accountpassword"))
>>> 🌍.setAttribute("value", value: password)
>>> 🌍.get(by: .Name("form2"))
>>> 🌍.submit(then: Wait(2.0))
>>> 🌍.get(by: .Attribute("href", "/account/"))
>>> 🌍.click
>>> 🌍.get(by: .Text("Provisioning Profiles"))
>>> 🌍.click(then: .Wait(0.5))
>>> 🌍.getAll(by: .Class("ui-ellipsis bold"))
=== myOutput
```

```ruby
func myOutput(result: [HTMLTableColumn]?) {
  // handle result
}
```

Web page navigation is based on *Actions*, which can be executed explicitly by calling the *start()* method

```swift
let action : Action<HTMLPage> = headless.open(url)

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

# JSON

# Links
link of all headless browsers

# What can be improved?
* HTMLImage
* ScreenCapture

# Author
Mathias Köhnke [@mkoehnke](http://twitter.com/mkoehnke)

# License
Headless is available under the MIT license. See the LICENSE file for more info.

# Recent Changes
The release notes can be found [here](https://github.com/mkoehnke/Headless/releases).
