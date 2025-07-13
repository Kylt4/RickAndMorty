
# 📚 Documentation: Modular Architecture in `RickAndMortyApp`

---

## 1. 🔍 Code Overview

This project demonstrates a clean, modular SwiftUI architecture to build a Rick & Morty app with reusable components and well-isolated concerns.

Key ideas:

- 🧩 **Modular composition:** `@main` composes the app by injecting dependencies and composing views from dedicated builders.
- 🔨 **Builders:** Factories like `CharacterViewBuilder` and `EpisodesViewBuilder` encapsulate view and ViewModel creation.
- 🗂️ **Caching:** `CharacterViewCache` holds reusable ViewModels to preserve state across SwiftUI view recreations (e.g. in lazy stacks).

---

## 2. 🧩 Architecture Principles

- **Modularity**  
  Components are split into small focused units (loaders, ViewModels, views) making the code easier to understand and maintain.

- **Dependency Injection**  
  Clients, caches, and closures are passed explicitly, enhancing testability and flexibility.

- **Separation of Concerns**  
  - Builders handle construction logic  
  - ViewModels manage UI state and presentation  
  - Loaders fetch data asynchronously

- **State Preservation**  
  Using a cache for ViewModels ensures that UI state is stable even if SwiftUI destroys and recreates views (like in `LazyHStack`).
  
- **Pagination in @main**  
  Pagination is implemented using recursion in the app's main entry point rather than creating a new module or use case.  
  This is a **composition detail** that doesn’t need to be abstracted with more modules. The approach favors simplicity and clarity, since recursion fits perfectly with declarative SwiftUI and avoids unnecessary indirection.

---

## 3. 🌟 Design Patterns Used

| Pattern         | Usage example                                            | Benefits                                         |
|-----------------|----------------------------------------------------------|-------------------------------------------------|
| Factory / Builder | `CharacterViewBuilder`, `EpisodesViewBuilder`           | Encapsulates creation of views and dependencies |
| Adapter         | `LoadResourcePresentationAdapter`                        | Decouples loaders from presentation logic       |
| Decorator       | `RemoteImageDataLoaderWithSomeFailure`                   | Dynamically extends loader behavior (simulate errors) |
| Cache           | `CharacterViewCache`                                     | Reuse ViewModels to persist state across views  |
| Dependency Injection | Injecting HTTP client and caches                        | Enhances modularity and testability              |

---

## 4. 🧑‍💻 SOLID Principles Breakdown

### S — Single Responsibility Principle (SRP)  
- Each class has one responsibility:  
  - Builders build  
  - Loaders load  
  - ViewModels transform and hold UI state  
  - Cache stores ViewModels  

### O — Open/Closed Principle (OCP)  
- Easy to extend by adding new builders, loaders, or decorators without modifying existing code.

### L — Liskov Substitution Principle (LSP)  
- Protocols and adapters ensure interchangeable components (e.g. different loaders can be swapped).

### I — Interface Segregation Principle (ISP)  
- Interfaces are narrow and focused (e.g. loaders only expose `load()`).

### D — Dependency Inversion Principle (DIP)  
- High-level modules depend on abstractions (protocols) rather than concretions.

---


# 5. 📈 Tracking & Event Composition

### Tracking with Composable Delegates

The app uses a powerful delegate composition pattern to handle tracking alongside the main business logic without coupling concerns.

**Example:**

```swift
protocol LoadEpisodeDelegate: LoadResourceDelegate where Item == PageEpisodeModels {}
extension EpisodesViewModel: LoadEpisodeDelegate {}

final class EpisodeResourceDelegateComposer: LoadEpisodeDelegate {
    private let delegates: [any LoadEpisodeDelegate]

    init(delegates: [any LoadEpisodeDelegate]) {
        self.delegates = delegates
    }

    func didStartLoading() {
        delegates.forEach { $0.didStartLoading() }
    }

    func didFinishLoading(with error: Error) {
        delegates.forEach { $0.didFinishLoading(with: error) }
    }

    func didFinishLoading(with item: PageEpisodeModels) {
        delegates.forEach { $0.didFinishLoading(with: item) }
    }
}

class AnalyticsTracker: LoadEpisodeDelegate {
    func didStartLoading() {
        print("[ANALYTICS] - TRACKING: Start loading episodes")
    }

    func didFinishLoading(with error: Error) {
        print("[ANALYTICS] - TRACKING: Finish loading episodes with \(error.localizedDescription)")
    }

    func didFinishLoading(with item: PageEpisodeModels) {
        print("[ANALYTICS] - TRACKING: Finish loading episodes with \(item.results.count)")
    }
}

final class FirebaseTracker: LoadEpisodeDelegate {
    func didStartLoading() {
        print("[FIREBASE] - TRACKING: Start loading episodes")
    }
    
    func didFinishLoading(with error: Error) {
        print("[FIREBASE] - TRACKING: Finish loading episodes with \(error.localizedDescription)")
    }

    func didFinishLoading(with item: PageEpisodeModels) {
        print("[FIREBASE] - TRACKING: Finish loading episodes with \(item.results.count)")
    }
}
```

### 🚀 Why is this powerful?

- **Decoupling:** Tracking logic is completely separate from UI and business logic.
- **Composable:** Multiple trackers can be combined easily using `EpisodeResourceDelegateComposer`.
- **Reusable:** Trackers conform to the same protocol, so they can be added or removed without changing existing code.
- **Single Responsibility:** Each tracker focuses only on its own concern (analytics, firebase, etc.).
- **Extensible:** New tracking implementations can be added later without modification to core loading or view code.
- **Cleaner main logic:** The `EpisodesViewBuilder` composes these trackers with the main `EpisodesViewModel` delegate seamlessly, preserving modularity.
**Example integration in `EpisodesViewBuilder`:**

```swift
private static func makeComposer(viewModel: any LoadEpisodeDelegate) -> EpisodeResourceDelegateComposer {
    return EpisodeResourceDelegateComposer(delegates: [AnalyticsTracker(), FirebaseTracker(), viewModel])
}
```

This approach shows how to elegantly track app events while maintaining a clean architecture and respecting SOLID principles.


## 6. 🚀 Why this architecture is powerful

- ✅ Encourages **reusable and testable code**  
- ✅ Promotes **clear boundaries** between UI, state, and network logic  
- ✅ Enables **state preservation** in SwiftUI even when views are frequently recreated  
- ✅ Facilitates **easy maintenance** and scalability for growing apps  
- ✅ Works well with Swift concurrency and async/await

---

## 7. 📂 Project Structure Highlights

- `RickAndMortyApp.swift` — App entry point, wires up dependencies and composes views.
- `CharacterViewBuilder.swift` — Builds Character views and ViewModels.
- `EpisodesViewBuilder.swift` — Builds Episodes views.
- `EpisodeResourceDelegateComposer` - Compose Trackers with ViewModels
- `CharacterViewCache.swift` — Caches Character ViewModels.
- `LoadResourcePresentationAdapter.swift` — Adapts async loaders to ViewModels or Presenters.

---

## 8. 📌 Summary

By using modular **builders**, **adapters**, and **caching**, this architecture allows SwiftUI views to be composed declaratively with stable state, maximizing maintainability and scalability.

This design respects SOLID principles and leverages common design patterns, making it a solid foundation for complex, real-world SwiftUI applications.

---

# [Project GitHub](https://github.com/Kylt4/RickAndMorty/tree/main)

