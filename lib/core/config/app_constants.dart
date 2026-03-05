class AppConstants {
  static const String appName = 'Mi Boda';
  static const String appTagline = 'Tu boda, simplificada';

  // ── White-label config ──────────────────────────────────────
  // The wedding planner this app belongs to.
  // All signups via this app are automatically linked to her.
  // TODO: Replace with the real wedding_planners.id from Supabase
  static const String plannerId = '84de261c-18e1-4ac8-8ebd-d53a61d5fbeb';

  // Roles — same as web
  static const String roleSuperAdmin = 'superadmin';
  static const String roleWeddingPlanner = 'wedding_planner';
  static const String roleClient = 'client';
  static const String roleSelfPlanner = 'self_planner';

  // Wedding modes
  static const String modeManaged = 'managed';
  static const String modeSelf = 'self';
  static const String modeResold = 'resold';

  // Subscription plans
  static const String planFree = 'free';
  static const String planPro = 'pro';
  static const String planPremium = 'premium';
}
