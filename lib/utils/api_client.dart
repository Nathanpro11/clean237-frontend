class ApiClient {
  // L'IP 10.0.2.2 permet à l'émulateur Android d'accéder directement au localhost:3000 de ton PC
  static const String baseUrl = 'http://10.0.2'; 
  
  static Map<String, String> getHeaders({String? token, String? roleId}) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      if (roleId != null) 'x-role-id': roleId, // Ton en-tête d'évaluation RBAC !
    };
  }
}
