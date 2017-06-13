class Particle {
  int x;
  int y;
  int age;
  color mycolor;
  int maxAge = 40;
  int waitTime = 40;
  int baseAlpha = 20;
  float[] alphas;
  float[] radius;
  
  Particle(float x, float y, color c){
    this.x = int(x);
    this.y = int(y);
    this.mycolor = c;
    this.age = maxAge;
    this.waitTime = floor(random(waitTime));
    this.radius = new float[maxAge+1];
    this.alphas = new float[maxAge+1];
    for (int a=0;a<maxAge+1;a++){
      this.radius[a] = (maxRadius*(maxAge-a)/maxAge);
      this.alphas[a] = (min(255,baseAlpha+(255-baseAlpha)*a/maxAge));    
    }
  }
  
  void setMaxRadius(int maxR){
    for (int a=0;a<maxAge+1;a++){
      this.radius[a] = (maxR*(maxAge-a)/maxAge);    
    }
  }
  
  void renew(float x, float y, color c){
    this.x = int(x);
    this.y = int(y);
    this.mycolor = c;
    this.age = maxAge;
  }
  
  void evolve(){
    this.age--;
    if (this.age<0) {
      this.age=maxAge+waitTime;
    }
  }
  
  void display(){
    if (this.age<this.maxAge){
      fill(this.mycolor,this.alphas[this.age]);
  //    stroke(mycolor,alphas[age]);
      ellipse(this.x, this.y, this.radius[this.age],this.radius[this.age]);
    }
  }
}