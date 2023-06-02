class Driver {

  final String id;
  final String name;
  final String email;
  final String phone;
  final String isAvailable;
  final String token;


  Driver(this.id, this.name, this.email, this.phone,this.isAvailable,this.token);

  Driver.fromData(Map<String, dynamic> data)
      : id = data['id'],
        name = data['name'],
        email = data['email'],
        phone = data['phone'],
        isAvailable = data['isAvailable'],
        token = data['token'];


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'isAvailable':isAvailable,
      'token':token
    };
  }
  // void show(){
  //   print("$name $email $phone");
  // }
}