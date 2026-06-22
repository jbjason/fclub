

class MyApiUrl {
  static const String baseUrl = //"https://op-media.up.railway.app";
      "https://op-media-backend.up.railway.app";
  static const String version = "v1";

  static const String me = "me";
  static const String deleteAccount = "auth/me";
  static const String clients = "clients";
  static String updateEmployee(String uId) => "admin/employees/$uId";

  // task
  static const String tasks = "tasks";
  static String taskById(String id) => "tasks/$id";
  static String taskMessages(String taskId) => "tasks/$taskId/messages";

  static const String sessions = "sessions";
  static const String startSession = "sessions/start";
  static String stopSession(String id) => "sessions/$id/stop";

  // screenshots
  static const String screenshots = "screenshots";
  static const String uploadScreenshot = "screenshots/upload";

  static const String leads = "leads";
  static const String calls = "calls";
  static const String messagesContacts = "messages/contacts";
  static const String messagesConversations = "messages/conversations";
  static String messagesRead(String conversationId) =>
      "messages/conversations/$conversationId/messages/read";
  static String messagesByConversation(String conversationId) =>
      "messages/conversations/$conversationId/messages";
  static String messagesSend(String conversationId) =>
      "messages/conversations/$conversationId/messages";

  // Clients
  static const String reports = "reports";

  // admin
  static const String adminEmployees = "admin/employees";
  static const String adminEmployeesInvite = "admin/invites";
  static String adminEmployeeById(String uid) => "admin/employees/$uid";

  // admin clients
  static const String adminClients = "clients";
  static String adminClientById(String id) => "clients/$id";

  // admin projects
  static const String adminProjects = "projects";
  static String adminProjectById(String id) => "projects/$id";
  static String adminProjectClients(String projectId) =>
      "projects/$projectId/clients";
  static const String adminTasks = "tasks";

  // admin reporting
  static const String adminReporting = "reports";
  static const String adminReportGenerate = "reports/generate";

  // admin monitoring
  static const String adminMonitoringScreenshots = "screenshots";
  static String monitoringScreenshotsDelete(String id) => "screenshots/$id";

  // admin history
  static const String adminHistory = "screenshots/stats";

  // admin leads
  static const String adminLeads = "leads";
  static String adminLeeadEdit(String id) => "leads/$id";

  // admin calls (call log entries, e.g. created via "Log Call" on a lead)
  static const String adminCalls = "calls";
  static String adminCallById(String id) => "calls/$id";

  // admin proposal
  static const String adminProposals = "proposals";
  static const String adminProposalsSummary = "proposals/summary";
  static String adminProposalById(String id) => "proposals/$id";
  static const String adminProposalGenerate = "proposals/generate";
}
