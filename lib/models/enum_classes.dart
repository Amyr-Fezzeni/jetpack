enum Gender { male, female, other }
enum UserStatus { active, banned, disabled, deleted }
enum Role { creator, admin }

UserStatus getUserStatusFromString(String? value) =>
    {
      'active': UserStatus.active,
      'banned': UserStatus.banned,
      'deleted': UserStatus.deleted
    }[value] ??
    UserStatus.disabled;


Gender getUserGenderFromString(String? value) => {
      'male': Gender.male,
      'female': Gender.female
    }[value]?? Gender.other;


Role getUserRoleFromString(String? value) =>
    {
      'admin': Role.admin,
    }[value] ??
    Role.creator;