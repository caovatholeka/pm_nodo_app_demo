import 'package:equatable/equatable.dart';

class PersonalState extends Equatable {
  final bool isLoading;
  final String name;
  final String email;
  final String address;

  const PersonalState({
    this.isLoading = false,
    this.name = '',
    this.email = '',
    this.address = '',
  });

  PersonalState copyWith({
    bool? isLoading,
    String? name,
    String? email,
    String? address,
  }) {
    return PersonalState(
      isLoading: isLoading ?? this.isLoading,
      name: name ?? this.name,
      email: email ?? this.email,
      address: address ?? this.address,
    );
  }

  @override
  List<Object?> get props => [isLoading, name, email, address];
}
