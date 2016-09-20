import Foundation
import WKZombie

// Parameters
let url = URL(string: "https://developer.apple.com/membercenter/index.action")!
let arguments = CommandLine.arguments
let user = arguments[1]
let password = arguments[2]
var shouldKeepRunning = true

func handleResult(_ result: Result<[HTMLTableRow]>) {
    shouldKeepRunning = false
    switch result {
    case .success(let value): handleSuccess(result: value)
    case .error(let error): handleError(error: error)
    }
}

// Result handling
func handleSuccess(result: [HTMLTableRow]?) {
    print("\n")
    print("PROVISIONING PROFILES:")
    print("======================")
    
    if let columns = result?.flatMap({ $0.columns?.first }) {
        for column in columns {
            if let element = column.children()?.first as HTMLElement?, let text = element.text {
                print(text)
            }
        }
    } else {
        print("Nothing found.")
    }
}

func handleError(error: ActionError) {
    print(error)
}

// WKZombie Actions
    open(url)
>>> get(by: .id("accountname"))
>>> setAttribute("value", value: user)
>>> get(by: .id("accountpassword"))
>>> setAttribute("value", value: password)
>>> get(by: .name("form2"))
>>> submit(then: .wait(2.0))
>>> get(by: .contains("href", "/account/"))
>>> click(then: .wait(2.5))
>>> getAll(by: .contains("class", "row-"))
=== handleResult

// Keep script running until actions are finished
let theRL = RunLoop.current
while shouldKeepRunning && theRL.run(mode: .defaultRunLoopMode, before: .distantFuture) { }
