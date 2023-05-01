class Client {

  final String id;
  final String name;
  final String email;
  final String phone;
  final String token;


  Client(this.id, this.name, this.email, this.phone,this.token);

  Client.fromData(Map<String, dynamic> data)
      : id = data['id'],
        name = data['name'],
        email = data['email'],
        phone = data['phone'],
        token = data['token'];


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'token':token
    };
  }
// void show(){
//   print("$name $email $phone");
// }
}