# LightNetworking

### A simple networking package utilizing async/await that includes optional logging.

## How to use
1. Create a data model that conforms to `Codable`
2. Create an `Endpoint`, passing that data model type when initializing
3. Initialize `Network`, providing a `baseURL`
4. Call `Network.request()` passing an endpoint
5. Wait for the decoded model to return or an error to be thrown.

```
// 1.
struct Coffee: Codable {
    let id: Int
    let name: String
}

// 2.
var params = Parameters()
params["userId"] = "ABC-123"

let endpoint = Endpoint<Coffee>(path: "/get_coffees", urlParams: params)

// 3.
let network = Network(baseURL: "https://url-with.com/fake-example")

// 4.
Task {
    do {
        let coffee = try await network.request(endpoint: endpoint)
        print("Congrats. Your coffee's name is \(coffee.name)")
    } catch {
        print(error.localizedDescription)
    }
}
```
