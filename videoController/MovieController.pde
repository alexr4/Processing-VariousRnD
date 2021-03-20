import processing.video.*;
import java.util.*;
import java.awt.Image;

class MovieController extends Movie implements MovieRoute {
  PGraphics buffer;
  PImage tmpBuffer;
  boolean finished = false;
  int route = MovieRoute.IDLE;
  private List<MovieEvent> listener = new ArrayList<MovieEvent>();

  MovieController(PApplet context, String file) {
    super(context, file);
    this.initBuffer(context.width, context.height);
  }

  MovieController(PApplet context, String file, int bwidth, int bheight) {
    super(context, file);
    this.initBuffer(bwidth, bheight);
  }

  private void initBuffer(int bwidth, int bheight) {
    this.buffer = this.parent.createGraphics(bwidth, bheight);
    this.buffer.beginDraw();
    this.buffer.background(0);
    this.buffer.endDraw();
  }

  public void addListener(MovieEvent event) {
    listener.add(event);
  }


  @Override void play() {
    super.play();
    finished = false;
    setRoute(MovieRoute.PLAY);
  }

  void replay() {
    super.stop();
    super.play();
    finished = false;
    setRoute(MovieRoute.PLAY);
  }

  @Override void pause() {
    super.pause();
    setRoute(MovieRoute.PAUSE);
  }

  @Override void stop() {
    super.stop();
    setRoute(MovieRoute.STOP);
  }

  public void run() {
    if (this.available()) {
      this.read();
    }

    if (!this.repeat && !this.playing && !this.paused &&  !this.finished) {
      setRoute(MovieRoute.STOP);
    }
  }

  /**
   this methods is used to get a snapshot of a frame
   */
  public void computeSnapshot() {
    if (this.newFrame) {
      tmpBuffer = new PImage((Image) this.getNative());
      this.buffer.beginDraw();
      this.buffer.image(tmpBuffer, 0, 0, this.buffer.width, this.buffer.height);
      this.buffer.endDraw();
    }
  }

  /**
   this methods check the chage of Route
   */
  private void setRoute(int route) {
    this.route = route;
    checkRoute();
  }

  private void checkRoute() {
    switch(route) {
    default:
    case MovieRoute.IDLE :
      break;
    case MovieRoute.PLAY :
      println("Play has been triggered");
      for (MovieEvent l : listener) {
        l.playEvent();
      }
      setRoute(MovieRoute.IDLE);
      break;
    case MovieRoute.PAUSE :
      println("Pause has been triggered");
      for (MovieEvent l : listener) {
        l.pauseEvent();
      }
      setRoute(MovieRoute.IDLE);
      break;
    case MovieRoute.STOP :
      println("Stop has been triggered");
      this.finished = true;
      for (MovieEvent l : listener) {
        l.stopEvent();
      }
      setRoute(MovieRoute.IDLE);
      break;
    }
  }

  public PGraphics getBuffer() {
    return this.buffer;
  }
}


private interface MovieRoute {
  public int IDLE   = 0;
  public int PLAY   = 1;
  public int PAUSE  = 2;
  public int STOP   = 3;
}

public interface MovieEvent {
  void playEvent();
  void pauseEvent();
  void stopEvent();
}
