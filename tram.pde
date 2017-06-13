class Tram{
  int sx,sy,tx,ty;
  int[] noise_levels;
  int traffic_level;

  Tram(int sx, int sy,int tx,int ty, int[] noise_levels, int traffic_level){
    this.noise_levels = noise_levels;
    this.traffic_level = traffic_level;
    this.sx = sx;
    this.sy = sy; //<>// //<>// //<>// //<>//
    this.tx = tx;
    this.ty = ty;
  }
  
  void display(){
    //strokeWeight(0.25+1.3*traffic_level);
    line(this.sx,this.sy,this.tx,this.ty);
  }
     
}