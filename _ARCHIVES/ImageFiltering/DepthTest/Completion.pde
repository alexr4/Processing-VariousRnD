void complete(int[] pix, int w, int h, int radius)
{
  int black = (255 << 24) | (0 << 16) | (0 << 8) | 0;
  int grey = (255 << 24) | (127 << 16) | (127 << 8) | 127;
  int white = (255 << 24) | (255 << 16) | (255 << 8) | 255;
  println(white, black);

  for (int i=0; i<pix.length; i++) {
    int x = i%w;
    int y = (i - x) / w;

    if (x > radius && x < w - radius - 1 && y > radius && y < h - radius - 1) {
      int topi = x + (y - radius) * w;
      int bottomi = x + (y + radius) * w;
      int lefti = (x - radius) + y * w;
      int righti = (x + radius) + y * w;

      int toplefti = (x-radius) + (y - radius) * w;
      int toprighti = (x+radius) + (y - radius) * w;
      int bottomlefti = (x - radius) + (y + radius) * w;
      int bottomrighti = (x + radius) + (y + radius) * w;

      int topc = (pix[topi] << 24) | (pix[topi] << 16) | (pix[topi] << 8) | pix[topi];
      int bottomc = (pix[bottomi] << 24) | (pix[bottomi] << 16) | (pix[bottomi] << 8) | pix[bottomi];
      int leftc = (pix[lefti] << 24) | (pix[lefti] << 16) | (pix[lefti] << 8) | pix[lefti];  
      int rightc = (pix[righti] << 24) | (pix[righti] << 16) | (pix[righti] << 8) | pix[righti];

      int topleftc = (pix[toplefti] << 24) | (pix[toplefti] << 16) | (pix[toplefti] << 8) | pix[toplefti];
      int toprightc = (pix[toprighti] << 24) | (pix[toprighti] << 16) | (pix[toprighti] << 8) | pix[toprighti];
      int bottomleftc = (pix[bottomlefti] << 24) | (pix[bottomlefti] << 16) | (pix[bottomlefti] << 8) | pix[bottomlefti];
      int bottomrightc = (pix[bottomrighti] << 24) | (pix[bottomrighti] << 16) | (pix[bottomrighti] << 8) | pix[bottomrighti];

      int average = topc + bottomc + leftc + rightc + topleftc + toprightc + bottomleftc + bottomrightc;
      average /= 8;

      //println(average);

      int col = (pix[i] << 24) | (pix[i] << 16) | (pix[i] << 8) | pix[i];
      //println(col);
      if (col != black) {
        pix[i] = (255 << 24) | (255 << 16) | (0 << 8) | 0;
      }
    }
  }
}


int[] getComplete(int[] pix, int w, int h, int radius)
{
  int[] npix = new int[pix.length];

  int black = (255 << 24) | (0 << 16) | (0 << 8) | 0;
  int grey = (255 << 24) | (127 << 16) | (127 << 8) | 127;
  int white = (255 << 24) | (255 << 16) | (255 << 8) | 255;


  for (int i=0; i<pix.length; i++) {
    int x = i%w;
    int y = (i - x) / w;
    int col = (pix[i] << 24) | (pix[i] << 16) | (pix[i] << 8) | pix[i];
    if (col != black) { 
      for (int j=0; j<radius; j++) {
        float nj = (float) j / (float)radius;
        if (x > radius && x < w - radius - 1 && y > radius && y < h - radius - 1) {
          int topi = x + (y - int(radius * nj)) * w;
          int bottomi = x + (y + int(radius * nj)) * w;
          int lefti = (x - int(radius * nj)) + y * w;
          int righti = (x + int(radius * nj)) + y * w;

          int toplefti = (x-int(radius * nj)) + (y - int(radius * nj)) * w;
          int toprighti = (x+int(radius * nj)) + (y - int(radius * nj)) * w;
          int bottomlefti = (x - int(radius * nj)) + (y + int(radius * nj)) * w;
          int bottomrighti = (x + int(radius * nj)) + (y + int(radius * nj)) * w;


          npix[topi] = white;
          npix[bottomi] = white;
          npix[lefti] = white;
          npix[righti] = white;
          npix[toplefti] = white;
          npix[toprighti] = white;
          npix[bottomlefti] = white;
          npix[bottomrighti] = white;
          npix[i] = white;
        }
      }
    }
  }

  return npix;
}


int[] getErode(int[] pix, int w, int h, int radius)
{
  int[] npix = new int[pix.length];

  int black = (255 << 24) | (0 << 16) | (0 << 8) | 0;
  int grey = (255 << 24) | (127 << 16) | (127 << 8) | 127;
  int white = (255 << 24) | (255 << 16) | (255 << 8) | 255;


  for (int i=0; i<pix.length; i++) {
    int x = i%w;
    int y = (i - x) / w;
    int col = (pix[i] << 24) | (pix[i] << 16) | (pix[i] << 8) | pix[i];
    if (col == black) { 
      for (int j=0; j<radius; j++) {
        float nj = (float) j / (float)radius;
        if (x > radius && x < w - radius - 1 && y > radius && y < h - radius - 1) {
          int topi = x + (y - int(radius * nj)) * w;
          int bottomi = x + (y + int(radius * nj)) * w;
          int lefti = (x - int(radius * nj)) + y * w;
          int righti = (x + int(radius * nj)) + y * w;

          int toplefti = (x-int(radius * nj)) + (y - int(radius * nj)) * w;
          int toprighti = (x+int(radius * nj)) + (y - int(radius * nj)) * w;
          int bottomlefti = (x - int(radius * nj)) + (y + int(radius * nj)) * w;
          int bottomrighti = (x + int(radius * nj)) + (y + int(radius * nj)) * w;


          npix[topi] = black;
          npix[bottomi] = black;
          npix[lefti] = black;
          npix[righti] = black;
          npix[toplefti] = black;
          npix[toprighti] = black;
          npix[bottomlefti] = black;
          npix[bottomrighti] = black;
          npix[i] = black;
        }
      }
    }
  }

  return npix;
}
