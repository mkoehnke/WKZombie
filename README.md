# WKZombie
[![Twitter: @mkoehnke](https://img.shields.io/badge/contact-@mkoehnke-blue.svg?style=flat)](https://twitter.com/mkoehnke)
[![Version](https://img.shields.io/cocoapods/v/WKZombie.svg?style=flat)](http://cocoadocs.org/docsets/WKZombie)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/cocoapods/l/WKZombie.svg?style=flat)](http://cocoadocs.org/docsets/WKZombie)
[![Platform](https://img.shields.io/cocoapods/p/WKZombie.svg?style=flat)](http://cocoadocs.org/docsets/WKZombie)
[![Build Status](https://travis-ci.org/mkoehnke/WKZombie.svg?branch=master)](https://travis-ci.org/mkoehnke/WKZombie)

[<img align="left" src="https://raw.githubusercontent.com/mkoehnke/WKZombie/develop/Resources/Logo.png" hspace="30" width="135px">](#logo)

WKZombie is an **iOS/OSX web-browser without a graphical user interface**. It was developed as an experiment in order to familiarize myself with **using functional concepts** written in Swift (>= 2.2).

It incorporates [WebKit](https://webkit.org) (WKWebView) for rendering and [hpple](https://github.com/topfunky/hpple) (libxml2) for parsing the HTML content. In addition, it has rudimentary support for parsing and decoding [JSON elements](#json-elements). **Chaining asynchronous actions makes the code compact and easy to use.**

For more information, see [Usage](#usage).

## Use Cases
There are many use cases for a Headless Browser. Some of them are:

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

<img src="https://raw.githubusercontent.com/mkoehnke/WKZombie/master/Resources/WKZombie-Web-Demo.gif" />

#### Automation with WKZombie

The same navigation process can be reproduced **automatically** within an iOS/OSX app linking WKZombie *Actions*. In addition, it is now possible to manipulate or display this data in a native way with *UITextfield*, *UIButton* and a *UITableView*. **Take a look at the demo project to see how to use it.**

<img src="https://raw.githubusercontent.com/mkoehnke/WKZombie/master/Resources/WKZombie-Simulator-Demo.gif" />

# Getting Started

The best way to get started is to look at the sample project. Just run the following commands in your shell and you're good to go:

```bash
$ cd Example
$ pod install
$ open Example.xcworkspace
```

__Note:__ You will need CocoaPods 1.0 beta4 or higher.

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
>>> browser.getAll(by: .Class("ui-ellipsis"))
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
func open<T : Page>(then: PostAction) -> (url: NSURL) -> Action<T>
```

### Get the current Website

The returned WKZombie Action will retrieve the current page.

```ruby
func inspect<T: Page>() -> Action<T>
```

### Submit a Form

The returned WKZombie Action will submit the specified HTML form.
```ruby
func submit<T : Page>(form: HTMLForm) -> Action<T>
```

Optionally, a *PostAction* can be passed. See [PostAction](#special-parameters) for more information.
```ruby
func submit<T : Page>(then: PostAction) -> (form: HTMLForm) -> Action<T>
```

### Click a Link / Press a Button

The returned WKZombie Actions will simulate the interaction with a HTML link/button.
```ruby
func click<T: Page>(link : HTMLLink) -> Action<T>
func press<T: Page>(button : HTMLButton) -> Action<T>
```

Optionally, a *PostAction* can be passed. See [PostAction](#Special- Parameters) for more information.
```ruby
func click<T: Page>(then: PostAction) -> (link : HTMLLink) -> Action<T>
func press<T: Page>(then: PostAction) -> (button : HTMLButton) -> Action<T>
```

**Note: HTMLButton only works if the "onClick" HTML-Attribute is present. If you want to submit a HTML form, you should use [Submit](#submit-a-form) instead.**

### Find HTML Elements

The returned WKZombie Action will search the specified HTML page and return the first element matching the generic HTML element type and passed [SearchType](#special-parameters).
```ruby
func get<T: HTMLElement>(by: SearchType<T>) -> (page: HTMLPage) -> Action<T>
```

The returned WKZombie Action will search and return all elements matching.
```ruby
func getAll<T: HTMLElement>(by: SearchType<T>) -> (page: HTMLPage) -> Action<[T]>
```


### Set an Attribute

The returned WKZombie Action will set or update an existing attribute/value pair on the specified HTMLElement.
```ruby
func setAttribute<T: HTMLElement>(key: String, value: String?) -> (element: T) -> Action<HTMLPage>
```

### Execute JavaScript

The returned WKZombie Action will execute a JavaScript string.

```ruby
func execute(script: JavaScript) -> (page: HTMLPage) -> Action<JavaScriptResult>
```

For example, the following example shows how retrieve the title of the currently loaded website using the *execute()* method:

```ruby
    browser.inspect()
>>> browser.execute("document.title")
=== myOutput
```

```ruby
func myOutput(result: JavaScriptResult?) {
  // handle result
}
```

### Fetching

Some HTMLElements, that implement the _HTMLFetchable_ protocol (e.g. _HTMLLink_ or _HTMLImage_), contain attributes like _"src"_ or _"href"_, that link to remote objects or data.
The following method returns a WKZombie Action that can conveniently download this data:
```ruby
func fetch<T: HTMLFetchable>(fetchable: T) -> Action<T>
```

Once the _fetch_ method has been executed, the data can be retrieved and __converted__. The following example shows how to convert data, fetched from a link, into an UIImage:
```ruby
let image : UIImage? = link.fetchedContent()
```

Fetched data can be converted into types, that implement the _HTMLFetchableContent_ protocol. The following types are currently supported:

- UIImage / NSImage
- NSData

__Note:__ See the OSX example for more info on how to use this.

### Transform

The returned WKZombie Action will transform a WKZombie object into another object using the specified function *f*.
```ruby
func map<T, A>(f: T -> A) -> (element: T) -> Action<A>
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
**Contains** (String, String)  | Returns all elements with an attribute containing the specified value.
**XPathQuery** (String)        | Returns all elements that match the specified XPath query.

## Operators

The following Operators can be applied to *Actions*, which makes chained *Actions* easier to read:

Operator       | Description
-------------- | -------------
**>>>**        | This Operator equates to the *andThen()* method. Here, the left-hand side *Action* will be started and the result is used as parameter for the right-hand side *Action*. **Note:** If the right-hand side *Action* doesn't take a parameter, the result of the left-hand side *Action* will be ignored and not passed.
**===**        | This Operator starts the left-hand side *Action* and passes the result as **Optional** to the function on the right-hand side.

## Advanced Actions

### Batch

The returned WKZombie Action will make a bulk execution of the specified action function *f* with the provided input elements. Once all actions have finished executing, the collected results will be returned.
```ruby
func batch<T, U>(f: T -> Action<U>) -> (elements: [T]) -> Action<[U]>
```

### Collect

The returned WKZombie Action will execute the specified action (with the result of the previous action execution as input parameter) until a certain condition is met. Afterwards, it will return the collected action results.
```ruby
func collect<T>(f: T -> Action<T>, until: T -> Bool) -> (initial: T) -> Action<[T]>
```

### Dump

This command is useful for **debugging**. It prints out the current state of the WKZombie browser represented as *DOM*.
```ruby
func dump()
```

### Clear Cache and Cookies

Clears the cache/cookie data (such as login data, etc).
```ruby
func clearCache()
```

### Logging

WKZombie logging can be enabled or disabled by setting the following _Logger_ variable:

```ruby
Logger.enabled = false
```

## HTML Elements

When using WKZombie, the following classes are involved when interacting with websites:

### HTMLPage

This class represents a **read-only** DOM of a website. It allows you to search for HTML elements using the [SearchType](#special-parameters) parameter.

### HTMLElement

The *HTMLElement* class is a **base class for all elements in the DOM**. It allows you to inspect attributes or the inner content (e.g. text) of that element. Currently, there are 7 subclasses with additional element-specific methods and variables available:

* HTMLForm
* HTMLLink
* HTMLButton
* HTMLImage
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

# Installation

## [CocoaPods](http://cocoapods.org)

To integrate **WKZombie** into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
use_frameworks!

pod 'WKZombie'
```

Then, run the following command:

```bash
$ pod install
```

## [Carthage](http://github.com/Carthage/Carthage)

To integrate `WKZombie` into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "mkoehnke/WKZombie"
```

# Contributing

See the CONTRIBUTING file for how to help out. You'll need to run

```bash
$ Scripts/setup-framework.sh
```

in the root WKZombie directory to set up a buildable framework project (`WKZombie.xcworkspace`).

# TODOs
* More Unit Tests
* More examples
* Replace hpple with more 'Swifty' implementation
* ScreenCapture
* More descriptive errors

# Author
Mathias Köhnke [@mkoehnke](http://twitter.com/mkoehnke)

# More Resources
* [A list of (almost) all headless web browsers in existence](https://github.com/dhamaniasad/HeadlessBrowsers)

# Attributions
* [Efficient JSON in Swift with Functional Concepts and Generics — Tony DiPasquale](https://robots.thoughtbot.com/efficient-json-in-swift-with-functional-concepts-and-generics)
* [Back to the Futures — Javier Soto](https://speakerdeck.com/javisoto/back-to-the-futures)

# License
WKZombie is available under the MIT license. See the LICENSE file for more info.

# Recent Changes
The release notes can be found [here](https://github.com/mkoehnke/WKZombie/releases).
