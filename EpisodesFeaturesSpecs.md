# 🧾 Episodes Feature Specs

### Story: Customer requests to see episodes

### Narrative

```
As a fan of Rick and Morty
I want the app to load episodes from the API
So I can browse the list and view details about each episode
```

#### Scenarios (Acceptance criteria)

```
Given the customer has connectivity
 When the customer requests to see episodes
 Then the app should display the episodes from the remote API
```

```
Given the customer has connectivity
And the API returns invalid data
When the customer requests to see episodes
Then the app should display an error message
```

```
Given the customer doesn't have connectivity
 When the customer requests to see episodes
 Then the app should display an error message
```

---

## Use Cases

### Load Episodes From Remote Use Case

#### Data:
- URL: https://rickandmortyapi.com/api/episode

#### Primary course (happy path):
1. Execute "Load Episodes" command with above URL.
2. System performs a GET request to the URL.
3. System receives a 200 OK response with JSON data.
4. System validates and parses the JSON.
5. System creates episodes from valid data.
6. System delivers episodes.
 
#### Invalid data – error course (sad path):
1. System delivers invalid data error.

#### No connectivity – error course (sad path):
1. System delivers connectivity error.


## Payload contract

```
GET /episode

2xx RESPONSE

{
  "info": {
    "count": 51,
    "pages": 3,
    "next": "https://rickandmortyapi.com/api/episode?page=2",
    "prev": null
  },
  "results": [
    {
      "id": 1,
      "name": "Pilot",
      "air_date": "December 2, 2013",
      "episode": "S01E01",
      "characters": [
        "https://rickandmortyapi.com/api/character/1",
        "https://rickandmortyapi.com/api/character/2"
      ],
      "url": "https://rickandmortyapi.com/api/episode/1",
      "created": "2017-11-10T12:56:33.798Z"
    },
    ...
  ]
}
```
