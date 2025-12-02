# DocChat Flutter - Replit Project Documentation

## Project Overview

**DocChat** is an AI-powered document chat application built with Flutter. It allows users to upload documents (PDF, PowerPoint, Word) and interact with them through an AI-powered chat interface.

### Technology Stack
- **Frontend**: Flutter 3.32.0 (Web)
- **Backend**: Supabase (PostgreSQL + Auth + Storage)
- **State Management**: Riverpod
- **Routing**: Go Router
- **AI Service**: OpenAI / DeepSeek integration

## Project Structure

```
├── docchat_flutter/          # Flutter application
│   ├── lib/                  # Source code
│   │   ├── core/            # Core configuration and utilities
│   │   ├── features/        # Feature modules (auth, documents, chat, etc.)
│   │   └── shared/          # Shared widgets and services
│   ├── build/web/           # Built web application (generated)
│   └── pubspec.yaml         # Flutter dependencies
├── database/                # Database SQL setup scripts
├── docs/                    # Project documentation
├── server.py               # Python web server for Flutter app
└── .env                    # Environment variables (Supabase config)
```

## Running the Application

### Development Mode

The application is currently set up to serve the pre-built Flutter web app:

1. The workflow "Flutter Web Server" automatically runs `python3 server.py`
2. The server serves the Flutter web app from `docchat_flutter/build/web`
3. Access the app through the Replit webview (port 5000)

### Rebuilding the Flutter App

If you make changes to the Flutter code, rebuild the web app:

```bash
cd docchat_flutter
flutter build web --release
```

The server will automatically serve the updated build.

### Installing Flutter Dependencies

If you need to update dependencies:

```bash
cd docchat_flutter
flutter pub get
```

## Environment Configuration

The application uses environment variables stored in `docchat_flutter/.env`:

- `SUPABASE_URL`: Supabase project URL
- `SUPABASE_ANON_KEY`: Supabase anonymous key
- `SUPABASE_PROJECT_ID`: Supabase project ID
- `OPENAI_API_KEY`: OpenAI API key (for AI features)
- `DEEPSEEK_API_KEY`: DeepSeek API key (alternative AI provider)

**Note**: The `.env` file is included in the repository but API keys should be updated with your own values.

## Database Setup

The application requires a Supabase database with specific tables and storage buckets. Setup instructions:

1. Create a Supabase project at https://supabase.com
2. Run the SQL scripts in the `database/` folder in order:
   - `01_users.sql` - User table and auth trigger
   - `02_core_tables.sql` - Core SaaS tables and DocChat tables
   - `03_storage.sql` - Storage buckets setup
   - `04_chat.sql` - Chat sessions and messages tables
3. Update the `.env` file with your Supabase credentials

See `database/README.md` for detailed setup instructions.

## Features

### Implemented
- User authentication (email/password + Google OAuth)
- Document upload and management
- Document chat interface
- Profile management
- Settings screen
- Landing pages (home, privacy, terms, contact)
- Dark mode support

### In Development
- AI integration with OpenAI/DeepSeek
- Document processing and summarization
- Real-time chat with streaming responses

## Deployment

The project is configured for static deployment to Replit Deployments:

- **Deployment Target**: Static
- **Public Directory**: `docchat_flutter/build/web`

To deploy:
1. Ensure the Flutter app is built (`flutter build web --release`)
2. Click the "Deploy" button in Replit
3. The static files will be served from the build directory

## Development Notes

### Flutter Web Considerations
- The app is built for web using Flutter's CanvasKit renderer
- All routes are handled client-side with Go Router
- The Python server is minimal - it only serves static files
- CORS headers are configured to allow iframe embedding in Replit

### State Management
- Uses Riverpod for reactive state management
- Freezed for immutable data models
- JSON Serializable for type-safe API responses

### Code Structure
- Clean architecture pattern (data, domain, presentation layers)
- Feature-based organization
- Shared widgets and utilities in `shared/`

## Recent Changes

**December 2, 2025** - Initial Replit setup
- Installed Flutter SDK via Nix packages
- Built Flutter web application for production
- Created Python server to serve Flutter web app
- Configured workflow to run on port 5000
- Set up deployment configuration
- Created .gitignore for Flutter/Dart/Python

## User Preferences

None specified yet.

## Project Architecture

This Flutter application follows clean architecture principles with clear separation of concerns:

- **Data Layer**: Repositories, data sources, models (JSON serialization)
- **Domain Layer**: Entities, repository interfaces, business logic
- **Presentation Layer**: Screens, widgets, providers (Riverpod)

Key architectural decisions:
- Supabase for backend services (reduces server-side code complexity)
- Static web deployment (pre-built Flutter web app served via simple HTTP server)
- Environment-based configuration using flutter_dotenv
