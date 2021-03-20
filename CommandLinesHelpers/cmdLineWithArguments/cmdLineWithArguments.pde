//command to launch processing-java --sketch=E:/_DEV/_RnD/CommandLinesHelpers/cmdLineWithArguments --run argu "arg o"
String text = "";

void settings() {
  if (args != null) {
    println(args.length);
    for (int i = 0; i < args.length; i++) {
      println(i, args[i]);
    }
    int swidth  = Integer.parseInt(args[0]);
    int sheight = Integer.parseInt(args[1]);
    size(swidth, sheight, P2D);
    
    text = args[2];
  } else {
    println("args == null");
  }
}

void draw(){
  background(127);
  text(text, 20, 20);
}
