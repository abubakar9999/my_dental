import '../local/database.dart';

class PatientDueSummary {
  final Patient patient;
  final double totalCost;
  final double totalPaid;
  final double totalDiscount;
  final double due;
  final DateTime? lastVisitDate;

  const PatientDueSummary({
    required this.patient,
    required this.totalCost,
    required this.totalPaid,
    this.totalDiscount = 0.0,
    required this.due,
    this.lastVisitDate,
  });
}

class PaymentWithPatient {
  final Payment payment;
  final Patient patient;

  const PaymentWithPatient({
    required this.payment,
    required this.patient,
  });
}

class AppointmentWithPatient {
  final Appointment appointment;
  final Patient patient;

  const AppointmentWithPatient({
    required this.appointment,
    required this.patient,
  });
}
