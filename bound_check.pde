class Bounds{
  float xmin, xmax, ymin, ymax, w, h;
  
  Bounds(float xmin, float xmax, float ymin, float ymax){
    this.xmin = xmin;
    this.xmax = xmax;
    this.ymin = ymin;
    this.ymax = ymax;
    this.w = xmax-xmin;
    this.h = ymax-ymin;
  }
  
  boolean isin(float x, float y){
    return (x >= this.xmin && x <= this.xmax && y>= this.ymin && y<=this.ymax);
  }
  
  void fixRatio(float ratio){
    if (this.w/this.h>ratio) {
      this.ymax = this.ymax+(this.w/ratio-this.h)/2;
      this.ymin = this.ymin-(this.w/ratio-this.h)/2;
      this.h = this.w/ratio;
    } else {
      this.xmax = this.xmax+(this.h*ratio-this.w)/2;
      this.xmin = this.xmin-(this.h*ratio-this.w)/2;
      this.w = this.h*ratio;    
    }    
  }
      
  int xtrans(float x){ //<>// //<>// //<>// //<>//
    return int(Nx*(x-this.xmin)/(this.w));
  }
      
  int ytrans(float y){
    return int(Ny*(y-this.ymin)/(this.h));
  }
  
  void display(){
    println ("X bounds = ",this.xmin,this.xmax);  
    println ("Y bounds = ",this.ymin,this.ymax);
  }

}