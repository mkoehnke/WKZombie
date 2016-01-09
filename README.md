# Headless
Headless is an iOS **web-browser without a graphical user interface**. It was developed as a mere *experiment* in order to familiarize myself with **using proven functional concepts** written in Swift.

It uses [WebKit](https://webkit.org) (WKWebView) for rendering and [hpple](https://github.com/topfunky/hpple) (libxml2) for parsing the HTML content. Furthermore, it has rudimentary support for parsing JSON pages. Chaining asynchronous actions makes the code compact and easy to use.

For more information, see [Usage](#usage).

## Use Cases
* Collect data without an API
* Scraping websites
* Automating interaction of websites
* Manipulation of websites
* Running automated tests
* etc.

## Example
The following example is supposed to demonstrate the headless functionality. Let's assume that we want to **show all iOS Provisioning Profiles in the Apple Developer Portal**.

#### Manual Web-Browser Navigation

When using a common web-browser (e.g. Mobile Safari) on iOS, you would typically type in your credentials, sign in and navigate (via links) to the *Provisioning Profiles* section:

<p align="center">
<img src="https://raw.githubusercontent.com/mkoehnke/Headless/develop/Resources/Headless-Web-Demo.gif?token=ABXNjQVdWqIq9FWdb42o8I09ERYprf7Mks5WmWgPwA%3D%3D" />
</p>

#### Automation with Headless

The same navigation process can be reproduced **automatically** within an iOS app using the chained *Actions* of Headless. In addition, it is now possible to manipulate or display this data in a native way with *UITextfield*, *UIButton* and a *UITableView*. **Take a look at the demo project to see how to use it.**

<p align="center">
<img src="https://raw.githubusercontent.com/mkoehnke/Headless/develop/Resources/Headless-Simulator-Demo.gif?token=ABXNjWc-qmO9Vk7DUFWbnG1VE0LNM73Wks5WmWfXwA%3D%3D" />
</p>

# Usage
A Headless instance equates to a web session, which can be created using the following line:

```ruby
let browser = Headless(name: "Demo")
```

#### Linking Actions

Web page navigation is based on *Actions*, which can be executed implicitly when linking actions using the **[>>>](#>>>)** operator. All chained actions pass their result to the next action. The **[===](#===)** operator then starts the execution of the action chain. **The following snippet demonstrates how you would use Headless to collect all Provisioning Profiles from the Developer Portal:**

```ruby
    browser.open(url)
>>> browser.get(by: .Id("accountname"))
>>> browser.setAttribute("value", value: user)
>>> browser.get(by: .Id("accountpassword"))
>>> browser.setAttribute("value", value: password)
>>> browser.get(by: .Name("form2"))
>>> browser.submit
>>> browser.get(by: .Attribute("href", "/account/"))
>>> browser.click
>>> browser.get(by: .Text("Provisioning Profiles"))
>>> browser.click(then: .Wait(0.5))
>>> browser.getAll(by: .Class("ui-ellipsis bold"))
=== myOutput
```

In order to output or process the collected data, one can either use a closure or implement a custom function taking the Headless optional result as parameter:

```ruby
func myOutput(result: [HTMLTableColumn]?) {
  // handle result
}
```

#### Manual Actions

*Actions* can also be started explicitly by calling the *start()* method:

```ruby
let action : Action<HTMLPage> = browser.open(url)

action.start { result in
    switch result {
    case .Success(let page): // process page
    case .Error(let error):  // handle error
    }
}
```

This is certainly the less complicated, but you have to write a lot more code, which might become confusing when you want to nest *Actions*.  


## Basic Actions
There are currently a few *Actions* implemented, helping you visit and navigate on a website:

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

### Find HTML Elements

### Set an Attribute

### Transform

## Operators

### >>>

### ===

## Advanced Actions

### Batch

### Repeat

## HTML Elements

### HTMLPage

### HTMLForm

### HTMLLink



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
* More descriptive errors

# Author
Mathias Köhnke [@mkoehnke](http://twitter.com/mkoehnke)

# License
Headless is available under the MIT license. See the LICENSE file for more info.

# Recent Changes
The release notes can be found [here](https://github.com/mkoehnke/Headless/releases).
