class Connection {
  final String uid;
  final String username;
  final DateTime? since;
  final String name;
  final String? profilePicUrl;
  final String? jobTitle;
  final String? organisation;

  Connection({
    required this.uid,
    required this.username,
    this.since,
    required this.name,
    this.profilePicUrl,
    this.jobTitle,
    this.organisation,
  });

  /// Builds a Connection from the result of the Supabase JOIN query:
  ///   connections.select('since, profiles!connection_id(id, username, name, ...)')
  factory Connection.fromMap(Map<String, dynamic> data) {
    final profile = data['profiles'] as Map<String, dynamic>? ?? {};
    return Connection(
      uid: profile['id'] as String? ?? '',
      username: profile['username'] as String? ?? '',
      since: data['since'] != null ? DateTime.parse(data['since'] as String) : null,
      name: profile['name'] as String? ?? profile['username'] as String? ?? '',
      profilePicUrl: profile['profile_pic_url'] as String?,
      jobTitle: profile['job_title'] as String?,
      organisation: profile['organisation'] as String?,
    );
  }
}
