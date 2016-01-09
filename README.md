# Headless
Headless is an iOS/OSX **web-browser without a graphical user interface**. It was developed as a mere *experiment* in order to familiarize myself with **using proven functional concepts** written in Swift.

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

<img src="https://raw.githubusercontent.com/mkoehnke/Headless/develop/Resources/Headless-Web-Demo.gif?token=ABXNjQVdWqIq9FWdb42o8I09ERYprf7Mks5WmWgPwA%3D%3D" />

#### Automation with Headless

The same navigation process can be reproduced **automatically** within an iOS/OSX app using the chained *Actions* of Headless. In addition, it is now possible to manipulate or display this data in a native way with *UITextfield*, *UIButton* and a *UITableView*. **Take a look at the demo project to see how to use it.**

<img src="https://raw.githubusercontent.com/mkoehnke/Headless/develop/Resources/Headless-Simulator-Demo.gif?token=ABXNjWc-qmO9Vk7DUFWbnG1VE0LNM73Wks5WmWfXwA%3D%3D" />

# Usage
A Headless instance equates to a web session, which can be created using the following line:

```ruby
let browser = Headless(name: "Demo")
```

#### Linking Actions

Web page navigation is based on *Actions*, which can be executed implicitly when linking actions using the **[>>>](#>>>)** operator. All chained actions pass their result to the next action. The **[===](#===)** operator then starts the execution of the action chain. **The following snippet demonstrates how you would use Headless to collect all Provisioning Profiles from the Developer Portal:**

```ruby
    browser.open(url)
>>> browser.get(by: .Id("name"))
>>> browser.setAttribute("value", value: user)
>>> browser.get(by: .Id("password"))
>>> browser.setAttribute("value", value: password)
>>> browser.get(by: .Name("form"))
>>> browser.submit
>>> browser.get(by: .Attribute("href", "/account"))
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

*Actions* can also be started manually by calling the *start()* method:

```ruby
let action : Action<HTMLPage> = browser.open(url)

action.start { result in
    switch result {
    case .Success(let page): // process page
    case .Error(let error):  // handle error
    }
}
```

This is certainly the less complicated way, but you have to write a lot more code, which might become confusing when you want to nest *Actions*.  


## Basic Actions
There are currently a few *Actions* implemented, helping you visit and navigate on a website:

### Open a Website

The returned Headless Action will load and return a HTML or JSON page for the specified URL.
```ruby
func open<T : Page>(url: NSURL) -> Action<T>
```

Optionally, a *PostAction* can be passed. It can be seen as a special wait/validation action, that will be performed after the page has finished loading. See [PostAction](#PostAction) for more information.

```ruby
func open<T : Page>(then: PostAction)(url: NSURL) -> Action<T>
```

### Submit a Form

The returned Headless Action will submit the specified HTML form.
```ruby
func submit<T : Page>(form: HTMLForm) -> Action<T>
```

Optionally, a *PostAction* can be passed. See [PostAction](#PostAction) for more information.
```ruby
func submit<T : Page>(then: PostAction)(form: HTMLForm) -> Action<T>
```

### Click a Link

The returned Headless Action will simulate the click of a HTML link.
```ruby
func click<T: Page>(link : HTMLLink) -> Action<T>
```

Optionally, a *PostAction* can be passed. See [PostAction](#PostAction) for more information.
```ruby
func click<T: Page>(then: PostAction)(link : HTMLLink) -> Action<T>
```

### Find HTML Elements

The returned Headless Action will search the specified HTML page and return the first element matching the generic HTML element type and
the passed [SearchType](SearchType).
```ruby
func get<T: HTMLElement>(by: SearchType<T>)(page: HTMLPage) -> Action<T>
```

The returned Headless Action will search and return all elements matching.
```ruby
func getAll<T: HTMLElement>(by: SearchType<T>)(page: HTMLPage) -> Action<[T]>
```


### Set an Attribute

The returned Headless Action will set or update an existing attribute/value pair on the specified HTMLElement.
```ruby
func setAttribute<T: HTMLElement>(key: String, value: String?)(element: T) -> Action<HTMLPage>
```

### Transform

The returned Headless Action will transform a HTMLElement into another HTMLElement using the specified function *f*.
```ruby
func map<T: HTMLElement, A: HTMLElement>(f: T -> A)(element: T) -> Action<A>
```
## Special Parameters

### 1. PostAction

An wait/validation action that will be performed after the page has finished loading.

#### a. Wait(*seconds*)
The time in seconds that the action will wait (after the page has been loaded) before returning. This is useful in cases where the page loading has been completed, but some JavaScript/Image loading is still in progress.

#### b. Validate(*script*)
The action will complete if the specified JavaScript expression/script returns 'true' or a timeout occurs.

### 2. SearchType

Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.

#### a. Id(*string*)

#### b. Name(*string*)

#### c. Text(*string*)

#### d. Class(*string*)

#### e. Attribute(*string*, *string*)

#### f. XPathQuery(*string*)

## Operators

### >>>
Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.


### ===

Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.

## Advanced Actions

### Batch

The returned Headless Action will make a bulk execution of the specified action with the provided input elements. Once all actions have finished executing, the collected results will be returned.
```ruby
func batch<T, U>(f: T -> Action<U>)(elements: [T]) -> Action<[U]>
```

### Collect

The returned Headless Action will execute the specified action (with the result of the previous action execution as input parameter) until a certain condition is met. Afterwards, it will return the collected action results.
```ruby
func collect<T>(f: T -> Action<T>, until: T -> Bool)(initial: T) -> Action<[T]>
```

### Dump

This command is useful for **debugging**. It prints out the current state of the Headless browser represented as *DOM*.
```ruby
func dump()
```

## HTML Elements

### HTMLPage

Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.

### HTMLElement

The *HTMLElement* class is a base class, which can represent every element in the DOM.

* HTMLForm
* HTMLLink
* HTMLTable
* HTMLTableColumn
* HTMLTableRow

## JSON Elements

### JSONPage

Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.

# Installation
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

# TODOs
* HTMLImage
* ScreenCapture
* More descriptive errors

# Links
link of all headless browsers

# Author
Mathias Köhnke [@mkoehnke](http://twitter.com/mkoehnke)

# License
Headless is available under the MIT license. See the LICENSE file for more info.

# Recent Changes
The release notes can be found [here](https://github.com/mkoehnke/Headless/releases).
