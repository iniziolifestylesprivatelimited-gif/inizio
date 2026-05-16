import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/address_model.dart';
import '../utils/constants.dart'; // <- import ApiConstants

class AddressService {
  final String baseUrl = '${ApiConstants.baseUrl}/address'; // <- use constant

  final String? token;

  AddressService({this.token});

  Map<String, String> get headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  Future<List<Address>> getAddresses() async {
    final res = await http.get(Uri.parse(baseUrl), headers: headers);
    if (res.statusCode == 200) {
      List data = json.decode(res.body);
      return data.map((e) => Address.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load addresses');
    }
  }

  Future<List<dynamic>> getCountries() async {
  final res = await http.get(
    Uri.parse('${ApiConstants.baseUrl}/locations/countries'),
    headers: headers,
  );
  if (res.statusCode == 200) {
    return json.decode(res.body);
  } else {
    throw Exception('Failed to load countries');
  }
}

Future<List<dynamic>> getStates(String countryCode) async {
  final res = await http.get(
    Uri.parse('${ApiConstants.baseUrl}/locations/states/$countryCode'),
    headers: headers,
  );
  if (res.statusCode == 200) {
    return json.decode(res.body);
  } else {
    throw Exception('Failed to load states');
  }
}

Future<List<dynamic>> getCities(String countryCode, String stateCode) async {
  final res = await http.get(
    Uri.parse('${ApiConstants.baseUrl}/locations/cities/$countryCode/$stateCode'),
    headers: headers,
  );
  if (res.statusCode == 200) {
    return json.decode(res.body);
  } else {
    throw Exception('Failed to load cities');
  }
}


  Future<Address> addAddress(Address address) async {
    final res = await http.post(
      Uri.parse(baseUrl),
      headers: headers,
      body: json.encode(address.toJson()),
    );
    if (res.statusCode == 201) {
      return Address.fromJson(json.decode(res.body));
    } else {
      throw Exception('Failed to add address');
    }
  }

  Future<Address> updateAddress(String id, Address address) async {
    final res = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: headers,
      body: json.encode(address.toJson()),
    );
    if (res.statusCode == 200) {
      return Address.fromJson(json.decode(res.body));
    } else {
      throw Exception('Failed to update address');
    }
  }

  Future<void> deleteAddress(String id) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: headers,
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to delete address');
    }
  }
}
