# AiNote Blueprint

## Overview

This document outlines the architecture, features, and design of the AiNote application. It serves as a single source of truth for the project's implementation details.

## Core Features & Design

### 1. Note Management

*   **Create, Edit, Delete Notes**: Core functionality for note lifecycle management.
*   **Rich Text Editor**: A simple, full-screen editor for writing and editing notes.
*   **Folder Organization**: 
    *   Users can create colored folders to categorize notes.
    *   Notes can be moved between folders via a context menu or drag-and-drop.
*   **Archiving**: Notes can be archived to be hidden from the main view and managed in a separate "Archived Notes" screen.
*   **Undo Delete**: A SnackBar with an "UNDO" action appears after deleting a note, allowing the user to revert the deletion.

### 2. UI & UX

*   **Modern Aesthetics**: The app uses Material Design 3 components, a visually balanced layout, clean spacing, and polished styles.
*   **Responsive Design**: The UI is designed to be responsive and work well on both mobile and web.
*   **Light/Dark Mode**: The application supports both light and dark themes, with a toggle in the settings screen. The theme is persisted using `shared_preferences`.
*   **Staggered Grid View**: Uncategorized notes are displayed in a `MasonryGridView` for a visually dynamic layout.
*   **Intuitive Navigation**: The app uses a simple and clear navigation structure.

### 3. State Management

*   **Provider**: The `provider` package is used for state management, specifically with `ChangeNotifierProvider` to manage the `NoteProvider` and `ThemeProvider`.
*   **NoteProvider**: A central class that manages all note and folder data, including CRUD operations, archiving, and moving notes.
*   **ThemeProvider**: Manages the application's theme (light/dark/system) and persists the choice to `shared_preferences`.

### 4. Local Storage

*   **SharedPreferences**: Used to persist:
    *   The user's selected theme.
    *   The user's custom text prompts.

## New Feature: Customizable Prompts

### Plan & Steps

1.  **UI for Prompts**: 
    *   Add three buttons to the `NoteEditorScreen`.
    *   Each button will insert a predefined text string into the note content.
2.  **Settings for Prompts**:
    *   Add a settings icon to the `NoteEditorScreen`'s app bar.
    *   Tapping the icon opens a dialog where the user can define the text for each of the three prompts.
3.  **Persistence**: 
    *   Use the `shared_preferences` package to save the three prompt strings locally on the device.
    *   The `NoteEditorScreen` will load the saved prompts when it initializes.
