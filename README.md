# LightNetworking

### A simple networking package utilizing async/await that includes optional logging.

## How to use
1. Create an `Endpoint`
2. Initialize `Network`, providing a `baseURL`
3. Call `Network.request()` passing an endpoint
4. Wait for the data to return or an error to be thrown
5. Optionally use JSONParser to decode returned JSON into a decodable data model

```
// 1.
var params = Parameters()
params["userId"] = "ABC-123"

let endpoint = Endpoint(path: "/get_kitties", urlParams: params)

// 3.
let network = Network(baseURL: "https://url-with.com/fake-example")

// 4.
Task {
    do {
        let data = try await network.request(endpoint: endpoint)
        print(data?.prettyPrintedJSONString)
    } catch {
        print(error.localizedDescription)
    }
}

// 5.
JSONParser
```

