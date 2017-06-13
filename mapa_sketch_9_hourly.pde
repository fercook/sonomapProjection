Color_Scale traffic_color = new Color_Scale();
Color_Scale trains_color = new Color_Scale();
Color_Scale industry_color = new Color_Scale();
Color_Scale recreation_color = new Color_Scale();
Color_Scale construction_color = new Color_Scale();

//////// GRAPHICAL PARAMETERS  ---   TOCAR A PARTIR DE AQUI
int maxAge=10; // Afecta la velocidad de transicion de los puntos

final float DRAW_THRESHOLD = 35.0;  // Nivel de ruido a partir del cual se pinta algo, por debajo se hace cero

final int color_steps = 20;  // Cuantos pasos se usan para las escalas de color
final float nivel_vacio = 0.2;  // Cuantos puntos "vacios" aparecen 

// Background color
color back=color(0);

// Radius of the small circles 
int maxRadius = 8;

void prepare_colors(){
  // Agregar un paso para cada escala a gusto...dos, tres, cuatro, los que quieras, 
  // con el valor de ruido (van desde 0 hasta 85)
  // Recomiendo usar el color con el valor mas bajo con el color de fondo, back, asi desaparecen esos puntos
  // Color scale for Traffic
  traffic_color.add_color( 36.0, color(6,10,18) );
  traffic_color.add_color( 40.0, back);//40,45,6011,19,29
  traffic_color.add_color( 70.0, color(40,45,60) );//11,19,29
  traffic_color.add_color( 73.0, color(181,189,239) );
  traffic_color.add_color( 94.0, color(191,199,239) );
  
  // Color scale for Trains
  trains_color.add_color( 50.0, back);
  trains_color.add_color( 67.0, color (6,77,38) );
  trains_color.add_color( 67.0, color(0,106,0));
  trains_color.add_color( 74.0, color(0,186,0));
  trains_color.add_color( 83.0, color (129,255,0));
  
  // Color scale for Industry
  industry_color.add_color( 52.0 , back );
  industry_color.add_color( 58.0, color(11,1,86));//87,148,255
  industry_color.add_color( 67.0, color(87,148,255));
  industry_color.add_color( 70.0, color(0, 110, 221));
  industry_color.add_color( 72.0, color(0,195,255));
  
  // Color scale for Recreation places // POR AHORA SOLO TOMA EL COLOR MAS ALTO
  recreation_color.add_color(80.0, color(255, 248, 139));
  
  // Color scale for Construction places // POR AHORA SOLO TOMA EL COLOR MAS ALTO
  construction_color.add_color( 80.0, color(255, 115, 0));
}
//////// end PARAMETERS  ---   TOCAR hasta AQUI

/* Raw data has 
X min: 4574934.60525
Y min: 423032.210894
transposed, that is 
x <- y-y_min
y <- x-x_min
and the rotated by angle: a=0.803923213179
x <- x cos(a) + y sin(a)
y <- x sin(-a)+ y cos(a)
*/

//import deadpixel.keystone.*;
//Keystone ks;
//CornerPinSurface surface;
//PGraphics offscreen;
PFont f;

final int num_layers = 4; // Layers that are visualized...it's actually three plus the empty layer

String[] layers = {"Viario", "Train", "Industrial", "Total"};
float[] maxNoises;

float[][] data_layers;
int[] age_layer, from_layer, to_layer;
float maxNoise=0.0;
Color_Picker cPicker;

float[][] legend_values;
int[][][] legend_age_layer, legend_from_layer, legend_to_layer;
Particle construction_particle, leisure_particle;

int Nx,Ny;

static final int maxStrokeW=10;
static final int baseAlpha=20;

Tram[] trams;

Bounds bounds;
int tramCount;

int numParticles = 200;
Particle[] particles;
Location_Chooser loc_chooser;

float[][] hourly_factor;

final int legend_value_height = 25;
final int legend_value_width = 86;
final int[] legend_positions ={14,42,70};

int top_legend, top_logo, x_legend, x_logo;

PImage legend_img, logo_img;

