# WKZombie
WKZombie is an **iOS web-browser without a graphical user interface**. It was developed as an experiment in order to familiarize myself with **using functional concepts** written in Swift.

It incorporates [WebKit](https://webkit.org) (WKWebView) for rendering and [hpple](https://github.com/topfunky/hpple) (libxml2) for parsing the HTML content. In addition, it has rudimentary support for parsing and decoding [JSON elements](#json-elements). **Chaining asynchronous actions makes the code compact and easy to use.**

For more information, see [Usage](#usage).

## Use Cases
There are many use cases for a WKZombie Browser. Some of them are:

* Collect data without an API
* Scraping websites
* Automating interaction of websites
* Manipulation of websites
* Running automated tests
* etc.

## Example
The following example is supposed to demonstrate the WKZombie functionality. Let's assume that we want to **show all iOS Provisioning Profiles in the Apple Developer Portal**.

#### Manual Web-Browser Navigation

When using a common web-browser (e.g. Mobile Safari) on iOS, you would typically type in your credentials, sign in and navigate (via links) to the *Provisioning Profiles* section:

<img src="https://raw.githubusercontent.com/mkoehnke/WKZombie/develop/Resources/WKZombie-Web-Demo.gif?token=ABXNjQVdWqIq9FWdb42o8I09ERYprf7Mks5WmWgPwA%3D%3D" />

#### Automation with WKZombie

The same navigation process can be reproduced **automatically** within an iOS app linking WKZombie *Actions*. In addition, it is now possible to manipulate or display this data in a native way with *UITextfield*, *UIButton* and a *UITableView*. **Take a look at the demo project to see how to use it.**

<img src="https://raw.githubusercontent.com/mkoehnke/WKZombie/develop/Resources/WKZombie-Simulator-Demo.gif?token=ABXNjWc-qmO9Vk7DUFWbnG1VE0LNM73Wks5WmWfXwA%3D%3D" />

# Usage
A WKZombie instance equates to a web session, which can be created using the following line:

```ruby
let browser = WKZombie(name: "Demo")
```

#### Chaining Actions

Web page navigation is based on *Actions*, that can be executed **implicitly** when chaining actions using the **[>>>](#operators)** operator. All chained actions pass their result to the next action. The **[===](#operators)** operator then starts the execution of the action chain. **The following snippet demonstrates how you would use WKZombie to collect all Provisioning Profiles from the Developer Portal:**

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

In order to output or process the collected data, one can either use a closure or implement a custom function taking the WKZombie optional result as parameter:

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

This is certainly the less complicated way, but you have to write a lot more code, which might become confusing when you want to execute *Actions* successively.  


## Basic Actions
There are currently a few *Actions* implemented, helping you visit and navigate within a website:

### Open a Website

The returned WKZombie Action will load and return a HTML or JSON page for the specified URL.
```ruby
func open<T : Page>(url: NSURL) -> Action<T>
```

Optionally, a *PostAction* can be passed. This is a special wait/validation action, that is performed after the page has finished loading. See [PostAction](#special-parameters) for more information.

```ruby
func open<T : Page>(then: PostAction)(url: NSURL) -> Action<T>
```

### Submit a Form

The returned WKZombie Action will submit the specified HTML form.
```ruby
func submit<T : Page>(form: HTMLForm) -> Action<T>
```

Optionally, a *PostAction* can be passed. See [PostAction](#special-parameters) for more information.
```ruby
func submit<T : Page>(then: PostAction)(form: HTMLForm) -> Action<T>
```

### Click a Link

The returned WKZombie Action will simulate the click of a HTML link.
```ruby
func click<T: Page>(link : HTMLLink) -> Action<T>
```

Optionally, a *PostAction* can be passed. See [PostAction](#Special- Parameters) for more information.
```ruby
func click<T: Page>(then: PostAction)(link : HTMLLink) -> Action<T>
```

### Find HTML Elements

The returned WKZombie Action will search the specified HTML page and return the first element matching the generic HTML element type and passed [SearchType](#special-parameters).
```ruby
func get<T: HTMLElement>(by: SearchType<T>)(page: HTMLPage) -> Action<T>
```

The returned WKZombie Action will search and return all elements matching.
```ruby
func getAll<T: HTMLElement>(by: SearchType<T>)(page: HTMLPage) -> Action<[T]>
```


### Set an Attribute

The returned WKZombie Action will set or update an existing attribute/value pair on the specified HTMLElement.
```ruby
func setAttribute<T: HTMLElement>(key: String, value: String?)(element: T) -> Action<HTMLPage>
```

### Transform

The returned WKZombie Action will transform a HTMLElement into another HTMLElement using the specified function *f*.
```ruby
func map<T: HTMLElement, A: HTMLElement>(f: T -> A)(element: T) -> Action<A>
```
## Special Parameters

### 1. PostAction

Some *Actions*, that incorporate a (re-)loading of webpages (e.g. [open](#open-a-website), [submit](#submit-a-form), etc.), have *PostActions* available. A *PostAction* is a wait or validation action, that will be performed after the page has finished loading:

PostAction                | Description
------------------------- | -------------
**Wait** (Seconds)        | The time in seconds that the action will wait (after the page has been loaded) before returning. This is useful in cases where the page loading has been completed, but some JavaScript/Image loading is still in progress.
**Validate** (Javascript) | The action will complete if the specified JavaScript expression/script returns 'true' or a timeout occurs.

### 2. SearchType

In order to find certain HTML elements within a page, you have to specify a *SearchType*. The return type of [get()](#find-html-elements) and [getAll()](#find-html-elements) is generic and determines which tag should be searched for. For instance, the following would return all links with the class *book*:

```ruby
let books : Action<HTMLLink> = browser.getAll(by: .Class("book"))(page: htmlPage)
```

The following 6 types are currently available and supported:

SearchType                     | Description
------------------------------ | -------------
**Id** (String)                | Returns an element that matches the specified id.
**Name** (String)              | Returns all elements matching the specified value for their *name* attribute.
**Text** (String)              | Returns all elements with inner content, that *contain* the specified text.
**Class** (String)             | Returns all elements that match the specified class name.
**Attribute** (String, String) | Returns all elements that match the specified attribute name/value combination.
**XPathQuery** (String)        | Returns all elements that match the specified XPath query.

## Operators

The following Operators can be applied to *Actions*, which makes chained *Actions* easier to read:

Operator       | Description
-------------- | -------------
**>>>**        | This Operator equates to the *andThen()* method. Here, the left-hand side *Action* will be started and the result is used as parameter for the right-hand side *Action*.
**===**        | This Operator starts the left-hand side *Action* and passes the result as **Optional** to the function on the right-hand side.

## Advanced Actions

### Batch

The returned WKZombie Action will make a bulk execution of the specified action function *f* with the provided input elements. Once all actions have finished executing, the collected results will be returned.
```ruby
func batch<T, U>(f: T -> Action<U>)(elements: [T]) -> Action<[U]>
```

### Collect

The returned WKZombie Action will execute the specified action (with the result of the previous action execution as input parameter) until a certain condition is met. Afterwards, it will return the collected action results.
```ruby
func collect<T>(f: T -> Action<T>, until: T -> Bool)(initial: T) -> Action<[T]>
```

### Dump

This command is useful for **debugging**. It prints out the current state of the WKZombie browser represented as *DOM*.
```ruby
func dump()
```

## HTML Elements

When using WKZombie, the following classes are involved when interacting with websites:

### HTMLPage

This class represents a **read-only** DOM of a website. It allows you to search for HTML elements using the [SearchType](#special-parameters) parameter.

### HTMLElement

The *HTMLElement* class is a **base class for all elements in the DOM**. It allows you to inspect attributes or the inner content (e.g. text) of that element. Currently, there are 5 subclasses with additional element-specific methods and variables available:

* HTMLForm
* HTMLLink
* HTMLTable
* HTMLTableColumn
* HTMLTableRow

**Additional subclasses can be easily implemented and might be added in the future.**

## JSON Elements

As mentioned above, WKZombie as rudimentary support for JSON documents.

### Methods and Protocols

For parsing and decoding JSON, the following methods and protocols are available:

#### Parsing
The returned WKZombie Action will parse NSData and create a JSON object.

```ruby
func parse<T: JSON>(data: NSData) -> Action<T>
```

#### Decoding
The following methods return a WKZombie Action, that will take a *JSONParsable* (Array, Dictionary and JSONPage) and decode it into a Model object. This particular Model class has to implement the [*JSONDecodable*](#jsondecodable) protocol.

```ruby
func decode<T : JSONDecodable>(element: JSONParsable) -> Action<T>
```

```ruby
func decode<T : JSONDecodable>(array: JSONParsable) -> Action<[T]>
```

#### JSONDecodable
This protocol must be implemented by each class, that is supposed to support JSON decoding.
The implementation will take a *JSONElement* (Dictionary\<String : AnyObject\>) and create an object instance of that class.

```ruby
static func decode(json: JSONElement) -> Self?
```


### Example

The following example shows how to use JSON parsing/decoding in conjunction with WKZombie:

```ruby
    browser.open(bookURL)
>>> browser.decode
=== myOutput
```

```ruby
func myOutput(result: Book?) {
  // handle result
}
```

<!---
# Installation
## CocoaPods
[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate the WKZombie into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!

pod 'WKZombie'
```

Then, run the following command:

```bash
$ pod install
```
-->

# TODOs
* Cocoapods
* run() method for executing Javascript
* clear() method for deleting all Cookies
* HTMLImage
* ScreenCapture
* More descriptive errors

# Author
Mathias Köhnke [@mkoehnke](http://twitter.com/mkoehnke)

# More Resources
* [A list of (almost) all WKZombie web browsers in existence](https://github.com/dhamaniasad/WKZombieBrowsers)

# Attributions
* [Efficient JSON in Swift with Functional Concepts and Generics — Tony DiPasquale](https://robots.thoughtbot.com/efficient-json-in-swift-with-functional-concepts-and-generics)
* [Back to the Futures — Javier Soto](https://speakerdeck.com/javisoto/back-to-the-futures)

# License
WKZombie is available under the MIT license. See the LICENSE file for more info.

# Recent Changes
The release notes can be found [here](https://github.com/mkoehnke/WKZombie/releases).
