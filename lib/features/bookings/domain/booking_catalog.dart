import 'booking.dart';

/// What can be booked from the home-screen quick-booking section.
/// Keep these titles in step with the Projects / Products / Services / Course
/// screens so admins see the same names everywhere.
const bookingCatalog = <BookingType, List<String>>{
  BookingType.project: [
    'Agri Farming Projects',
    'Aquaculture Projects',
    'Livestock Farming Projects',
    'Farm Engineering Projects',
  ],
  BookingType.product: [
    'Agri Farming Inputs',
    'Polyhouse Structure',
    'Horticulture Catalog',
    'Control & Automation',
  ],
  BookingType.service: [
    'Farm Planning & Consulting',
    'Farming Project Setup',
    'Farm Infrastructure',
    'Maintenance & Support',
  ],
  BookingType.course: [
    'Polyhouse Training',
    'Hydroponics Training',
  ],
};
