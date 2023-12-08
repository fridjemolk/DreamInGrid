void setupShaders() 
{
  GShader newShader;
  shaders = new ArrayList<GShader>();
  
  // drip 2
  newShader = new GShader("drip.glsl");
  newShader.addParameter("intense", 0, 1);
  newShader.addParameter("speed", 0, 1);
  newShader.addParameter("graininess", 0, 1, 0, 1);
  shaders.add(newShader);

  //monjori 3
  newShader = new GShader("monjori.glsl");
  newShader.addParameter("graininess", 0, 40);
  newShader.addParameter("pace", 0, 5);
  newShader.addParameter("twist", 0, 7);
  shaders.add(newShader);
  
   // bits 4
  newShader = new GShader("bits.glsl");
  newShader.addParameter("mx", 0, 1);
  newShader.addParameter("my", 0, 1);
  shaders.add(newShader);
  
  // rain 5
  newShader = new GShader("rain.glsl");
  newShader.addParameter("hue", 0, 0.1);
  newShader.addParameter("fade", 0, 1);
  newShader.addParameter("slow", 0.1, 3);
  newShader.addParameter("gray", 0, 1);
  shaders.add(newShader);
  
  // grain 5
  newShader = new GShader("noisy.glsl");
  //newShader.addParameter("resolution",1, 50, 1, 50);
  newShader.addParameter("noiseFactor", 1, 10,1,10);
  newShader.addParameter("noiseFactorTime", 0, 100);
  shaders.add(newShader);
  
  //limes 6
  newShader = new GShader("violetLimes.glsl");
  //newShader.addParameter("rings", 5, 40);
  //newShader.addParameter("complexity", 1, 60);
  shaders.add(newShader);
  
  //twist 7
  newShader = new GShader("Twist.glsl");
  shaders.add(newShader);
  
  //dip 8
  newShader = new GShader("dip.glsl");
  newShader.addParameter("extraTime", 1,1.25);
  newShader.addParameter("width",0.001, 0.009);
  shaders.add(newShader);
  
  //Yasmin's Torus Knot
  newShader = new GShader("yasmin_torusknots.glsl");
  newShader.addParameter("mouse", 0, width, height*0.4, height);
  shaders.add(newShader);
  
  //Yasmin's Butterfly
  newShader = new GShader("yasmin_butterfly.glsl");
  newShader.addParameter("mouse", 0, width, height*0.4, height);
  shaders.add(newShader);
  
  //Yasmin's Squid Thing
  newShader = new GShader("yasmin_squid.glsl");
  shaders.add(newShader);
  
  // blobby 1
  newShader = new GShader("blobby.glsl");
  newShader.addParameter("depth", 0, 2);
  newShader.addParameter("rate", 0, 2);
  shaders.add(newShader);
  
}


void setShader(int idxNextShader) {
  if (idxShader > -1)
    shader.removeGui();
  idxShader = idxNextShader;
  shader = shaders.get(idxShader); 
  shader.addGui();
}
