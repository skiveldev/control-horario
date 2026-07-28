List<Map<String, Object>> getSeedUserDefinitions() {
  return [
    {
      'email': 'admin@example.com',
      'passwordEnvKey': 'SEED_ADMIN_PASSWORD',
      'displayName': 'Demo Admin',
      'employeeId': 'DEV-001',
      'role': 'admin',
      'weeklyHours': 40.0,
    },
    {
      'email': 'rrhh@example.com',
      'passwordEnvKey': 'SEED_RRHH_PASSWORD',
      'displayName': 'Demo HR Manager',
      'employeeId': 'DEV-002',
      'role': 'rrhh',
      'weeklyHours': 40.0,
    },
    {
      'email': 'employee@example.com',
      'passwordEnvKey': 'SEED_EMPLOYEE_PASSWORD',
      'displayName': 'Demo Employee One',
      'employeeId': 'DEV-003',
      'role': 'employee',
      'weeklyHours': 40.0,
    },
    {
      'email': 'employee2@example.com',
      'passwordEnvKey': 'SEED_EMPLOYEE2_PASSWORD',
      'displayName': 'Demo Employee Two',
      'employeeId': 'DEV-004',
      'role': 'employee',
      'weeklyHours': 25.0,
    },
    {
      'email': 'employee3@example.com',
      'passwordEnvKey': 'SEED_EMPLOYEE3_PASSWORD',
      'displayName': 'Demo Employee Three',
      'employeeId': 'DEV-005',
      'role': 'employee',
      'weeklyHours': 15.0,
    },
  ];
}