void setup() {
  size(1920,1080,P3D);
  Nx = 1920; Ny = 1080;
  
  legend_img = loadImage("leyenda.png"); //<>//
  logo_img = loadImage("sonomap.png");
  
  top_legend = 30;
  top_logo = height-logo_img.height/2;
  x_logo = 0; //width-logo_img.width;
  x_legend=0;
  
  //ks = new Keystone(this);
  //surface = ks.createCornerPinSurface(1920, 1080, 20);
  //offscreen = createGraphics(1920, 1080, P3D);  
  background(back);  
  
  f = createFont("Arial",16,true);
  textFont(f,24);
 
  prepare_colors();
  Color_Scale empty_color = new Color_Scale();
  empty_color.add_color(0.0,back);
  empty_color.add_color(100.0,back);
  Color_Scale[] color_scales = {traffic_color, trains_color, industry_color, empty_color};
 
    data_layers = new float[num_layers][Nx*Ny];
    maxNoises = new float[num_layers];
    int pix; float noise;
    for (int i=0; i<num_layers; i++){
      String[] lines = loadStrings(Nx+"_noise_kernelized_"+layers[i].toLowerCase()+".csv");
      print ("Read ", layers[i],"\n");
      for (int y=0; y<Ny; y++) {
        String[] row = split(lines[y], ",");
        for (int x=0; x<Nx; x++){  
           pix = y*Nx+x;
           data_layers[i][pix] = float(row[x]);
           maxNoises[i] = max(maxNoises[i],float(row[x]));
        }  
      } 
    }
    for (int i=0; i<num_layers-1; i++){
      println ("Max noise in ",layers[i]," is ",maxNoises[i]);
      for (int y=0; y<Ny; y++) {
        for (int x=0; x<Nx; x++){  
           pix = y*Nx+x;
           noise = data_layers[i][pix];
           if (noise >= DRAW_THRESHOLD) { 
             //noise = (noise-0.0)/(maxNoises[i]-0.0);
             //if (noise>=0.0){ noise = (transparencySteps-1)*noise;}
             //else { noise = 0.0; }
           }
           else { noise = 0.0; }
           data_layers[i][pix] = noise;
           //if (noise<0 || noise >transparencySteps-1) { println("Error ",i,pix,noise); }
        }  
      } 
    }     
    // Fill dummy values for empty space    
    for (int i=0;i<data_layers[num_layers-1].length;i++) {
        data_layers[num_layers-1][i] = nivel_vacio*(data_layers[0][i]+data_layers[1][i]+data_layers[2][i]); //(transparencySteps-1);
    }
    age_layer = new int[Nx*Ny];
    from_layer= new int[Nx*Ny]; 
    to_layer = new int[Nx*Ny];
    for (int i=0; i<Nx*Ny; i++){
      age_layer[i] = floor(random(maxAge));
      from_layer[i] = floor(random(num_layers));
      to_layer[i] = floor(random(num_layers));
    }
    cPicker = new Color_Picker(maxAge, color_steps, color_scales);    
    println("Now reading places...");
    String[] leasure_lines = loadStrings("leisure_data.csv");
    String[] construction_lines = loadStrings("constructions_data.csv");
    particles = new Particle[leasure_lines.length+construction_lines.length-2];
    float x,y;
    bounds = new Bounds(5000, 19000, -5100, 2200);
    numParticles = 0;
    for (int n=0; n<leasure_lines.length-1; n++) {
        String[] row = split(leasure_lines[n+1], ",");
        x = float(row[0]); y = float(row[1]);
        if ( bounds.isin(x,y) ){
          particles[numParticles] = new Particle(bounds.xtrans(x), bounds.ytrans(y), recreation_color.get_color_at_percent(0.99) );
          particles[numParticles].age = floor(random(particles[numParticles].maxAge));
          numParticles++;
        }
     } 
    for (int n=0; n<construction_lines.length-1; n++) {
        String[] row = split(construction_lines[n+1], ",");
        x = float(row[0]); y = float(row[1]);
        if ( bounds.isin(x,y) ){
          particles[numParticles] = new Particle(bounds.xtrans(x), bounds.ytrans(y), construction_color.get_color_at_percent(0.99) );
          particles[numParticles].age = floor(random(particles[numParticles].maxAge));
          numParticles++;
        }
     }  
     construction_particle = new Particle(84, 147, construction_color.get_color_at_percent(0.99) );
     construction_particle.age = floor(random(construction_particle.maxAge));
     construction_particle.setMaxRadius(5);
     leisure_particle = new Particle(84, 120, recreation_color.get_color_at_percent(0.99) );
     leisure_particle.age = floor(random(leisure_particle.maxAge));
     leisure_particle.setMaxRadius(5);
     /////
     println("Reading hourly data");
    hourly_factor = new float[24][Nx*Ny];
    for (int h=0; h<24; h++){ 
      println("Reading hour",h);
      String[] lines = loadStrings(Nx+"_noise_kernelized_hourly_"+h+"_viario.csv");
      for (int ny=0; ny<Ny; ny++) {
        String[] row = split(lines[ny], ",");
        for (int nx=0; nx<Nx; nx++){  
           pix = ny*Nx+nx;
           hourly_factor[h][pix] = float(row[nx]);
        }  
      } 
    }     
     
  println("All set");
   ranNumbers= new float[100000];
   for (int n=0;n<100000;n++){
     ranNumbers[n] = random(1.0);
   }
   legend_age_layer = new int[3][legend_value_height][legend_value_width];
   legend_values = new float[legend_value_height][legend_value_width];
   legend_from_layer = new int[3][legend_value_height][legend_value_width];
   legend_to_layer = new int[3][legend_value_height][legend_value_width];
   for (int nx=0;nx<legend_value_width;nx++){
     for (int ny=0;ny<legend_value_height;ny++){
       legend_values[ny][nx]=55+20.0*nx/legend_value_width;
       for (int i=0;i<3;i++){
         legend_age_layer[i][ny][nx] = floor(random(maxAge));
         legend_from_layer[i][ny][nx] = floor(2);
         legend_to_layer[i][ny][nx] = floor(2);
       }
     }
   }
}

