import 'package:get/get.dart';
import 'package:ninaivu/core/constants/translation_keys.dart';

class LocalizedValueHelper {
  LocalizedValueHelper._();

  static String followUpType(String value) {
    switch (value.trim().toLowerCase()) {
      case 'call':
        return TranslationKeys.call.tr;
      case 'whatsapp':
        return TranslationKeys.whatsapp.tr;
      case 'visit':
        return TranslationKeys.visit.tr;
      case 'payment reminder':
        return TranslationKeys.paymentReminder.tr;
      case 'document collection':
        return TranslationKeys.documentCollectionReminder.tr;
      case 'renewal discussion':
        return TranslationKeys.renewalReminder.tr;
      default:
        return value;
    }
  }

  static String followUpStatus(String value) {
    switch (value.trim().toLowerCase()) {
      case 'pending':
        return TranslationKeys.pending.tr;
      case 'completed':
        return TranslationKeys.completed.tr;
      case 'missed':
        return TranslationKeys.missed.tr;
      case 'cancelled':
        return TranslationKeys.cancelled.tr;
      default:
        return value;
    }
  }

  static String policyInsuranceType(String value) {
    switch (value.trim().toLowerCase()) {
      case 'bike':
        return TranslationKeys.bike.tr;
      case 'car':
        return TranslationKeys.car.tr;
      case 'health':
        return TranslationKeys.health.tr;
      case 'term':
        return TranslationKeys.term.tr;
      case 'life':
        return TranslationKeys.life.tr;
      case 'commercial vehicle':
        return TranslationKeys.commercialVehicle.tr;
      case 'other':
        return TranslationKeys.other.tr;
      default:
        return value;
    }
  }

  static String paymentFrequency(String value) {
    switch (value.trim().toLowerCase()) {
      case 'monthly':
        return TranslationKeys.monthly.tr;
      case 'quarterly':
        return TranslationKeys.quarterly.tr;
      case 'half-yearly':
        return TranslationKeys.halfYearly.tr;
      case 'yearly':
        return TranslationKeys.yearly.tr;
      case 'single':
        return TranslationKeys.single.tr;
      case 'other':
        return TranslationKeys.other.tr;
      default:
        return value;
    }
  }

  static String policyStatus(String value) {
    switch (value.trim().toLowerCase()) {
      case 'active':
        return TranslationKeys.active.tr;
      case 'expired':
        return TranslationKeys.expired.tr;
      case 'renewed':
        return TranslationKeys.markRenewed.tr.replaceFirst('Mark ', '');
      case 'cancelled':
        return TranslationKeys.cancelled.tr;
      case 'pending':
        return TranslationKeys.pending.tr;
      default:
        return value;
    }
  }

  static String renewalStatus(String value) {
    switch (value.trim().toLowerCase()) {
      case 'not contacted':
        return TranslationKeys.notContacted.tr;
      case 'contacted':
        return TranslationKeys.contacted.tr;
      case 'interested':
        return TranslationKeys.interested.tr;
      case 'quote sent':
        return TranslationKeys.quoteSent.tr;
      case 'payment pending':
        return TranslationKeys.paymentPending.tr;
      case 'renewed':
        return TranslationKeys.markRenewed.tr.replaceFirst('Mark ', '');
      case 'lost':
        return TranslationKeys.lost.tr;
      case 'not reachable':
        return TranslationKeys.notReachable.tr;
      default:
        return value;
    }
  }

  static String reminderType(String value) {
    switch (value.trim().toLowerCase()) {
      case 'renewal reminder':
        return TranslationKeys.renewalReminder.tr;
      case 'payment reminder':
        return TranslationKeys.paymentReminder.tr;
      case 'document collection reminder':
        return TranslationKeys.documentCollectionReminder.tr;
      case 'follow-up reminder':
        return TranslationKeys.followUpReminder.tr;
      default:
        return value;
    }
  }
}
