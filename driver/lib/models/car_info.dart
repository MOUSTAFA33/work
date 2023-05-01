class CarInfo {
  final String idDriver;
  final String name;
  final String nbrPlace;
  final String matricule;

  CarInfo(this.idDriver, this.name, this.nbrPlace, this.matricule);

  CarInfo.fromData(Map<String, dynamic> data)
      : idDriver = data['id'],
        name = data['name'],
        nbrPlace = data['nbrPlace'],
        matricule = data['matricule'];

  Map<String, dynamic> toJson() {
    return {
      'id': idDriver,
      'name': name,
      'nbrPlace': nbrPlace,
      'matricule': matricule,
    };
  }
}
