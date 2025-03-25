class Strings {
  final String home;
  final String clients;
  final String exercises;
  final String workoutLibrary;
  final String programs;
  final String evaluations;
  final String posts;
  final String finance;
  final String ranking;
  final String settings;
  final String classes;
  final String notifications;
  final String myPlan;
  final String chat;
  final String login;
  final String search;

  Strings({
    required this.home,
    required this.clients,
    required this.exercises,
    required this.workoutLibrary,
    required this.programs,
    required this.evaluations,
    required this.posts,
    required this.finance,
    required this.ranking,
    required this.settings,
    required this.classes,
    required this.notifications,
    required this.myPlan,
    required this.chat,
    required this.login,
    required this.search,
  });

  // **🇧🇷 Portuguese (First Language for MVP)**
  static final Strings ptBr = Strings(
    home: "Início",
    clients: "Clientes",
    exercises: "Exercícios",
    workoutLibrary: "Biblioteca de Treinos",
    programs: "Programas",
    evaluations: "Avaliações",
    posts: "Posts",
    finance: "Financeiro",
    ranking: "Ranking",
    settings: "Configurações",
    classes: "Aulas",
    notifications: "Notificações",
    myPlan: "Meu Plano",
    chat: "Chat",
    login: "Entrar",
    search: "Buscar",
  );

  // **🇺🇸 English (Will Be the Default After Global Launch)**
  static final Strings enUs = Strings(
    home: "Home",
    clients: "Clients",
    exercises: "Exercises",
    workoutLibrary: "Workout Library",
    programs: "Programs",
    evaluations: "Evaluations",
    posts: "Posts",
    finance: "Finance",
    ranking: "Ranking",
    settings: "Settings",
    classes: "Classes",
    notifications: "Notifications",
    myPlan: "My Plan",
    chat: "Chat",
    login: "Login",
    search: "Search",
  );

  static const String appLogo = 'assets/fitclub_logo.png';
}
