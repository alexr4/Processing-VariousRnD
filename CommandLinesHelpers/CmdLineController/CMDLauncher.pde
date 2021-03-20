import java.io.BufferedReader;
import java.io.InputStreamReader;

public class CommandPrompt {

  CommandPrompt() {
  }

  public void killApp(String appName) {
    try {
      Runtime.getRuntime().exec("taskkill /f /fi \"WINDOWTITLE eq "+appName+"\"");
    }
    catch(Exception e) {
      e.printStackTrace();
    }
  }

  public void launchApp(String path, String appName) {
    launchApp(path, appName, null);
  }

  public void launchApp(String path, String appName, String[] args) {
    try {
      String cmd = "cmd.exe /c start /d \""+path+"\" "+appName+".exe";
      if (args != null) {
        for (String s : args) {
          cmd += " "+s;
        }
      }
      Process p = Runtime.getRuntime().exec(cmd);
      p.waitFor();
    }
    catch (IOException e) {
      e.printStackTrace();
    } 
    catch(Exception e) {
      e.printStackTrace();
    }
  }

  public void runSketch(String path, String[] args) {
    cmdSketch(path, "--run", args);
  }

  public void cmdSketch(String path, String action, String[] args) {
    try {
      String cmd = "processing-java --sketch="+path+" "+action;
      if (args != null) {
        for (String s : args) {
          cmd += " "+s;
        }
      }
      println(cmd);
      Process p = Runtime.getRuntime().exec(cmd);
      p.waitFor();
    }
    catch (IOException e) {
      e.printStackTrace();
    } 
    catch(Exception e) {
      e.printStackTrace();
    }
  }

  ///// CMD HELPER
  public boolean isAppLaunched(String appName) {
    if (getProcess(appName).size() > 0 ) {
      return true;
    } else {
      return false;
    }
  }

  public ArrayList<String> getProcessList() {
    ArrayList<String> ProcessList = new ArrayList<String>();
    try {
      String process;
      Process p = Runtime.getRuntime().exec("tasklist /FO TABLE /NH  /FI \"STATUS eq running\"");
      BufferedReader input = new BufferedReader(new InputStreamReader(p.getInputStream()));
      while ((process = input.readLine()) != null) {
        // println(process);
        ProcessList.add(process);
      }
      input.close();
    } 
    catch (Exception err) {
      err.printStackTrace();
    }
    return ProcessList;
  }

  public ArrayList<String> getProcess(String s) {
    ArrayList<String> ProcessList = new ArrayList<String>();
    try {
      String process;
      Process p = Runtime.getRuntime().exec("tasklist /fi \"windowtitle eq "+s+"\" /FO TABLE /NH");
      BufferedReader input = new BufferedReader(new InputStreamReader(p.getInputStream()));
      while ((process = input.readLine()) != null) {
        String[] appSplit = splitTokens(process, ".");
        if (appSplit.length == 2) {
          ProcessList.add(appSplit[0]);
        }
      }
      input.close();
    } 
    catch (Exception err) {
      err.printStackTrace();
    }
    return ProcessList;
  }

  public ArrayList<String> getAllAppNames() {
    ArrayList<String> ProcessList = getProcessList();
    return getAllAppNames(ProcessList);
  }

  public ArrayList<String> getAllAppNames(ArrayList<String> ProcessList) {
    ArrayList<String> appList = new ArrayList<String>();
    for (String s : ProcessList) {
      String[] appSplit = splitTokens(s, ".");
      if (appSplit.length == 2) {
        appList.add(appSplit[0]);
      }
    }
    return appList;
  }

  public String createCmdPath(String path) {
    String[] pathList = split(path, "/");
    String finalPath = "";
    for (String s : pathList) {
      finalPath += s+"\\";
    }

    return finalPath;
  }
}