int frame=0, timeSpacing = 10;
float[] ranNumbers;

    int kind;
    float ran,accumulated_sum, sum_noises, noise;
    color c;
    int startFrame=0,endFrame=0;
    float remainder=0;
    float sumfactor = (1.0+1.0/nivel_vacio);    
    float[] probabilities = {0,0,0,nivel_vacio};
void draw() {
    background(back);
    frame++;
    //println(frame);
    if (frame>24*timeSpacing-1) {frame=0;} // Dirty
    
    //PVector surfaceMouse = surface.getTransformedMouse();
    //PImage img;
    
  /*offscreen.beginDraw();
    offscreen.background(back);   
    offscreen.loadPixels();*/
    //println("start");
    background(back);   
    loadPixels();
    //for (int pix = 0; pix < offscreen.pixels.length; pix++) {
      for (int pix = 0; pix < pixels.length; pix++) {
      if (data_layers[num_layers-1][pix]>0.0) { // total noise larger than some value...
       age_layer[pix] += 1;      
        if ( age_layer[pix] > maxAge-1){ //transition to another color
          age_layer[pix] = 0; 
          from_layer[pix] = to_layer[pix];
          // Choose the new target color 
          ////// BIASED VERSION
          /*
          sum_noises = nivel_vacio;
          for (int n=0;n<num_layers-1;n++){
            if (data_layers[n][pix]>0){
              probabilities[n]=(n+1);
              sum_noises+=(n+1);
            } else {
              probabilities[n]=0;
            }
          }
          //sum_noises=data_layers[num_layers-1][pix]*sumfactor;
          ran = random(1); 
          accumulated_sum=0.0;
          kind=-1;
          while (ran >= accumulated_sum && kind < num_layers-1){
            kind++;
            //accumulated_sum += data_layers[kind][pix]/sum_noises;
            accumulated_sum += probabilities[kind]/sum_noises;
          } */
          ////// PROPORTIONAL VERSION
         
          sum_noises=data_layers[num_layers-1][pix]*sumfactor;
          ran = random(1); 
          accumulated_sum=0.0;
          kind=-1;
          while (ran >= accumulated_sum && kind < num_layers-1){
            kind++;
            accumulated_sum += data_layers[kind][pix]/sum_noises;
          }     
          
          to_layer[pix] = kind;   //    */      
        }
        if (to_layer[pix]==0){ 
          startFrame = floor(frame/timeSpacing);
          endFrame = (startFrame+1)%24;
          remainder = (frame%24)/23.0;
          noise = (hourly_factor[startFrame][pix]*(1.0-remainder)+remainder*hourly_factor[endFrame][pix]) ;
        } else {
          noise = data_layers[to_layer[pix]][pix] ;
        }
        c = cPicker.interpolate( from_layer[pix], to_layer[pix], age_layer[pix] , noise); 
        //offscreen.pixels[pix] = c;
        pixels[pix] = c;
      } 
    }
    
      //println("end draw particles");
      //offscreen.image(logo_img, x_logo, top_logo);
      //offscreen.image(legend_img, x_legend,top_legend);
      image(logo_img, x_logo, top_logo);
      image(legend_img, x_legend,top_legend);
      int pix;
       for (int leg=0;leg<3;leg++){
         for (int ny=0;ny<legend_value_height;ny++){
          for (int nx=0;nx<legend_value_width;nx++){
           legend_age_layer[leg][ny][nx] += 1;      
          if ( legend_age_layer[leg][ny][nx] > maxAge-1){ //transition to another color
            legend_age_layer[leg][ny][nx] = 0; 
            ran = random(1); 
            legend_from_layer[leg][ny][nx] = legend_to_layer[leg][ny][nx];
            if (ran>nivel_vacio){
              legend_to_layer[leg][ny][nx] = leg; 
            } else {
              legend_to_layer[leg][ny][nx] = 3; // vacio
            }
          }
          noise = legend_values[ny][nx];
          c = cPicker.interpolate( legend_from_layer[leg][ny][nx], legend_to_layer[leg][ny][nx], legend_age_layer[leg][ny][nx] , noise); 
          pix = (top_legend+ny+legend_positions[leg]-1)*width+1+nx;
          //offscreen.pixels[pix] = c;
          pixels[pix] = c;
        } 
      }
    } 
    
    //offscreen.
    updatePixels();  
    //offscreen.fill(255);
    fill(255);
    //offscreen.
    text((frame/10)+" "+":::"+startFrame+"->"+endFrame+","+remainder+" --- "+frameRate,10,20);
    //offscreen.endDraw();
    
    //println("Changed ",floor(100.0*changes/offscreen.pixels.length),"% pixels");
    //surface.render(offscreen);
    /*  // draw resized screen
    img = offscreen.get();
    img.resize(width,0);
    image(img,0,0);
    */
    for (int n=0; n<numParticles; n++) {
      particles[n].evolve();
      particles[n].display();
    }
    
}


