import 'package:flutter/material.dart';

import '../features/ai_generation/presentation/screens/generation_failure_screen.dart';
import '../features/ai_generation/presentation/screens/generation_setup_screen.dart';
import '../features/ai_generation/presentation/screens/insufficient_text_screen.dart';
import '../features/ai_generation/presentation/screens/local_generation_processing_screen.dart';
import '../features/ai_generation/presentation/screens/low_memory_screen.dart' as generation;
import '../features/ai_generation/presentation/screens/missing_model_screen.dart';
import '../features/documents/presentation/screens/corrupted_document_screen.dart';
import '../features/documents/presentation/screens/document_details_screen.dart';
import '../features/documents/presentation/screens/document_library_grid_screen.dart';
import '../features/documents/presentation/screens/document_library_list_screen.dart';
import '../features/documents/presentation/screens/extracted_text_review_screen.dart';
import '../features/documents/presentation/screens/extraction_success_screen.dart';
import '../features/documents/presentation/screens/global_search_no_results_screen.dart';
import '../features/documents/presentation/screens/global_search_results_screen.dart';
import '../features/documents/presentation/screens/import_files_screen.dart';
import '../features/documents/presentation/screens/import_loading_screen.dart';
import '../features/documents/presentation/screens/insufficient_storage_screen.dart';
import '../features/documents/presentation/screens/library_filters_sorting_screen.dart';
import '../features/documents/presentation/screens/organize_documents_screen.dart';
import '../features/documents/presentation/screens/scanned_pdf_ocr_screen.dart';
import '../features/documents/presentation/screens/selected_file_preview_screen.dart';
import '../features/documents/presentation/screens/text_extraction_processing_screen.dart';
import '../features/documents/presentation/screens/unreadable_text_screen.dart';
import '../features/documents/presentation/screens/unsupported_file_screen.dart';
import '../features/flashcards/presentation/screens/card_editor_screen.dart';
import '../features/flashcards/presentation/screens/deck_overview_screen.dart';
import '../features/flashcards/presentation/screens/session_summary_screen.dart';
import '../features/flashcards/presentation/screens/study_card_back_screen.dart';
import '../features/flashcards/presentation/screens/study_card_front_screen.dart';
import '../features/home/presentation/screens/empty_home_screen.dart';
import '../features/home/presentation/screens/home_dashboard_screen.dart';
import '../features/model_management/presentation/screens/delete_model_confirmation_screen.dart';
import '../features/model_management/presentation/screens/download_failed_screen.dart';
import '../features/model_management/presentation/screens/downloading_screen.dart';
import '../features/model_management/presentation/screens/low_memory_screen.dart' as models;
import '../features/model_management/presentation/screens/not_installed_screen.dart';
import '../features/model_management/presentation/screens/offline_not_installed_screen.dart';
import '../features/model_management/presentation/screens/ready_offline_screen.dart';
import '../features/onboarding/presentation/screens/ai_study_tools_screen.dart';
import '../features/onboarding/presentation/screens/import_notes_screen.dart';
import '../features/onboarding/presentation/screens/private_offline_screen.dart';
import '../features/onboarding/presentation/screens/splash_screen.dart';
import '../features/privacy/presentation/screens/privacy_screen.dart';
import '../features/quizzes/presentation/screens/answer_review_screen.dart';
import '../features/quizzes/presentation/screens/mcq_screen.dart';
import '../features/quizzes/presentation/screens/quiz_history_screen.dart';
import '../features/quizzes/presentation/screens/quiz_results_screen.dart';
import '../features/quizzes/presentation/screens/quiz_setup_screen.dart';
import '../features/quizzes/presentation/screens/short_answer_screen.dart';
import '../features/quizzes/presentation/screens/true_false_screen.dart';
import '../features/quizzes/presentation/screens/unanswered_confirmation_screen.dart';
import '../features/settings/presentation/screens/clear_all_local_data_confirmation_screen.dart';
import '../features/settings/presentation/screens/clear_cache_confirmation_screen.dart';
import '../features/settings/presentation/screens/delete_file_confirmation_screen.dart';
import '../features/settings/presentation/screens/help_about_screen.dart';
import '../features/settings/presentation/screens/preferences_screen.dart';
import '../features/settings/presentation/screens/settings_hub_screen.dart';
import '../features/settings/presentation/screens/storage_screen.dart';
import '../features/study/presentation/screens/study_library_screen.dart';
import '../features/study/presentation/screens/create_study_folder_screen.dart';
import '../features/study/presentation/screens/revision_hub_screen.dart';
import '../features/study/presentation/screens/statistics_dashboard_screen.dart';
import '../features/study/presentation/screens/study_planner_screen.dart';
import '../features/study/presentation/screens/subject_details_screen.dart';
import '../features/subscription/presentation/screens/manage_subscription_screen.dart';
import '../features/subscription/presentation/screens/payment_failure_screen.dart';
import '../features/subscription/presentation/screens/payment_processing_screen.dart';
import '../features/subscription/presentation/screens/payment_success_screen.dart';
import '../features/subscription/presentation/screens/purchase_confirmation_screen.dart';
import '../features/subscription/presentation/screens/restore_purchases_screen.dart';
import '../features/subscription/presentation/screens/upgrade_premium_screen.dart';

