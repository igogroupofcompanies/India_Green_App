/// Named route path constants for GoRouter.
abstract final class Routes {
  // ── Unauthenticated ──────────────────
  static const splash         = '/splash';
  static const languageSelect = '/onboarding/language';
  static const roleSelect     = '/onboarding/roles';
  static const otpLogin       = '/onboarding/otp-login';
  static const userDetails    = '/onboarding/user-details';

  // ── Authenticated (StatefulShellRoute branches) ─
  static const home           = '/home';
  static const market         = '/market';
  static const mandi          = '/mandi';
  static const aiDoctor       = '/ai-doctor';
  static const projects       = '/projects';
  static const products       = '/products';
  static const services       = '/services';
  static const course         = '/course';
  static const myBookings     = '/bookings';
  static const admin          = '/admin';
  static const agriProjects          = '/projects/agri-farming';
  static const aquacultureProjects   = '/projects/aquaculture';
  static const livestockProjects     = '/projects/livestock';
  static const farmEngineeringProjects = '/projects/farm-engineering';

  // ── Dashboard ────────────────────────
  static const dashboard      = '/dashboard';
  static const agrimart       = '/agrimart';

  // ── Hubs ─────────────────────────────
  static const hubs           = '/hubs';
  static const profile        = '/hubs/profile';
  static const editProfile    = '/hubs/profile/edit';
  static const vendor         = '/hubs/vendor';
  static const finance        = '/hubs/finance';
  static const wallet         = '/hubs/finance/wallet';
  static const learn          = '/hubs/learn';
  static const jobs           = '/hubs/jobs';
  static const opportunities  = '/hubs/opportunities';
}
