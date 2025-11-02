# 🔌 Backend API Integration Guide

## ✅ Changes Completed

### Removed Direct Gemini API Integration
All AI features now use backend API endpoints instead of direct Gemini API calls.

---

## 📋 Modified Files

### 1. **lib/services/gemini_service.dart** → **AIService**
- **Old**: Direct Gemini API integration
- **New**: Backend API calls with mock fallback
- **Configuration**:
  ```dart
  static const String _backendUrl = 'https://your-backend.com/api/ai';
  static const bool _useBackend = false; // Set to true when backend is ready
  ```

### 2. **lib/services/chat_service.dart** → **ChatService**
- **Old**: Mock responses only
- **New**: Backend API ready with mock fallback
- **Configuration**:
  ```dart
  static const String _backendUrl = 'https://your-backend.com/api/chat';
  static const bool _useBackend = false; // Set to true when backend is ready
  ```

### 3. **lib/config.dart**
- **Removed**: `geminiApiKey`
- **Added**: `backendApiUrl` for backend API configuration
- **Environment Variable**: `BACKEND_API_URL`

### 4. **pubspec.yaml**
- **Removed**: `google_generative_ai: ^0.4.6`
- **Benefit**: Smaller bundle size, no Gemini dependency

### 5. **.vscode/launch.json**
- **Removed**: `GEMINI_API_KEY`
- **Added**: `BACKEND_API_URL`

---

## 🎯 Backend API Specifications

### Endpoint 1: AI Chat

**URL**: `POST /api/ai/chat`

**Request**:
```json
{
  "message": "How can I reduce the budget?",
  "context": "Destination: Paris\nDuration: 5 days\nBudget: ₹50000\nThemes: culture, food",
  "timestamp": "2025-11-02T10:30:00.000Z"
}
```

**Response**:
```json
{
  "response": "To reduce your budget for Paris, consider: 1) Stay in budget hotels or hostels 2) Use public transport 3) Try local cafes instead of restaurants 4) Visit free museums on first Sundays",
  "timestamp": "2025-11-02T10:30:02.000Z"
}
```

**Alternative Response Format**:
```json
{
  "message": "Budget tips for Paris...",
  "suggestions": ["Hotel tip", "Food tip", "Transport tip"]
}
```

---

### Endpoint 2: Chat Service

**URL**: `POST /api/chat/send`

**Request**:
```json
{
  "message": "What are the best places to visit?",
  "userId": "user123",
  "sessionId": "session456",
  "timestamp": "2025-11-02T10:30:00.000Z"
}
```

**Response**:
```json
{
  "reply": "Based on your interests, I recommend visiting the Eiffel Tower, Louvre Museum, and Notre-Dame Cathedral. Would you like more details about any of these?",
  "messageId": "msg789",
  "timestamp": "2025-11-02T10:30:02.000Z"
}
```

---

### Endpoint 3: Itinerary Generation (Already Configured)

**URL**: `POST /api/generate-itinerary`

**Request**:
```json
{
  "destination": "Paris",
  "days": 5,
  "budget": 50000,
  "themes": ["culture", "food"]
}
```

**Response**: See `lib/services/ai_service.dart` for complete JSON schema

---

## 🚀 How to Enable Backend Integration

### Step 1: Deploy Your Backend API

Your backend should implement the endpoints above. Example tech stacks:
- **Python**: Flask/FastAPI + OpenAI/Gemini/Claude
- **Node.js**: Express + LangChain
- **Java**: Spring Boot + AI services

### Step 2: Update Backend URL

**Option 1: Environment Variable (Recommended)**
```powershell
# In .env.local
BACKEND_API_URL=https://your-backend.com/api
```

**Option 2: Update launch.json**
```json
"--dart-define=BACKEND_API_URL=https://your-backend.com/api"
```

**Option 3: Hardcode (Development Only)**
```dart
// lib/services/gemini_service.dart
static const String _backendUrl = 'https://your-backend.com/api/ai';
```

### Step 3: Enable Backend Mode

**In `lib/services/gemini_service.dart`**:
```dart
static const bool _useBackend = true; // Change from false to true
```

**In `lib/services/chat_service.dart`**:
```dart
static const bool _useBackend = true; // Change from false to true
```

### Step 4: Restart the App

```powershell
flutter clean
flutter pub get
flutter run -d chrome
```

---

## 🧪 Testing

### Test Mock Mode (Default)
```powershell
flutter run -d chrome
```
- ✅ Uses mock responses
- ✅ No backend required
- ✅ Good for UI testing