abstract final class AppRoutes {
  static const splash = '/splash';
  static const home = '/home';
  static const onboardingImport = '/onboarding/import';
  static const onboardingAi = '/onboarding/ai';
  static const onboardingPrivate = '/onboarding/private';
  static const emptyHome = '/home/empty';
  static const importFiles = '/documents/import';
  static const selectedPreview = '/documents/preview';
  static const importLoading = '/documents/import-loading';
  static const unsupported = '/documents/unsupported';
  static const corrupted = '/documents/corrupted';
  static const unreadable = '/documents/unreadable';
  static const ocr = '/documents/ocr';
  static const storageError = '/documents/storage-error';
  static const extractionProcessing = '/documents/extraction-processing';
  static const extractionReview = '/documents/extraction-review';
  static const extractionSuccess = '/documents/extraction-success';
  static const details = '/documents/details';
  static const list = '/documents/list';
  static const grid = '/documents/grid';
  static const filters = '/documents/filters';
  static const searchResults = '/documents/search';
  static const searchEmpty = '/documents/search-empty';
  static const organize = '/documents/organize';
  static const generationSetup = '/generation/setup';
  static const generationProcessing = '/generation/processing';
  static const missingModel = '/generation/missing-model';
  static const insufficientText = '/generation/insufficient-text';
  static const generationLowMemory = '/generation/low-memory';
  static const generationFailure = '/generation/failure';
  static const deck = '/flashcards/deck';
  static const cardFront = '/flashcards/front';
  static const cardBack = '/flashcards/back';
  static const editor = '/flashcards/editor';
  static const summary = '/flashcards/summary';
  static const quizSetup = '/quiz/setup';
  static const mcq = '/quiz/mcq';
  static const trueFalse = '/quiz/true-false';
  static const shortAnswer = '/quiz/short-answer';
  static const unanswered = '/quiz/unanswered';
  static const results = '/quiz/results';
  static const review = '/quiz/review';
  static const history = '/quiz/history';
  static const studyLibrary = '/study/library';
  static const createFolder = '/study/create-folder';
  static const subject = '/study/subject';
  static const revision = '/study/revision';
  static const statistics = '/study/statistics';
  static const planner = '/study/planner';
  static const notInstalled = '/models/not-installed';
  static const downloading = '/models/downloading';
  static const readyOffline = '/models/ready';
  static const downloadFailed = '/models/download-failed';
  static const modelLowMemory = '/models/low-memory';
  static const offline = '/models/offline';
  static const deleteModel = '/models/delete';
  static const settings = '/settings';
  static const preferences = '/settings/preferences';
  static const storage = '/settings/storage';
  static const privacy = '/settings/privacy';
  static const help = '/settings/help';
  static const clearCache = '/settings/clear-cache';
  static const deleteFile = '/settings/delete-file';
  static const clearData = '/settings/clear-data';
  static const premium = '/subscription/premium';
  static const purchase = '/subscription/purchase';
  static const processing = '/subscription/processing';
  static const paymentSuccess = '/subscription/success';
  static const paymentFailure = '/subscription/failure';
  static const restore = '/subscription/restore';
  static const manage = '/subscription/manage';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final page = <String, Widget>{
      splash: const SplashDesignScreen(), home: const HomeDashboardScreen(), onboardingImport: const ImportNotesScreen(), onboardingAi: const AiStudyToolsScreen(), onboardingPrivate: const PrivateOfflineScreen(), emptyHome: const EmptyHomeScreen(),
      importFiles: const ImportFilesScreen(), selectedPreview: const SelectedFilePreviewScreen(), importLoading: const ImportLoadingScreen(), unsupported: const UnsupportedFileScreen(), corrupted: const CorruptedDocumentScreen(), unreadable: const UnreadableTextScreen(), ocr: const ScannedPdfOcrScreen(), storageError: const InsufficientStorageScreen(), extractionProcessing: const TextExtractionProcessingScreen(), extractionReview: const ExtractedTextReviewScreen(), extractionSuccess: const ExtractionSuccessScreen(), details: const DocumentDetailsScreen(), list: const DocumentLibraryListScreen(), grid: const DocumentLibraryGridScreen(), filters: const LibraryFiltersSortingScreen(), searchResults: const GlobalSearchResultsScreen(), searchEmpty: const GlobalSearchNoResultsScreen(), organize: const OrganizeDocumentsScreen(),
      generationSetup: const GenerationSetupScreen(), generationProcessing: const LocalGenerationProcessingScreen(), missingModel: const MissingModelScreen(), insufficientText: const InsufficientTextScreen(), generationLowMemory: const generation.GenerationLowMemoryScreen(), generationFailure: const GenerationFailureScreen(),
      deck: const DeckOverviewScreen(), cardFront: const StudyCardFrontScreen(), cardBack: const StudyCardBackScreen(), editor: const CardEditorScreen(), summary: const SessionSummaryScreen(),
      quizSetup: const QuizSetupScreen(), mcq: const QuizMcqScreen(), trueFalse: const QuizTrueFalseScreen(), shortAnswer: const QuizShortAnswerScreen(), unanswered: const UnansweredConfirmationScreen(), results: const QuizResultsScreen(), review: const AnswerReviewScreen(), history: const QuizHistoryScreen(),
      studyLibrary: const StudyLibraryScreen(), createFolder: const CreateStudyFolderScreen(), subject: const SubjectDetailsScreen(), revision: const RevisionHubScreen(), statistics: const StatisticsDashboardScreen(), planner: const StudyPlannerScreen(),
      notInstalled: const ModelNotInstalledScreen(), downloading: const ModelDownloadingScreen(), readyOffline: const ReadyOfflineScreen(), downloadFailed: const ModelDownloadFailedScreen(), modelLowMemory: const models.ModelLowMemoryScreen(), offline: const OfflineNotInstalledScreen(), deleteModel: const DeleteModelConfirmationScreen(),
      AppRoutes.settings: const SettingsHubScreen(), preferences: const PreferencesScreen(), storage: const StorageScreen(), privacy: const PrivacyScreen(), help: const HelpAboutScreen(), clearCache: const ClearCacheConfirmationScreen(), deleteFile: const DeleteFileConfirmationScreen(), clearData: const ClearAllLocalDataConfirmationScreen(),
      premium: const UpgradePremiumScreen(), purchase: const PurchaseConfirmationScreen(), processing: const PaymentProcessingScreen(), paymentSuccess: const PaymentSuccessScreen(), paymentFailure: const PaymentFailureScreen(), restore: const RestorePurchasesScreen(), manage: const ManageSubscriptionScreen(),
    }[settings.name] ?? const HomeDashboardScreen();
    return MaterialPageRoute<void>(settings: settings, builder: (_) => page);
  }
}
