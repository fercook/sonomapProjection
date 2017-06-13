
//traf", "Train", "Industrial", "Vacio"
//color[] cTo = { traffic_color[1],trains_color[1], industry_color[1],back};
//color[] cFrom = {traffic_color[0], trains_color[0], industry_color[0],back};

//color[] layerColors = {color(255, 0, 0),  color(255, 145, 34),color(0, 0, 255),color(255)};

class Color_Point{
  float value;
  color c;
  Color_Point(float point, color cc){
    this.value = point;
    this.c = cc;
  }
}

class Color_Scale{
  ArrayList<Color_Point> color_points;
  float valMin, valMax;
  int num_points;
  int changing = 0;
  
  Color_Scale(){
    this.valMin = 0;
    this.valMax = 0;
    this.num_points = 0;
    this.color_points = new ArrayList<Color_Point>();
  }
  
  void add_color(float val, color c){
    if (this.num_points==0) {
      this.color_points.add(new Color_Point(val,c) );
      this.valMin = val;
      this.valMax = val;
    } else if(this.num_points==1) {
      Color_Point prev = this.color_points.get(0);
      if (val >= prev.value) {
        this.valMax = val;
        this.color_points.add(new Color_Point(val,c) );
      } else {
        this.valMin = val;
        this.color_points.add(0, new Color_Point(val,c) );
      }
    } else { 
      //Insert color in proper order
      if (val<this.valMin) {
        this.color_points.add(0, new Color_Point(val,c) );
        this.valMin = val;
      } else if (val>=valMax) {
        this.color_points.add(new Color_Point(val,c) );
        this.valMax = val;
      } else {
        Color_Point low, high;
        for (int n=0;n<this.num_points-1;n++){
          low = this.color_points.get(n);
          high = this.color_points.get(n+1);      
          if (val >= low.value && val < high.value){
            this.color_points.add(n+1, new Color_Point(val,c) );
            break;
          }
        }
      }    
    }
    this.num_points++;
  }
  void change_point_value(int point, int upordown){
    if (point>=0 && point < this.num_points) {
      this.changing = 1;
      Color_Point prev = this.color_points.get(point);
      color prevColor = prev.c;
      float prevValue = prev.value;
      // Remove point and update meta data      
      this.color_points.remove(point);
      this.num_points--;      
      this.valMin = this.color_points.get(0).value;
      this.valMax = this.color_points.get(this.num_points-1).value;
      this.add_color(prev.value+upordown, prevColor);
      print(", new value: ",prevValue+upordown,"\n");
      this.changing = 0;
    }
  }
  color get_color(float val){
    color c = color(0);
    if (this.num_points==0) {
      c = color(0);
    } else if(this.num_points==1 || val<=this.valMin) {
      Color_Point cp = this.color_points.get(0);
      c = cp.c;
    } else if (val>=valMax) {
      Color_Point cp = this.color_points.get(this.num_points-1);
      c = cp.c;
    } else {
      Color_Point low, high;
      for (int n=0;n<this.num_points-1;n++){
        low = this.color_points.get(n); //<>// //<>//
        high = this.color_points.get(n+1);      
        if (val >= low.value && val < high.value){            
          c = lerpColor(low.c, high.c, (val-low.value)/(high.value-low.value));
        }
      }
    }
    return c;
  }
  color get_color_at_percent(float percent){
    float val = (this.valMax-this.valMin)*percent+this.valMin;
    return this.get_color(val);
  }
  
  void print_out(){
    Color_Point col;
    for (int n=0;n<this.num_points;n++){
      col = this.color_points.get(n);
      println("  value:",col.value,", color:", int(red(col.c)),",", int(green(col.c)),",", int(blue(col.c)));
    }
  } 
}


/////////////////////////

class Color_Picker{ 
 color[][][][] interpolator;
 float speed = 0.5; // This controls the slope of the curve between two colors.
 Color_Scale[] color_scales;
 int current_scale, current_control_point, value_steps, transition_steps;
 
 Color_Picker(int transition_steps, int value_steps, Color_Scale[] col_scales){
   this.color_scales = col_scales;
   this.value_steps = value_steps; 
   this.transition_steps = transition_steps; 
   this.current_scale = 0;
   this.current_control_point = 0;
   this.interpolator = new color[num_layers][num_layers][transition_steps][value_steps];   
   this.update_interpolator();
   println("Colors ready");
 }
 
 void update_interpolator(){
   float x,tanh;
   color source, target;
   for (int n=0;n<this.color_scales.length;n++){
     for (int m=0;m<this.color_scales.length;m++){
       for (int v=0;v<this.value_steps;v++){
          source = this.color_scales[n].get_color_at_percent(1.0*v/(this.value_steps-1.0));
          target = this.color_scales[m].get_color_at_percent(1.0*v/(this.value_steps-1.0));
          for (int s=0;s<this.transition_steps;s++){         
             x = 2.0*s/(this.transition_steps-1)-1.0; // x between -1 and 1
             tanh = min(1.0,max(0.0,(float)((1.0+Math.tanh((x-0.5)/this.speed)/Math.tanh(0.5/this.speed))/2.0))); // displaced so that domain and range = 0,1          
             interpolator[n][m][s][v]= lerpColor(source, target, tanh);
         }
       }
     }
   }
 }
 
 void change_current_scale(int new_scale){
   if (new_scale >=0 || new_scale < this.color_scales.length){
     this.current_scale = new_scale;
   }
 }
 
void change_current_control_point(int new_point){
   if (new_point >=0 || new_point < this.color_scales[this.current_scale].num_points){
     this.current_control_point = new_point;
   }
 }
 
void change_point_value(int upordown){
  print("Changing scale ",layers[this.current_scale]," point ",this.current_control_point+1);
  noLoop();   //<>// //<>//
  this.color_scales[this.current_scale].change_point_value(this.current_control_point, upordown);
  this.update_interpolator(); //<>// //<>//
  loop();
 } 
 
 void print_out(){
   for (int n=0;n<num_layers;n++){
     println("*** Colors for ",layers[n],":");
     this.color_scales[n].print_out();
   }
 }

 color interpolate(int n, int m, int s, float val){
   // will always choose the target color scale to determine the min/max
   int pos = min(this.value_steps-1,max(0,floor((this.value_steps-1)*(val-this.color_scales[m].valMin)/(this.color_scales[m].valMax-this.color_scales[m].valMin))));   
   return interpolator[n][m][s][pos];
 }
}