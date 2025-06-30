# 📸 RemoteImageDataLoader

`RemoteImageDataLoader` est un composant responsable du chargement asynchrone de données d’image à partir d’une URL distante via un client HTTP. Il gère les erreurs de connectivité et de validation de réponse, et retourne les données binaires d’image si la requête est réussie.

---

## ✅ Fonctionnalités

- Envoie une requête HTTP GET à une URL donnée via un `HTTPClient`
- Utilise `async/await` pour des appels réseau non bloquants
- Retourne les données (`Data`) d’image lorsque la réponse HTTP est valide (`200`)
- Gère les erreurs suivantes via un enum `RemoteLoaderError` :
  - `.connectivity` en cas d’erreur réseau (client error)
  - `.invalidData` en cas de réponse HTTP invalide ou d'un autre code que 200

---

## 🔍 Cas testés

### Initialisation

- [x] Ne déclenche **aucune requête réseau** à l'initialisation

### Chargement

- [x] Envoie une requête GET vers l’URL fournie lors de `load()`
- [x] Envoie une requête **à chaque appel** de `load()` (pas de mise en cache interne)

### Erreurs

- [x] Retourne `.connectivity` en cas d'erreur client (ex: pas de réseau)
- [x] Retourne `.invalidData` pour toute réponse HTTP avec un code ≠ 200

### Succès

- [x] Retourne les données d’image (`Data`) si le statut HTTP est 200 — aucune validation de format binaire (ex: PNG/JPEG)

---

## 📦 Dépendances

- `HTTPClient` : abstraction réseau utilisée pour exécuter la requête HTTP
- `RemoteLoaderError` : enum d’erreur partagée avec d'autres loaders distants (réutilisé)

---

## 🧪 Tests

Les tests utilisent un `HTTPClientSpy` pour capturer les appels et simuler des réponses.  
Chaque test est isolé, ne fait pas d’appel réseau réel, et couvre :

- La logique de requête
- Le comportement sur erreur
- La validité du flux asynchrone

---

## Exemple d'utilisation

```swift
let loader = RemoteImageDataLoader(url: imageURL, client: URLSessionHTTPClient())
let data = try await loader.load()
// Utilisez les données d’image (ex: UIImage(data: data) sur iOS)
```

---


