String sketchApp = "E:/_DEV/_RnD/CommandLinesHelpers/cmdLineWithArguments";
String appPath = "/application.windows64";
String app = "cmdLineWithArguments";

ArrayList<CommandPrompt> cmdApplist;

void setup() {
  size(200, 200);

  cmdApplist = new ArrayList<CommandPrompt>();

  for (int i=0; i<5; i++) {
    CommandPrompt cmdapp = new CommandPrompt();
    String[] args = {
      Integer.toString((int)random(200, 400)), 
      Integer.toString((int)random(200, 400)), 
      "\"Hello World\""
    };
    cmdapp.launchApp(sketchApp+appPath, app, args);
    cmdApplist.add(cmdapp);
  }
}

void draw() { 
  background(0);
}

void mousePressed() {
}

void keyPressed() {
  switch(key) {
  case 'k' :
    for (CommandPrompt cmdapp : cmdApplist) {
      if (cmdapp.isAppLaunched(app)) cmdapp.killApp(app);
    }
    break;
  case 'r':
    for (CommandPrompt cmdapp : cmdApplist) {
      if (cmdapp.isAppLaunched(app)) cmdapp.killApp(app);
      String[] args = {
        Integer.toString((int)random(200, 400)), 
        Integer.toString((int)random(200, 400)), 
        "\"Hello World\""
      };

      cmdapp.launchApp(sketchApp+appPath, app, args);
    }
    break;
  }
}
