# Timetable App

A comprehensive Flutter timetable management application with SQLite offline storage.

## Features

### 🏠 Home Screen
- New Timetable creation
- History of timetables
- Settings management

### 📅 Timetable Editor
- Date Picker
- Add/Delete rows
- From Time dropdown
- To Time dropdown
- Subject dropdowns
- Empty cells automatically show `--`
- Save/Edit/Delete timetable
- Duplicate previous timetable

### 🎓 Standards Management
Default Standards:
- 5th, 6th, 7th, 8th, 9th, 10th, Abacus

Features:
- Add, Edit, Delete, Reorder

### 📚 Subjects Management
Default Subjects (18 subjects):
- Maths, Science, English (various), Sanskrit, Marathi, SST, Hindi, Geography, Exam, Holiday

Features:
- Add, Edit, Delete, Reorder

### ⏰ Time Slots Management
Default times from 06:45 AM to 09:00 PM (20 slots)

Features:
- Add, Edit, Delete, Reorder

### 🖼 Preview
- Exactly like your sample timetable
- Academy name display
- Date display
- Table borders
- Landscape layout support

### 📷 Export
- Download PNG
- Download JPG
- Share image

### 💾 Storage
- SQLite database
- Offline access
- Complete history
- Edit previous timetables

## Technology Stack

- **Flutter**: UI Framework
- **SQLite (sqflite)**: Local database
- **Provider**: State management
- **Screenshot**: Image capture
- **Image Gallery Saver**: Save to device
- **Share Plus**: Share functionality

## Project Structure

```
lib/
├── main.dart
├── models/
│   ├── timetable.dart
│   ├── timetable_row.dart
│   ├── subject.dart
│   ├── standard.dart
│   └── time_slot.dart
├── screens/
│   ├── home_screen.dart
│   ├── history_screen.dart
│   ├── settings_screen.dart
│   ├── standards_screen.dart
│   ├── subjects_screen.dart
│   ├── time_slots_screen.dart
│   ├── timetable_editor_screen.dart
│   └── timetable_preview_screen.dart
├── providers/
│   ├── timetable_provider.dart
│   ├── standards_provider.dart
│   ├── subjects_provider.dart
│   └── time_slots_provider.dart
├── services/
│   └── database_service.dart
├── constants/
│   ├── app_theme.dart
│   └── app_constants.dart
└── utils/
    └── date_time_utils.dart
```

## Getting Started

### Prerequisites
- Flutter SDK (>=3.0.0)
- Dart SDK

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd timetable_app
```

2. Get dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Development Stages

### Stage 1: ✅ Create the complete Flutter project structure and SQLite database.
- Project structure created
- Models defined
- Database service implemented
- SQLite tables and default data setup

### Stage 2: Build the Home, Settings, and History screens.
- Home screen with navigation
- Settings screen with management options
- History screen with timetable list
- Standards, Subjects, Time Slots screens

### Stage 3: Build the dynamic Timetable Editor with dropdowns.
- Timetable editor with date picker
- Add/delete rows functionality
- Dynamic dropdowns for time slots and subjects
- Form validation

### Stage 4: Build the Preview screen and PNG/JPG export.
- Timetable preview with proper formatting
- PNG export
- JPG export
- Share functionality

### Stage 5: Polish the UI, test, and deliver the complete project.
- UI refinements
- Testing
- Performance optimization
- Final delivery

## Usage

### Creating a Timetable
1. Tap "New" on the Home screen
2. Enter academy name (optional)
3. Select date
4. Choose standard
5. Add periods with time slots and subjects
6. Tap "Save Timetable"

### Managing Standards/Subjects/Time Slots
1. Go to Settings
2. Select the item to manage
3. Use the + button to add new items
4. Use menu options to edit or delete

### Viewing and Exporting
1. Go to History
2. Tap a timetable to preview
3. Use the menu to export as PNG/JPG or share

## Database Schema

### Tables
- **timetables**: Stores timetable information
- **timetable_rows**: Stores individual periods
- **standards**: Stores available standards
- **subjects**: Stores available subjects
- **time_slots**: Stores available time slots

## Future Enhancements
- Multiple timetables per standard
- Recurring timetables
- Custom fonts and colors
- Cloud backup
- Offline sync
- Multi-language support

## License

This project is open source and available under the MIT License.
