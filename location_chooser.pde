class Location {
  int x=0;
  int y=0;
  int kind=0;
}  

class Location_Chooser {
  
  int numberOfelements=0, numberOfClasses = 0;
  
  Location_Chooser(int elements, int classes){
    this.numberOfelements = elements;
    this.numberOfClasses = classes;
  }

  int choose(){
    return floor( random(this.numberOfelements));
  }

  Location locate(Tram tram){
    Location loc;
    loc = new Location();
    float position = random(1.0);
    loc.x = int(tram.sx * (1.0-position) + tram.tx * position);
    loc.y = int(tram.sy * (1.0-position) + tram.ty * position);
    loc.kind = floor(random(this.numberOfClasses));
    return loc;
  }
}