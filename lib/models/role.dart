enum UserRole {
  contractor('Contractor'),
  supervisor('Supervisor/Owner');

  const UserRole(this.label);
  final String label;
}