### Test Backend Mode
1. Set `_useBackend = true` in both service files
2. Ensure backend is running
3. Run the app
4. Test chat functionality

---

## 📊 Backend API Authentication (Optional)

If your backend requires authentication, update the services:

```dart
// lib/services/gemini_service.dart
Future<String> sendMessage(String message, String tripContext) async {
  final response = await http.post(
    Uri.parse('$_backendUrl/chat'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $userToken', // Add auth token
    },
    body: json.encode({...}),
  );
}
```

---

## 🔐 CORS Configuration (Required for Web)

Your backend must allow CORS from your Flutter web app:

**Python (Flask)**:
```python
from flask_cors import CORS
app = Flask(__name__)
CORS(app, origins=["http://localhost:*", "https://yourdomain.com"])
```

**Node.js (Express)**:
```javascript
const cors = require('cors');
app.use(cors({
  origin: ['http://localhost:*', 'https://yourdomain.com']
}));
```

**Spring Boot**:
```java
@CrossOrigin(origins = {"http://localhost:*", "https://yourdomain.com"})
```

---

## 📈 Backend API Examples

### Python + OpenAI Example

```python
from flask import Flask, request, jsonify
import openai

app = Flask(__name__)
openai.api_key = "your-openai-key"

@app.route('/api/ai/chat', methods=['POST'])
def ai_chat():
    data = request.json
    message = data['message']
    context = data['context']
    
    response = openai.ChatCompletion.create(
        model="gpt-3.5-turbo",
        messages=[
            {"role": "system", "content": f"You are a travel assistant. Trip context: {context}"},
            {"role": "user", "content": message}
        ]
    )
    
    return jsonify({
        'response': response.choices[0].message.content,
        'timestamp': datetime.now().isoformat()
    })

if __name__ == '__main__':
    app.run(port=5000)
```

### Node.js + OpenAI Example

```javascript
const express = require('express');
const OpenAI = require('openai');

const app = express();
const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });

app.use(express.json());

app.post('/api/ai/chat', async (req, res) => {
  const { message, context } = req.body;
  
  const completion = await openai.chat.completions.create({
    model: "gpt-3.5-turbo",
    messages: [
      { role: "system", content: `You are a travel assistant. Trip context: ${context}` },
      { role: "user", content: message }
    ]
  });
  
  res.json({
    response: completion.choices[0].message.content,
    timestamp: new Date().toISOString()
  });
});

app.listen(5000, () => console.log('Backend running on port 5000'));
```

---

## ✅ Current Status

### What Works Now (Mock Mode):
- ✅ **AI Chat**: Mock responses based on keywords
- ✅ **Trip Recommendations**: Mock suggestions
- ✅ **All UI Features**: Fully functional
- ✅ **No API Keys Required**: Works out of the box

### What Requires Backend:
- ⚠️ **Real AI Responses**: Need backend API
- ⚠️ **Context-Aware Chat**: Need LLM integration
- ⚠️ **Advanced Itineraries**: Need AI service

---

## 🎯 Quick Start Commands

### Run with Mock Mode (No Backend)
```powershell
flutter run -d chrome
```

### Run with Backend URL
```powershell
flutter run -d chrome --dart-define=BACKEND_API_URL=https://your-backend.com/api
```

### Update Dependencies
```powershell
flutter pub get
```

---

## 📚 Files to Review

1. **lib/services/gemini_service.dart** - AI chat backend integration
2. **lib/services/chat_service.dart** - General chat backend integration
3. **lib/services/ai_service.dart** - Itinerary generation
4. **lib/config.dart** - Configuration constants

---

## 🆘 Troubleshooting

### Issue: "Error: Unable to connect to AI assistant"
**Solution**: 
1. Check if backend is running
2. Verify `_backendUrl` is correct
3. Check CORS configuration
4. Review backend logs

### Issue: App still uses mock responses
**Solution**: Set `_useBackend = true` in service files

### Issue: CORS error in browser
**Solution**: Add Flutter app origin to backend CORS configuration

---

## 📞 Summary

✅ **Gemini API dependency removed**
✅ **Backend API integration ready**
✅ **Mock mode for development**
✅ **Easy switch between mock and backend**
✅ **Smaller app bundle size**
✅ **More flexible architecture**

**Next Steps**:
1. Deploy your backend API
2. Update `BACKEND_API_URL`
3. Set `_useBackend = true`
4. Test and deploy!

---

**All AI features now route through your backend API! 🎉**
