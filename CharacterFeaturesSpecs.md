# 🧾 Character Feature Specs

## **Story**: Customer requests to see character details

### **Narrative**
> As a fan of Rick and Morty  
> I want to view detailed information about a character  
> So I can learn more about them and their appearances

---

## ✅ **Scenarios (Acceptance Criteria)**

### ✅ Given the customer has connectivity  
When the customer selects a character  
Then the app should display that character’s detailed information from the remote API

### ❌ Given the customer has connectivity  
And the API returns invalid data  
When the customer selects a character  
Then the app should display an error message

### ❌ Given the customer doesn't have connectivity  
When the customer selects a character  
Then the app should display an error message

---

## 🔧 **Use Case**: Load Character From Remote Use Case

### Data:
- Endpoint pattern: `https://rickandmortyapi.com/api/character/{id}`  
- Example: `https://rickandmortyapi.com/api/character/2`

---

### 🟢 Primary Course (Happy Path)
1. Execute "Load Character" command with character ID
2. System performs a `GET` request to the endpoint
3. System receives a `200 OK` response with JSON data
4. System validates and parses the JSON payload
5. System creates a `Character` entity from the valid data
6. System delivers the character to the presentation layer

---

### 🔴 Invalid Data – Sad Path
- The system receives a 200 OK response but with malformed or unexpected data
- System fails to parse the data
- System delivers an `invalid data` error

---

### 🔴 No Connectivity – Sad Path
- Network error (e.g., no internet, timeout, etc.)
- System delivers a `connectivity` error

---

## 📦 **Payload Contract**

### GET `/character/{id}`  
**Example**: `/character/2`

#### ✅ `2xx` RESPONSE

```json
{
  "id": 2,
  "name": "Morty Smith",
  "status": "Alive",
  "species": "Human",
  "type": "",
  "gender": "Male",
  "origin": {
    "name": "Earth",
    "url": "https://rickandmortyapi.com/api/location/1"
  },
  "location": {
    "name": "Earth",
    "url": "https://rickandmortyapi.com/api/location/20"
  },
  "image": "https://rickandmortyapi.com/api/character/avatar/2.jpeg",
  "episode": [
    "https://rickandmortyapi.com/api/episode/1",
    "https://rickandmortyapi.com/api/episode/2"
  ],
  "url": "https://rickandmortyapi.com/api/character/2",
  "created": "2017-11-04T18:50:21.651Z"
}

