
import 'package:contacts_service/contacts_service.dart';

class ContactDetails {
  // Name
  String? displayName, givenName, middleName, prefix, suffix, familyName;

// Company
  String? company, jobTitle;

// Email addresses
  List<Item> emails = [];

// Phone numbers
  List<Item> phones = [];

// Post addresses
  List<PostalAddress> postalAddresses = [];
}