void keyPressed() {
  switch(key) {
  case 'C':
    // enter/leave calibration mode, where surfaces can be warped 
    // and moved
    //ks.toggleCalibration();
    break;

  case 'l':
    // loads the saved layout
    //ks.load();
    break;

  case 's':
    // saves the layout
    //ks.save();
    break;

  case 'S':
    saveFrame("capture.png");
    break;
  case 'c':
    cPicker.change_current_scale(0);
    break;
  case 't':
    cPicker.change_current_scale(1);
    break;
  case 'i':
    cPicker.change_current_scale(2);
    break;

  case '1':
    cPicker.change_current_control_point(0);
    break;
  case '2':
    cPicker.change_current_control_point(1);
    break;
  case '3':
    cPicker.change_current_control_point(2);
    break;
  case '4':
    cPicker.change_current_control_point(3);
    break;
  case '5':
    cPicker.change_current_control_point(4);
    break;
  case '6':
    cPicker.change_current_control_point(5);
    break;
  case '7':
    cPicker.change_current_control_point(6);
    break;
  case '8':
    cPicker.change_current_control_point(7);
    break;
  case '9':
    cPicker.change_current_control_point(8);
    break;
  case '0':
    cPicker.change_current_control_point(9);
    break;

  case '+':
    cPicker.change_point_value(1);
    break;
  case '-':
    cPicker.change_point_value(-1);
    break;
    
  case 'p':
    cPicker.print_out();
    break;
  }
}


/*



*/


/*
void nada(){
    Location loc; Tram tram;
    // trams
    stroke(200);
    for (int n=0; n<trams.length; n++) {
       //trams[n].display();
    }
    noStroke();
    // particles
    for (int n=0;n<numParticles;n++){
      particles[n].evolve();
      if (particles[n].age<0) {
        tram = trams[loc_chooser.choose()];
        loc = loc_chooser.locate(tram);
//        particles[n] = new Particle(loc.x,loc.y,lerpColor(cFrom[loc.kind],cTo[loc.kind],tram.noise_levels[loc.kind]));
//        particles[n].setMaxRadius(int(tram.noise_levels[loc.kind] * particles[n].maxRadius));
    //particles[n] = new Particle(loc.x,loc.y,lerpColor(cFrom[loc.kind],cTo[loc.kind],1.0));
    particles[n].setMaxRadius(int(1.0 * maxRadius));

    }
    particles[n].display();
      
    }
    fill(0);
    text(frameRate,10,Ny-20);
}


 */
 
 
  /*
  bounds = new Bounds(6000, 20000, -5500, 3000);
  bounds.fixRatio(ratio);
  bounds.display();
  
  Reader reader = new Reader();
  tramCount = reader.prepare(bounds);
  trams = reader.read();  
  
  Location loc; Tram tram;
  particles = new Particle[numParticles];
  loc_chooser = new Location_Chooser(tramCount, layers.length);
  for (int n=0;n<numParticles;n++){
    tram = trams[loc_chooser.choose()];
    loc = loc_chooser.locate( tram );
    particles[n] = new Particle(loc.x,loc.y,lerpColor(cFrom[loc.kind],cTo[loc.kind],1.0));
    particles[n].setMaxRadius(int(1.0 * particles[n].maxRadius));
    particles[n].age = int(random(particles[n].maxAge));
  }
  */
  
  
//    for (int c=0;c<1;c++){
//      stroke(layerColors[c]);
//      for (int t=0;t<4;t++){
//        strokeWeight(t*0.5+0.5);
//        for (int n=0; n<trams.length; n++) {
//          if (trams[n].traffic_level == t){
//            trams[n].display();
//          }
//        }
//      }
//    }