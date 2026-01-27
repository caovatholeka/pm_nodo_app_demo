import 'package:equatable/equatable.dart';
import '../../../data/models/entities/profile_entity.dart';
import '../../../data/models/enums/load_status.dart';

class AccountState extends Equatable {
  final LoadStatus loadStatus;
  final LoadStatus logoutStatus;
  final ProfileEntity? profile;
  

  const AccountState({
    this.loadStatus = LoadStatus.INITIAL,
    this.logoutStatus = LoadStatus.INITIAL,
    this.profile,
  });

  AccountState copyWith({
    LoadStatus? loadStatus,
    LoadStatus? logoutStatus,
    ProfileEntity? profile,
  }) {
    return AccountState(
      loadStatus: loadStatus ?? this.loadStatus,
      logoutStatus: logoutStatus ?? this.logoutStatus,
      profile: profile ?? this.profile,
    );
  }

  @override
  List<Object?> get props => [loadStatus, logoutStatus, profile];
}
