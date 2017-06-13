
class Reader{
  int tramCount;
  String[] lines;
  IntList validTrams;
  int[] maxNoise= {0,0,0};
  
  Reader(){
    this.lines = loadStrings("streets_and_noise_level.csv");
    this.validTrams = new IntList();
  }

  int prepare(Bounds bounds){
    //data_layers = new Data_Layer[layers.length];
    float prevshapeid=-1.0, shapeid=-1.0;
    String[] row;
    float x=0,y=0,xprev=0,yprev=0;
    float xmax=-1.e6, xmin=1.e6, ymax=-1.e6, ymin=1.e6;
    for (int n=1;n<this.lines.length;n++){
      row = split(this.lines[n], ",");
      shapeid = float(row[0]);
      x=float(row[1]); y=float(row[2]);
      xmax=max(x,xmax); ymax=max(y,ymax);
      xmin=min(x,xmin); ymin=min(y,ymin);
      if (shapeid==prevshapeid && (bounds.isin(x,y) || bounds.isin(xprev,yprev))) {
        this.tramCount++;
        this.validTrams.append(n);
      }
      xprev = x; yprev = y;
      prevshapeid=shapeid;
    }
    print("Found ",this.tramCount," trams\n");
    println ("X range = ",xmin,xmax);  
    println ("Y range = ",ymin,ymax);
    return this.tramCount;
  }

  Tram[] read(){
    Tram[] trams = new Tram[this.tramCount];
    String[] row;
    float x=0,y=0,xprev=0,yprev=0;
    int curTram = 0, traffic;
    int[] noises;
    noises = new int[3];
    //Columns are shapeid,xp,yp,Traffic,Train,Industrial
    for (int n: validTrams){
      row = split(lines[n-1], ",");
      xprev=float(row[1]); yprev=float(row[2]); 
      row = split(lines[n], ",");
      x=float(row[1]); y=float(row[2]); 
      noises[0] = int(row[3]);
      noises[1] = int(row[4]);
      noises[2] = int(row[5]);
      traffic = int(random(4));    
      trams[curTram] = new Tram(bounds.xtrans(xprev), bounds.ytrans(yprev), bounds.xtrans(x), bounds.ytrans(y), noises, traffic);
      curTram++;
    } 
    return trams;
  }

}

  