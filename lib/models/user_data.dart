/// User-facing profile data, stored in the public.profiles table.
class UserData {
  final String uid;
  final String username;
  final String? name;
  String? profilePicUrl;
  String? coverPicUrl;
  String? jobTitle;
  String? organisation;
  String? location;
  String? address;
  List<String>? phoneNumbers;
  List<String>? emails;

  // Links section
  String? linkSectionHeader;
  List<String>? linksText;
  List<String>? linkUrl;

  // About me
  String? aboutMe;

  // Socials. socialIcons holds a lowercase icon-key (e.g. "instagram") used
  // to resolve `assets/icons/social_icons/<key>.png`.
  List<String>? socialNames;
  List<String>? socialUrl;
  List<String>? socialIcons;

  // Scheduling link (Calendly, etc.)
  String? scheduling;

  UserData({
    required this.uid,
    required this.username,
    this.name,
    this.profilePicUrl,
    this.coverPicUrl,
    this.jobTitle,
    this.organisation,
    this.location,
    this.address,
    this.phoneNumbers,
    this.emails,
    this.aboutMe,
    this.linkSectionHeader,
    this.linksText,
    this.linkUrl,
    this.socialIcons,
    this.socialNames,
    this.socialUrl,
    this.scheduling,
  });

  UserData copyWith({
    String? name,
    String? profilePicUrl,
    String? coverPicUrl,
    String? jobTitle,
    String? organisation,
    String? location,
    String? address,
    List<String>? phoneNumbers,
    List<String>? emails,
    String? aboutMe,
    String? linkSectionHeader,
    List<String>? linksText,
    List<String>? linkUrl,
    List<String>? socialIcons,
    List<String>? socialNames,
    List<String>? socialUrl,
    String? scheduling,
  }) {
    return UserData(
      uid: uid,
      username: username,
      name: name ?? this.name,
      profilePicUrl: profilePicUrl ?? this.profilePicUrl,
      coverPicUrl: coverPicUrl ?? this.coverPicUrl,
      jobTitle: jobTitle ?? this.jobTitle,
      organisation: organisation ?? this.organisation,
      location: location ?? this.location,
      address: address ?? this.address,
      phoneNumbers: phoneNumbers ?? this.phoneNumbers,
      emails: emails ?? this.emails,
      linkSectionHeader: linkSectionHeader ?? this.linkSectionHeader,
      linksText: linksText ?? this.linksText,
      linkUrl: linkUrl ?? this.linkUrl,
      aboutMe: aboutMe ?? this.aboutMe,
      socialNames: socialNames ?? this.socialNames,
      socialUrl: socialUrl ?? this.socialUrl,
      socialIcons: socialIcons ?? this.socialIcons,
      scheduling: scheduling ?? this.scheduling,
    );
  }

  /// Reads from Supabase Postgres column names (snake_case).
  factory UserData.fromMap(Map<String, dynamic> data) {
    return UserData(
      uid: data['id'] as String? ?? '',
      username: data['username'] as String? ?? '',
      name: data['name'] as String?,
      profilePicUrl: data['profile_pic_url'] as String?,
      coverPicUrl: data['cover_pic_url'] as String?,
      jobTitle: data['job_title'] as String?,
      organisation: data['organisation'] as String?,
      location: data['location'] as String?,
      address: data['address'] as String?,
      phoneNumbers: List<String>.from(data['phone_numbers'] as List? ?? const []),
      emails: List<String>.from(data['emails'] as List? ?? const []),
      linksText: List<String>.from(data['links_text'] as List? ?? const []),
      linkSectionHeader: data['link_section_header'] as String?,
      linkUrl: List<String>.from(data['link_url'] as List? ?? const []),
      aboutMe: data['about_me'] as String?,
      socialIcons: List<String>.from(data['social_icons'] as List? ?? const []),
      socialNames: List<String>.from(data['social_names'] as List? ?? const []),
      socialUrl: List<String>.from(data['social_url'] as List? ?? const []),
      scheduling: data['scheduling'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': uid,
      'username': username,
      'name': name,
      'profile_pic_url': profilePicUrl,
      'cover_pic_url': coverPicUrl,
      'job_title': jobTitle,
      'organisation': organisation,
      'location': location,
      'address': address,
      'phone_numbers': phoneNumbers ?? [],
      'emails': emails ?? [],
      'link_section_header': linkSectionHeader,
      'links_text': linksText ?? [],
      'link_url': linkUrl ?? [],
      'about_me': aboutMe,
      'social_names': socialNames ?? [],
      'social_url': socialUrl ?? [],
      'social_icons': socialIcons ?? [],
      'scheduling': scheduling,
    };
  }

  bool get hasContactInfo =>
      (name?.trim().isNotEmpty ?? false) ||
      (phoneNumbers?.isNotEmpty ?? false) ||
      (emails?.isNotEmpty ?? false);
}
