
class MyUsers {
  String uid="", name="", email="", password="", access="", manager="", did="";

  MyUsers(String this.uid, String this.name, String this.email, String this.password, String this.access, String this.manager, String this.did);
}

class MyFiles {
  String id="", shared_by="", name="", sharer="";
  List<dynamic> shared_with = List.empty(growable: true);
  int time=0;

  MyFiles(String this.id, String this.name, String this.shared_by, List<dynamic> this.shared_with, int this.time, String this.sharer);
}

class Tickets {
  String name="", owner="", id="";
  int start=0, end=0;

  Tickets(String this.id, String this.name, String this.owner, int this.start, int this.end);
}