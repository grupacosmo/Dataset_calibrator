import java.io.File;

final static String ORGINAL_DATASET_PATH = "C:/Users/Pixedar/AppData/Local/Programs/Python/Python37/Lib/site-packages/axelerate/widsdatathon2019/tmp";
final static String MODYFIED_DATASET_PATH = "modified_sat/";
final static String CAMERA_IMGS_PATH = "camImgs/";
//settings for maixpy camera
final float[] saturationRange = {0,7};
final float[] hueRange = {-2,2};
final float[] brightnessnRange = {-20,20};
final boolean resize = false;
final boolean addInvalidData  = false;
final boolean drawBorders = false;
final color borderColor = color(250,0,250);
void setup() {
  colorMode(HSB, 255, 255, 255);

  File dir = new File(ORGINAL_DATASET_PATH);
  File[] files = dir.listFiles();

  for (int i=0; i < files.length; i++ ) { 
    String path = files[i].getAbsolutePath();
    if (!path.toLowerCase().endsWith(".jpg")  ) {
      continue;
    }
    PImage image = loadImage(path);
    modifyImg(image, 100);
    image.save(MODYFIED_DATASET_PATH+ path.substring(path.lastIndexOf("\\")+1));
  }
  exit();
}


void modifyImg(PImage img, int probability) {
  if (random(100) > probability) {
    return;
  }
  if(resize){
  float w = random(0.8, 1.3)*img.width;
  float h = random(0.9, 1.2)*img.height;
  img.resize(round(w),round(h));
  }

  int sat = round(random(saturationRange[0], saturationRange[1]));
  int hue = round(random(hueRange[0],hueRange[1]));
  int brigh = round(random(brightnessnRange[0],brightnessnRange[1]));

  if(random(100) < 5&& addInvalidData){
    sat = round(sat*random(5,15));
    hue= round(hue*random(5.5,15));
    brigh= round(brigh*random(5,15));
  }
  int y_r =0;
  int x_r1 =0;
  int x_r2= 0;
  if(drawBorders){
    y_r = round(random(0, 0.05*img.height));
    x_r1 = round(random(0, 0.16*img.height));
    x_r2 = round(random(0, 0.16*img.height));
  }
  if (random(100) < 70) {
    img.filter(BLUR, round(random(1, 2.1)));
  }

  float br = 0;
  float hu = 0;
  float sa = 0;
  for (int y = 0; y < img.height; y++) {
    for (int x = 0; x < img.width; x++) {
      br+=random(-0.055, 0.055);
      hu+=random(-0.015, 0.015);
      sa+=random(-0.04, 0.04);
      color c = img.get(x, y);
      color c2;
     if((y < y_r || y > img.height - y_r || x < x_r1 || x > img.width - x_r2)&&drawBorders){
          c2 = color(red(borderColor)+br,green(borderColor)+sa,blue(borderColor)+br);
     }else{
      c2 = color(hue(c)+ hue+hu, saturation(c)-sat+sa, brightness(c)+brigh+br);
      }
      img.set(x, y, c2);
    }
  }
}

//used for oil palms only
void splitImgs() {
  Table table = loadTable("solutionFile.csv", "header");

  println(table.getRowCount() + " total rows in table");
  for (TableRow row : table.rows()) {
    String imgP = row.getString("image_id").replace("2018", "").replace("2017", "");
    //imgP  = imgP .substring(0, 8) + imgP.substring(12);
    int valid = row.getInt("has_oilpalm");
    float score =row.getFloat("score"); 
    PImage img = loadImage("train_images/"+imgP);
    if (score < 0.7) {
      continue;
    }
    if (valid == 1) {
      img.save("train/valid/"+imgP);
    } else if (valid ==0) {
      img.save("train/invalid/"+imgP);
    }
  }
}
