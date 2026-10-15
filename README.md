# project_create

This project aims to provide students with personalized supplementary projects based on the current topics being taught in their courses. These projects will allow students to further understand the real-world applications of the concepts learned in classes, as well as understand how ideas from their different courses connect to one another.

## Let's get started! (o≧∇≦)o

### Run the app

Project suggestions use Gemini. For local development, provide your own API key at launch:

```powershell
flutter run --dart-define=GEMINI_API_KEY=your_key_here
```

The key is required for the direct development setup. A key compiled into a mobile or web client can be extracted. For a deployed app, set `GEMINI_API_KEY` on the included backend and point the app at it with `--dart-define=LUXI_API_URL=https://your-api.example.com` instead.
