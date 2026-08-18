import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ur.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ur'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Anas Life OS'**
  String get appName;

  /// No description provided for @startingTitle.
  ///
  /// In en, this message translates to:
  /// **'Preparing your private workspace'**
  String get startingTitle;

  /// No description provided for @startingMessage.
  ///
  /// In en, this message translates to:
  /// **'Checking the secure offline foundation.'**
  String get startingMessage;

  /// No description provided for @foundationReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'Private workspace ready'**
  String get foundationReadyTitle;

  /// No description provided for @foundationReadyMessage.
  ///
  /// In en, this message translates to:
  /// **'Your encrypted offline workspace is ready.'**
  String get foundationReadyMessage;

  /// No description provided for @foundationErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Secure foundation unavailable'**
  String get foundationErrorTitle;

  /// No description provided for @foundationErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'The local encrypted database engine could not be verified. No data was created. Retry after checking the installation.'**
  String get foundationErrorMessage;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @openTasks.
  ///
  /// In en, this message translates to:
  /// **'Open tasks'**
  String get openTasks;

  /// No description provided for @tasksTitle.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasksTitle;

  /// No description provided for @createTask.
  ///
  /// In en, this message translates to:
  /// **'Create task'**
  String get createTask;

  /// No description provided for @taskTitle.
  ///
  /// In en, this message translates to:
  /// **'Task title'**
  String get taskTitle;

  /// No description provided for @taskTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a task title.'**
  String get taskTitleRequired;

  /// No description provided for @taskTitleTooLong.
  ///
  /// In en, this message translates to:
  /// **'Task title cannot exceed 300 characters.'**
  String get taskTitleTooLong;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @completeTask.
  ///
  /// In en, this message translates to:
  /// **'Complete task'**
  String get completeTask;

  /// No description provided for @taskActions.
  ///
  /// In en, this message translates to:
  /// **'Task actions'**
  String get taskActions;

  /// No description provided for @archive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archive;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @noTasksTitle.
  ///
  /// In en, this message translates to:
  /// **'No tasks yet'**
  String get noTasksTitle;

  /// No description provided for @noTasksMessage.
  ///
  /// In en, this message translates to:
  /// **'Create your first private offline task.'**
  String get noTasksMessage;

  /// No description provided for @tasksErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Tasks are unavailable'**
  String get tasksErrorTitle;

  /// No description provided for @openReminders.
  ///
  /// In en, this message translates to:
  /// **'Open reminders'**
  String get openReminders;

  /// No description provided for @remindersTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get remindersTitle;

  /// No description provided for @createReminder.
  ///
  /// In en, this message translates to:
  /// **'Create reminder'**
  String get createReminder;

  /// No description provided for @reminderTaskId.
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get reminderTaskId;

  /// No description provided for @reminderTaskRequired.
  ///
  /// In en, this message translates to:
  /// **'Select a task.'**
  String get reminderTaskRequired;

  /// No description provided for @reminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminder title'**
  String get reminderTitle;

  /// No description provided for @reminderTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a reminder title.'**
  String get reminderTitleRequired;

  /// No description provided for @reminderDateTime.
  ///
  /// In en, this message translates to:
  /// **'Reminder date and time'**
  String get reminderDateTime;

  /// No description provided for @reminderVibration.
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get reminderVibration;

  /// No description provided for @reminderVoice.
  ///
  /// In en, this message translates to:
  /// **'Voice reminder'**
  String get reminderVoice;

  /// No description provided for @reminderFlash.
  ///
  /// In en, this message translates to:
  /// **'Flash alert'**
  String get reminderFlash;

  /// No description provided for @reminderFullScreen.
  ///
  /// In en, this message translates to:
  /// **'Full-screen alert'**
  String get reminderFullScreen;

  /// No description provided for @reminderAutoSnooze.
  ///
  /// In en, this message translates to:
  /// **'Automatic snooze'**
  String get reminderAutoSnooze;

  /// No description provided for @noRemindersTitle.
  ///
  /// In en, this message translates to:
  /// **'No reminders yet'**
  String get noRemindersTitle;

  /// No description provided for @noRemindersMessage.
  ///
  /// In en, this message translates to:
  /// **'Create a private offline reminder for a task.'**
  String get noRemindersMessage;

  /// No description provided for @remindersErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminders are unavailable'**
  String get remindersErrorTitle;

  /// No description provided for @openKnowledge.
  ///
  /// In en, this message translates to:
  /// **'Open Knowledge Vault'**
  String get openKnowledge;

  /// No description provided for @knowledgeTitle.
  ///
  /// In en, this message translates to:
  /// **'Knowledge Vault'**
  String get knowledgeTitle;

  /// No description provided for @documentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get documentsTitle;

  /// No description provided for @createNote.
  ///
  /// In en, this message translates to:
  /// **'Create note'**
  String get createNote;

  /// No description provided for @searchKnowledge.
  ///
  /// In en, this message translates to:
  /// **'Search knowledge'**
  String get searchKnowledge;

  /// No description provided for @allNotes.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allNotes;

  /// No description provided for @notesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notesLabel;

  /// No description provided for @journalLabel.
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get journalLabel;

  /// No description provided for @wikiLabel.
  ///
  /// In en, this message translates to:
  /// **'Wiki'**
  String get wikiLabel;

  /// No description provided for @knowledgeErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Knowledge is unavailable'**
  String get knowledgeErrorTitle;

  /// No description provided for @noKnowledgeTitle.
  ///
  /// In en, this message translates to:
  /// **'No knowledge yet'**
  String get noKnowledgeTitle;

  /// No description provided for @noKnowledgeMessage.
  ///
  /// In en, this message translates to:
  /// **'Create a private offline note, journal entry, or wiki page.'**
  String get noKnowledgeMessage;

  /// No description provided for @noteTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get noteTitle;

  /// No description provided for @noteTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a note title.'**
  String get noteTitleRequired;

  /// No description provided for @noteType.
  ///
  /// In en, this message translates to:
  /// **'Note type'**
  String get noteType;

  /// No description provided for @markdownMode.
  ///
  /// In en, this message translates to:
  /// **'Markdown mode'**
  String get markdownMode;

  /// No description provided for @noteContent.
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get noteContent;

  /// No description provided for @emptyNote.
  ///
  /// In en, this message translates to:
  /// **'Empty note'**
  String get emptyNote;

  /// No description provided for @favorite.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get favorite;

  /// No description provided for @noDocumentsTitle.
  ///
  /// In en, this message translates to:
  /// **'No documents yet'**
  String get noDocumentsTitle;

  /// No description provided for @noDocumentsMessage.
  ///
  /// In en, this message translates to:
  /// **'Imported documents remain private and available offline.'**
  String get noDocumentsMessage;

  /// No description provided for @openDashboard.
  ///
  /// In en, this message translates to:
  /// **'Open dashboard'**
  String get openDashboard;

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboardTitle;

  /// No description provided for @customizeDashboard.
  ///
  /// In en, this message translates to:
  /// **'Customize dashboard'**
  String get customizeDashboard;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @quickAdd.
  ///
  /// In en, this message translates to:
  /// **'Quick add'**
  String get quickAdd;

  /// No description provided for @openCalendar.
  ///
  /// In en, this message translates to:
  /// **'Open calendar'**
  String get openCalendar;

  /// No description provided for @calendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendarTitle;

  /// No description provided for @addEvent.
  ///
  /// In en, this message translates to:
  /// **'Add event'**
  String get addEvent;

  /// No description provided for @eventTitle.
  ///
  /// In en, this message translates to:
  /// **'Event title'**
  String get eventTitle;

  /// No description provided for @eventTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter an event title.'**
  String get eventTitleRequired;

  /// No description provided for @starts.
  ///
  /// In en, this message translates to:
  /// **'Starts'**
  String get starts;

  /// No description provided for @previousPeriod.
  ///
  /// In en, this message translates to:
  /// **'Previous period'**
  String get previousPeriod;

  /// No description provided for @nextPeriod.
  ///
  /// In en, this message translates to:
  /// **'Next period'**
  String get nextPeriod;

  /// No description provided for @noCalendarItems.
  ///
  /// In en, this message translates to:
  /// **'No calendar items in this period.'**
  String get noCalendarItems;

  /// No description provided for @moveUp.
  ///
  /// In en, this message translates to:
  /// **'Move up'**
  String get moveUp;

  /// No description provided for @moveDown.
  ///
  /// In en, this message translates to:
  /// **'Move down'**
  String get moveDown;

  /// No description provided for @dayView.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get dayView;

  /// No description provided for @weekView.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get weekView;

  /// No description provided for @monthView.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get monthView;

  /// No description provided for @yearView.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get yearView;

  /// No description provided for @agendaView.
  ///
  /// In en, this message translates to:
  /// **'Agenda'**
  String get agendaView;

  /// No description provided for @timelineView.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get timelineView;

  /// No description provided for @heatMapView.
  ///
  /// In en, this message translates to:
  /// **'Heat map'**
  String get heatMapView;

  /// No description provided for @openSearch.
  ///
  /// In en, this message translates to:
  /// **'Open search'**
  String get openSearch;

  /// No description provided for @searchTitle.
  ///
  /// In en, this message translates to:
  /// **'Universal Search'**
  String get searchTitle;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search tasks, projects, notes, documents and attachments'**
  String get searchHint;

  /// No description provided for @searchFilters.
  ///
  /// In en, this message translates to:
  /// **'Search filters'**
  String get searchFilters;

  /// No description provided for @searchSort.
  ///
  /// In en, this message translates to:
  /// **'Sort results'**
  String get searchSort;

  /// No description provided for @searchRelevance.
  ///
  /// In en, this message translates to:
  /// **'Relevance'**
  String get searchRelevance;

  /// No description provided for @searchNewest.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get searchNewest;

  /// No description provided for @searchOldest.
  ///
  /// In en, this message translates to:
  /// **'Oldest'**
  String get searchOldest;

  /// No description provided for @searchTitleSort.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get searchTitleSort;

  /// No description provided for @searchAllTypes.
  ///
  /// In en, this message translates to:
  /// **'All types'**
  String get searchAllTypes;

  /// No description provided for @searchTasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get searchTasks;

  /// No description provided for @searchProjects.
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get searchProjects;

  /// No description provided for @searchNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get searchNotes;

  /// No description provided for @searchDocuments.
  ///
  /// In en, this message translates to:
  /// **'Search documents'**
  String get searchDocuments;

  /// No description provided for @searchAttachments.
  ///
  /// In en, this message translates to:
  /// **'Attachments'**
  String get searchAttachments;

  /// No description provided for @searchProjectId.
  ///
  /// In en, this message translates to:
  /// **'Project ID'**
  String get searchProjectId;

  /// No description provided for @searchTags.
  ///
  /// In en, this message translates to:
  /// **'Tags separated by commas'**
  String get searchTags;

  /// No description provided for @searchFromDate.
  ///
  /// In en, this message translates to:
  /// **'From date'**
  String get searchFromDate;

  /// No description provided for @searchToDate.
  ///
  /// In en, this message translates to:
  /// **'To date'**
  String get searchToDate;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get clearFilters;

  /// No description provided for @applyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply filters'**
  String get applyFilters;

  /// No description provided for @saveSearch.
  ///
  /// In en, this message translates to:
  /// **'Save search'**
  String get saveSearch;

  /// No description provided for @savedSearchName.
  ///
  /// In en, this message translates to:
  /// **'Saved-search name'**
  String get savedSearchName;

  /// No description provided for @recentSearches.
  ///
  /// In en, this message translates to:
  /// **'Recent searches'**
  String get recentSearches;

  /// No description provided for @savedSearches.
  ///
  /// In en, this message translates to:
  /// **'Saved searches'**
  String get savedSearches;

  /// No description provided for @noSearchResults.
  ///
  /// In en, this message translates to:
  /// **'No authorized results'**
  String get noSearchResults;

  /// No description provided for @noSearchResultsMessage.
  ///
  /// In en, this message translates to:
  /// **'Try another term or adjust the filters.'**
  String get noSearchResultsMessage;

  /// No description provided for @voiceSearchEnglish.
  ///
  /// In en, this message translates to:
  /// **'Voice search in English'**
  String get voiceSearchEnglish;

  /// No description provided for @voiceSearchUrdu.
  ///
  /// In en, this message translates to:
  /// **'Voice search in Urdu'**
  String get voiceSearchUrdu;

  /// No description provided for @voiceSearchUnavailable.
  ///
  /// In en, this message translates to:
  /// **'On-device voice search is unavailable. Typed search remains available.'**
  String get voiceSearchUnavailable;

  /// No description provided for @searchErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Search is unavailable'**
  String get searchErrorTitle;

  /// No description provided for @unavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Content is unavailable'**
  String get unavailableTitle;

  /// No description provided for @moreTitle.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get moreTitle;

  /// No description provided for @projectsTitle.
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get projectsTitle;

  /// No description provided for @createProject.
  ///
  /// In en, this message translates to:
  /// **'Create project'**
  String get createProject;

  /// No description provided for @editProject.
  ///
  /// In en, this message translates to:
  /// **'Edit project'**
  String get editProject;

  /// No description provided for @projectTitle.
  ///
  /// In en, this message translates to:
  /// **'Project title'**
  String get projectTitle;

  /// No description provided for @projectTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a project title.'**
  String get projectTitleRequired;

  /// No description provided for @projectDetails.
  ///
  /// In en, this message translates to:
  /// **'Project details'**
  String get projectDetails;

  /// No description provided for @projectNotFound.
  ///
  /// In en, this message translates to:
  /// **'Project not found'**
  String get projectNotFound;

  /// No description provided for @projectNotFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'This project is no longer available.'**
  String get projectNotFoundMessage;

  /// No description provided for @noProjectsTitle.
  ///
  /// In en, this message translates to:
  /// **'No projects yet'**
  String get noProjectsTitle;

  /// No description provided for @noProjectsMessage.
  ///
  /// In en, this message translates to:
  /// **'Create a project to organize related tasks.'**
  String get noProjectsMessage;

  /// No description provided for @projectTasks.
  ///
  /// In en, this message translates to:
  /// **'Project tasks'**
  String get projectTasks;

  /// No description provided for @noProjectTasks.
  ///
  /// In en, this message translates to:
  /// **'No tasks belong to this project yet.'**
  String get noProjectTasks;

  /// No description provided for @noDescription.
  ///
  /// In en, this message translates to:
  /// **'No description'**
  String get noDescription;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @completionProgress.
  ///
  /// In en, this message translates to:
  /// **'Completion progress'**
  String get completionProgress;

  /// No description provided for @completedCount.
  ///
  /// In en, this message translates to:
  /// **'{completed} of {total} completed'**
  String completedCount(int completed, int total);

  /// No description provided for @taskDetails.
  ///
  /// In en, this message translates to:
  /// **'Task details'**
  String get taskDetails;

  /// No description provided for @taskNotFound.
  ///
  /// In en, this message translates to:
  /// **'Task not found'**
  String get taskNotFound;

  /// No description provided for @taskNotFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'This task is no longer available.'**
  String get taskNotFoundMessage;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @editTask.
  ///
  /// In en, this message translates to:
  /// **'Edit task'**
  String get editTask;

  /// No description provided for @duplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get duplicate;

  /// No description provided for @priority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get priority;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @mandatory.
  ///
  /// In en, this message translates to:
  /// **'Mandatory'**
  String get mandatory;

  /// No description provided for @progressPercent.
  ///
  /// In en, this message translates to:
  /// **'Progress: {value}%'**
  String progressPercent(int value);

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get startDate;

  /// No description provided for @dueDate.
  ///
  /// In en, this message translates to:
  /// **'Due date'**
  String get dueDate;

  /// No description provided for @projectId.
  ///
  /// In en, this message translates to:
  /// **'Project ID'**
  String get projectId;

  /// No description provided for @parentTaskId.
  ///
  /// In en, this message translates to:
  /// **'Parent task'**
  String get parentTaskId;

  /// No description provided for @parentTaskHelper.
  ///
  /// In en, this message translates to:
  /// **'Required only for mandatory subtasks.'**
  String get parentTaskHelper;

  /// No description provided for @noParentTask.
  ///
  /// In en, this message translates to:
  /// **'No parent task'**
  String get noParentTask;

  /// No description provided for @mandatoryTaskRequiresParent.
  ///
  /// In en, this message translates to:
  /// **'Choose a parent task before marking this subtask mandatory.'**
  String get mandatoryTaskRequiresParent;

  /// No description provided for @invalidTaskDates.
  ///
  /// In en, this message translates to:
  /// **'Due date cannot be before start date.'**
  String get invalidTaskDates;

  /// No description provided for @reminderSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get reminderSectionTitle;

  /// No description provided for @reminderEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enable reminder'**
  String get reminderEnabled;

  /// No description provided for @reminderDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get reminderDate;

  /// No description provided for @reminderTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get reminderTime;

  /// No description provided for @audibleReminder.
  ///
  /// In en, this message translates to:
  /// **'Audible reminder'**
  String get audibleReminder;

  /// No description provided for @taskSavedReminderFailed.
  ///
  /// In en, this message translates to:
  /// **'Task saved, but its reminder could not be scheduled: {message}'**
  String taskSavedReminderFailed(String message);

  /// No description provided for @addTag.
  ///
  /// In en, this message translates to:
  /// **'Add tag'**
  String get addTag;

  /// No description provided for @addChecklist.
  ///
  /// In en, this message translates to:
  /// **'Add checklist'**
  String get addChecklist;

  /// No description provided for @listView.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get listView;

  /// No description provided for @boardView.
  ///
  /// In en, this message translates to:
  /// **'Board'**
  String get boardView;

  /// No description provided for @taskStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'{status, select, draft{Draft} scheduled{Scheduled} pending{Pending} inProgress{In progress} waiting{Waiting} blocked{Blocked} completed{Completed} archived{Archived} deleted{Deleted} other{Status}}'**
  String taskStatusLabel(String status);

  /// No description provided for @taskPriorityLabel.
  ///
  /// In en, this message translates to:
  /// **'{priority, select, none{No priority} low{Low} medium{Medium} high{High} critical{Critical} other{Priority}}'**
  String taskPriorityLabel(String priority);

  /// No description provided for @editReminder.
  ///
  /// In en, this message translates to:
  /// **'Edit reminder'**
  String get editReminder;

  /// No description provided for @reminderMessage.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get reminderMessage;

  /// No description provided for @repeatRuleId.
  ///
  /// In en, this message translates to:
  /// **'Repeat rule ID'**
  String get repeatRuleId;

  /// No description provided for @snoozeMinutes.
  ///
  /// In en, this message translates to:
  /// **'Snooze minutes'**
  String get snoozeMinutes;

  /// No description provided for @maximumSnoozes.
  ///
  /// In en, this message translates to:
  /// **'Maximum snoozes'**
  String get maximumSnoozes;

  /// No description provided for @escalationStep.
  ///
  /// In en, this message translates to:
  /// **'Escalation step'**
  String get escalationStep;

  /// No description provided for @snooze.
  ///
  /// In en, this message translates to:
  /// **'Snooze'**
  String get snooze;

  /// No description provided for @missedReminders.
  ///
  /// In en, this message translates to:
  /// **'Missed reminders'**
  String get missedReminders;

  /// No description provided for @noMissedReminders.
  ///
  /// In en, this message translates to:
  /// **'No missed reminders.'**
  String get noMissedReminders;

  /// No description provided for @reminderNumber.
  ///
  /// In en, this message translates to:
  /// **'Reminder {id}'**
  String reminderNumber(int id);

  /// No description provided for @reminderPriorityLabel.
  ///
  /// In en, this message translates to:
  /// **'{priority, select, low{Low} normal{Normal} high{High} critical{Critical} other{Priority}}'**
  String reminderPriorityLabel(String priority);

  /// No description provided for @reminderActionLabel.
  ///
  /// In en, this message translates to:
  /// **'{action, select, triggered{Triggered} opened{Opened} completed{Completed} dismissed{Dismissed} ignored{Ignored} snoozed{Snoozed} expired{Expired} other{Action}}'**
  String reminderActionLabel(String action);

  /// No description provided for @createFolder.
  ///
  /// In en, this message translates to:
  /// **'Create folder'**
  String get createFolder;

  /// No description provided for @folderName.
  ///
  /// In en, this message translates to:
  /// **'Folder name'**
  String get folderName;

  /// No description provided for @noteDetails.
  ///
  /// In en, this message translates to:
  /// **'Note details'**
  String get noteDetails;

  /// No description provided for @noteNotFound.
  ///
  /// In en, this message translates to:
  /// **'Note not found'**
  String get noteNotFound;

  /// No description provided for @noteNotFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'This note is no longer available.'**
  String get noteNotFoundMessage;

  /// No description provided for @editNote.
  ///
  /// In en, this message translates to:
  /// **'Edit note'**
  String get editNote;

  /// No description provided for @pinned.
  ///
  /// In en, this message translates to:
  /// **'Pinned'**
  String get pinned;

  /// No description provided for @editTags.
  ///
  /// In en, this message translates to:
  /// **'Edit tags'**
  String get editTags;

  /// No description provided for @tagsCommaSeparated.
  ///
  /// In en, this message translates to:
  /// **'Tags separated by commas'**
  String get tagsCommaSeparated;

  /// No description provided for @linkNote.
  ///
  /// In en, this message translates to:
  /// **'Link note'**
  String get linkNote;

  /// No description provided for @targetNoteId.
  ///
  /// In en, this message translates to:
  /// **'Target note ID'**
  String get targetNoteId;

  /// No description provided for @versionHistory.
  ///
  /// In en, this message translates to:
  /// **'Version history'**
  String get versionHistory;

  /// No description provided for @versionNumber.
  ///
  /// In en, this message translates to:
  /// **'Version {number}'**
  String versionNumber(int number);

  /// No description provided for @noteTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'{type, select, note{Note} journal{Journal} wiki{Wiki} other{Note}}'**
  String noteTypeLabel(String type);

  /// No description provided for @contentFormatLabel.
  ///
  /// In en, this message translates to:
  /// **'{format, select, richText{Rich text} markdown{Markdown} other{Content}}'**
  String contentFormatLabel(String format);

  /// No description provided for @documentActions.
  ///
  /// In en, this message translates to:
  /// **'Document actions'**
  String get documentActions;

  /// No description provided for @documentDetails.
  ///
  /// In en, this message translates to:
  /// **'Document details'**
  String get documentDetails;

  /// No description provided for @documentNotFound.
  ///
  /// In en, this message translates to:
  /// **'Document not found'**
  String get documentNotFound;

  /// No description provided for @documentNotFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'This document is no longer available.'**
  String get documentNotFoundMessage;

  /// No description provided for @offlineMetadataPreview.
  ///
  /// In en, this message translates to:
  /// **'Offline metadata preview'**
  String get offlineMetadataPreview;

  /// No description provided for @fileName.
  ///
  /// In en, this message translates to:
  /// **'File name'**
  String get fileName;

  /// No description provided for @fileType.
  ///
  /// In en, this message translates to:
  /// **'File type'**
  String get fileType;

  /// No description provided for @fileSize.
  ///
  /// In en, this message translates to:
  /// **'File size'**
  String get fileSize;

  /// No description provided for @createdDate.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get createdDate;

  /// No description provided for @encryption.
  ///
  /// In en, this message translates to:
  /// **'Encryption'**
  String get encryption;

  /// No description provided for @encrypted.
  ///
  /// In en, this message translates to:
  /// **'Encrypted'**
  String get encrypted;

  /// No description provided for @protectedLocalStorage.
  ///
  /// In en, this message translates to:
  /// **'Protected local storage'**
  String get protectedLocalStorage;

  /// No description provided for @sourceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The authorized source is no longer available.'**
  String get sourceUnavailable;

  /// No description provided for @availableActions.
  ///
  /// In en, this message translates to:
  /// **'Tasks, calendar and search'**
  String get availableActions;

  /// No description provided for @dashboardWidgetLabel.
  ///
  /// In en, this message translates to:
  /// **'{kind, select, today{Today} tomorrow{Tomorrow} pending{Pending} overdue{Overdue} completedToday{Completed today} upcoming{Next seven days} favorites{Pinned and favorites} progress{Completion progress} recentKnowledge{Recent knowledge} dateTime{Date and time} quickActions{Quick actions} miniCalendar{Mini calendar} recentProjects{Recent projects} recentActivity{Recent activity} productivity{Productivity score} other{Dashboard widget}}'**
  String dashboardWidgetLabel(String kind);

  /// No description provided for @dashboardSizeLabel.
  ///
  /// In en, this message translates to:
  /// **'{size, select, compact{Compact} regular{Regular} expanded{Expanded} other{Size}}'**
  String dashboardSizeLabel(String size);

  /// No description provided for @noCalendarItemsMessage.
  ///
  /// In en, this message translates to:
  /// **'Add an event or task for this period.'**
  String get noCalendarItemsMessage;

  /// No description provided for @calendarDayItems.
  ///
  /// In en, this message translates to:
  /// **'Day {day}, {count} items'**
  String calendarDayItems(int day, int count);

  /// No description provided for @weekStarting.
  ///
  /// In en, this message translates to:
  /// **'Week of {date}'**
  String weekStarting(String date);

  /// No description provided for @enable.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get enable;

  /// No description provided for @disable.
  ///
  /// In en, this message translates to:
  /// **'Disable'**
  String get disable;

  /// No description provided for @itemCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No items} =1{1 item} other{{count} items}}'**
  String itemCount(int count);

  /// No description provided for @statisticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statisticsTitle;

  /// No description provided for @completionRate.
  ///
  /// In en, this message translates to:
  /// **'Completion rate'**
  String get completionRate;

  /// No description provided for @onTimeRate.
  ///
  /// In en, this message translates to:
  /// **'On-time rate'**
  String get onTimeRate;

  /// No description provided for @productivityScore.
  ///
  /// In en, this message translates to:
  /// **'Productivity score'**
  String get productivityScore;

  /// No description provided for @averageDelay.
  ///
  /// In en, this message translates to:
  /// **'Average delay'**
  String get averageDelay;

  /// No description provided for @historicalTrend.
  ///
  /// In en, this message translates to:
  /// **'Historical trend'**
  String get historicalTrend;

  /// No description provided for @noStatisticsTitle.
  ///
  /// In en, this message translates to:
  /// **'No statistics yet'**
  String get noStatisticsTitle;

  /// No description provided for @noStatisticsMessage.
  ///
  /// In en, this message translates to:
  /// **'Complete scheduled tasks to build private offline reports.'**
  String get noStatisticsMessage;

  /// No description provided for @notAvailable.
  ///
  /// In en, this message translates to:
  /// **'Not available'**
  String get notAvailable;

  /// No description provided for @percentageValue.
  ///
  /// In en, this message translates to:
  /// **'{value}%'**
  String percentageValue(int value);

  /// No description provided for @minutesValue.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String minutesValue(int minutes);

  /// No description provided for @backupTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup center'**
  String get backupTitle;

  /// No description provided for @manualBackup.
  ///
  /// In en, this message translates to:
  /// **'Manual backup'**
  String get manualBackup;

  /// No description provided for @importAndRestore.
  ///
  /// In en, this message translates to:
  /// **'Import and restore'**
  String get importAndRestore;

  /// No description provided for @automaticBackup.
  ///
  /// In en, this message translates to:
  /// **'Automatic backup'**
  String get automaticBackup;

  /// No description provided for @enableAutomaticBackup.
  ///
  /// In en, this message translates to:
  /// **'Enable automatic backups'**
  String get enableAutomaticBackup;

  /// No description provided for @backupFrequency.
  ///
  /// In en, this message translates to:
  /// **'Backup frequency'**
  String get backupFrequency;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @backupRetention.
  ///
  /// In en, this message translates to:
  /// **'Automatic backups to keep (1–30)'**
  String get backupRetention;

  /// No description provided for @backupDestination.
  ///
  /// In en, this message translates to:
  /// **'Backup destination'**
  String get backupDestination;

  /// No description provided for @destinationNotSelected.
  ///
  /// In en, this message translates to:
  /// **'No destination selected'**
  String get destinationNotSelected;

  /// No description provided for @destinationSelected.
  ///
  /// In en, this message translates to:
  /// **'Destination selected'**
  String get destinationSelected;

  /// No description provided for @backupHistory.
  ///
  /// In en, this message translates to:
  /// **'Backup history'**
  String get backupHistory;

  /// No description provided for @noBackupsMessage.
  ///
  /// In en, this message translates to:
  /// **'No backups yet. Create an encrypted backup to protect your data.'**
  String get noBackupsMessage;

  /// No description provided for @backupPassphrase.
  ///
  /// In en, this message translates to:
  /// **'Backup passphrase'**
  String get backupPassphrase;

  /// No description provided for @confirmPassphrase.
  ///
  /// In en, this message translates to:
  /// **'Confirm backup passphrase'**
  String get confirmPassphrase;

  /// No description provided for @backupPassphraseRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter the backup passphrase.'**
  String get backupPassphraseRequired;

  /// No description provided for @passphrasesDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passphrases do not match.'**
  String get passphrasesDoNotMatch;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @restoreBackup.
  ///
  /// In en, this message translates to:
  /// **'Restore backup'**
  String get restoreBackup;

  /// No description provided for @restoreWarning.
  ///
  /// In en, this message translates to:
  /// **'The backup will be verified before replacement. If validation fails, your current data will remain unchanged.'**
  String get restoreWarning;

  /// No description provided for @backupSucceeded.
  ///
  /// In en, this message translates to:
  /// **'Successful'**
  String get backupSucceeded;

  /// No description provided for @backupFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get backupFailed;

  /// No description provided for @securityTitle.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get securityTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @appLocked.
  ///
  /// In en, this message translates to:
  /// **'App locked'**
  String get appLocked;

  /// No description provided for @unlockMessage.
  ///
  /// In en, this message translates to:
  /// **'Authenticate to access your private data.'**
  String get unlockMessage;

  /// No description provided for @pinLabel.
  ///
  /// In en, this message translates to:
  /// **'PIN'**
  String get pinLabel;

  /// No description provided for @enterPin.
  ///
  /// In en, this message translates to:
  /// **'Enter your PIN'**
  String get enterPin;

  /// No description provided for @pinMinimum.
  ///
  /// In en, this message translates to:
  /// **'Use at least 6 digits.'**
  String get pinMinimum;

  /// No description provided for @unlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get unlock;

  /// No description provided for @useBiometric.
  ///
  /// In en, this message translates to:
  /// **'Use biometric'**
  String get useBiometric;

  /// No description provided for @biometricPromptTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock Anas Life OS'**
  String get biometricPromptTitle;

  /// No description provided for @biometricPromptSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use your enrolled biometric'**
  String get biometricPromptSubtitle;

  /// No description provided for @usePin.
  ///
  /// In en, this message translates to:
  /// **'Use PIN'**
  String get usePin;

  /// No description provided for @invalidPin.
  ///
  /// In en, this message translates to:
  /// **'The PIN is incorrect.'**
  String get invalidPin;

  /// No description provided for @cooldownMessage.
  ///
  /// In en, this message translates to:
  /// **'Try again in {seconds} seconds.'**
  String cooldownMessage(int seconds);

  /// No description provided for @configurePin.
  ///
  /// In en, this message translates to:
  /// **'Set PIN'**
  String get configurePin;

  /// No description provided for @changePin.
  ///
  /// In en, this message translates to:
  /// **'Change PIN'**
  String get changePin;

  /// No description provided for @disablePin.
  ///
  /// In en, this message translates to:
  /// **'Disable PIN'**
  String get disablePin;

  /// No description provided for @currentPin.
  ///
  /// In en, this message translates to:
  /// **'Current PIN'**
  String get currentPin;

  /// No description provided for @newPin.
  ///
  /// In en, this message translates to:
  /// **'New PIN'**
  String get newPin;

  /// No description provided for @confirmPin.
  ///
  /// In en, this message translates to:
  /// **'Confirm PIN'**
  String get confirmPin;

  /// No description provided for @pinsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'PINs do not match.'**
  String get pinsDoNotMatch;

  /// No description provided for @biometricLock.
  ///
  /// In en, this message translates to:
  /// **'Biometric unlock'**
  String get biometricLock;

  /// No description provided for @biometricUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Strong biometric authentication is unavailable.'**
  String get biometricUnavailable;

  /// No description provided for @autoLock.
  ///
  /// In en, this message translates to:
  /// **'Auto-lock'**
  String get autoLock;

  /// No description provided for @autoLockTimeout.
  ///
  /// In en, this message translates to:
  /// **'Auto-lock timeout'**
  String get autoLockTimeout;

  /// No description provided for @immediately.
  ///
  /// In en, this message translates to:
  /// **'Immediately'**
  String get immediately;

  /// No description provided for @seconds30.
  ///
  /// In en, this message translates to:
  /// **'30 seconds'**
  String get seconds30;

  /// No description provided for @minute1.
  ///
  /// In en, this message translates to:
  /// **'1 minute'**
  String get minute1;

  /// No description provided for @minutes5.
  ///
  /// In en, this message translates to:
  /// **'5 minutes'**
  String get minutes5;

  /// No description provided for @minutes15.
  ///
  /// In en, this message translates to:
  /// **'15 minutes'**
  String get minutes15;

  /// No description provided for @hiddenItemsProtection.
  ///
  /// In en, this message translates to:
  /// **'Protect hidden items'**
  String get hiddenItemsProtection;

  /// No description provided for @securityFailClosed.
  ///
  /// In en, this message translates to:
  /// **'Protected data stays unavailable until authentication succeeds.'**
  String get securityFailClosed;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @themeSetting.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeSetting;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get systemDefault;

  /// No description provided for @lightTheme.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightTheme;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkTheme;

  /// No description provided for @languageSetting.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageSetting;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @urdu.
  ///
  /// In en, this message translates to:
  /// **'Urdu'**
  String get urdu;

  /// No description provided for @dynamicColor.
  ///
  /// In en, this message translates to:
  /// **'Dynamic color'**
  String get dynamicColor;

  /// No description provided for @fontScale.
  ///
  /// In en, this message translates to:
  /// **'Text size'**
  String get fontScale;

  /// No description provided for @reduceMotion.
  ///
  /// In en, this message translates to:
  /// **'Reduce motion'**
  String get reduceMotion;

  /// No description provided for @accessibilitySettings.
  ///
  /// In en, this message translates to:
  /// **'Accessibility'**
  String get accessibilitySettings;

  /// No description provided for @settingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Settings saved'**
  String get settingsSaved;

  /// No description provided for @securityOperationFailed.
  ///
  /// In en, this message translates to:
  /// **'Security settings could not be changed.'**
  String get securityOperationFailed;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTitle;

  /// No description provided for @appVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version 1.0 release candidate'**
  String get appVersionLabel;

  /// No description provided for @privacySummary.
  ///
  /// In en, this message translates to:
  /// **'Offline by default. No account, ads, analytics or tracking.'**
  String get privacySummary;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ur'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ur':
      return AppLocalizationsUr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
