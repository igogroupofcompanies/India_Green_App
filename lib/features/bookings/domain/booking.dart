enum BookingType {
  project('project', 'Project', 'Book a Project'),
  product('product', 'Product', 'Product Enquiry'),
  service('service', 'Service', 'Book a Service'),
  course('course', 'Course', 'Enrol in Course');

  const BookingType(this.db, this.label, this.sheetTitle);
  final String db;
  final String label;
  final String sheetTitle;

  static BookingType fromDb(String v) =>
      values.firstWhere((t) => t.db == v, orElse: () => BookingType.product);
}

enum BookingStatus {
  pending('pending', 'Pending'),
  confirmed('confirmed', 'Confirmed'),
  completed('completed', 'Completed'),
  cancelled('cancelled', 'Cancelled');

  const BookingStatus(this.db, this.label);
  final String db;
  final String label;

  static BookingStatus fromDb(String v) =>
      values.firstWhere((s) => s.db == v, orElse: () => BookingStatus.pending);
}

class Booking {
  final String id;
  final String userId;
  final BookingType type;
  final String itemTitle;
  final String customerName;
  final String phone;
  final DateTime? preferredDate;
  final String? notes;
  final BookingStatus status;
  final String? adminNotes;
  final DateTime createdAt;

  const Booking({
    required this.id,
    required this.userId,
    required this.type,
    required this.itemTitle,
    required this.customerName,
    required this.phone,
    required this.preferredDate,
    required this.notes,
    required this.status,
    required this.adminNotes,
    required this.createdAt,
  });

  factory Booking.fromJson(Map<String, dynamic> j) => Booking(
        id: j['id'] as String,
        userId: j['user_id'] as String,
        type: BookingType.fromDb(j['type'] as String),
        itemTitle: j['item_title'] as String,
        customerName: j['customer_name'] as String,
        phone: j['phone'] as String,
        preferredDate: j['preferred_date'] == null
            ? null
            : DateTime.parse(j['preferred_date'] as String),
        notes: j['notes'] as String?,
        status: BookingStatus.fromDb(j['status'] as String),
        adminNotes: j['admin_notes'] as String?,
        createdAt: DateTime.parse(j['created_at'] as String).toLocal(),
      );
}
