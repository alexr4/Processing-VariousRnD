import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import org.ejml.*; 

import org.ejml.dense.row.*; 
import org.ejml.dense.row.misc.*; 
import org.ejml.dense.row.linsol.*; 
import org.ejml.dense.row.linsol.qr.*; 
import org.ejml.dense.row.linsol.chol.*; 
import org.ejml.dense.row.linsol.lu.*; 
import org.ejml.dense.row.decompose.*; 
import org.ejml.dense.row.decompose.qr.*; 
import org.ejml.dense.row.decompose.hessenberg.*; 
import org.ejml.dense.row.decompose.chol.*; 
import org.ejml.dense.row.decompose.lu.*; 
import org.ejml.dense.row.mult.*; 
import org.ejml.dense.row.factory.*; 
import org.ejml.*; 
import org.ejml.interfaces.decomposition.*; 
import org.ejml.interfaces.linsol.*; 
import org.ejml.ops.*; 
import org.ejml.data.*; 
import org.ejml.dense.fixed.*; 
import org.ejml.dense.row.decomposition.qr.*; 
import org.ejml.dense.row.decomposition.*; 
import org.ejml.dense.row.decomposition.hessenberg.*; 
import org.ejml.dense.row.decomposition.chol.*; 
import org.ejml.dense.row.decomposition.svd.*; 
import org.ejml.dense.row.decomposition.svd.implicitqr.*; 
import org.ejml.dense.row.decomposition.eig.symm.*; 
import org.ejml.dense.row.decomposition.eig.*; 
import org.ejml.dense.row.decomposition.eig.watched.*; 
import org.ejml.dense.row.decomposition.lu.*; 
import org.ejml.dense.row.decomposition.bidiagonal.*; 
import org.ejml.dense.row.linsol.svd.*; 
import org.ejml.dense.block.decomposition.qr.*; 
import org.ejml.dense.block.decomposition.hessenberg.*; 
import org.ejml.dense.block.decomposition.chol.*; 
import org.ejml.dense.block.decomposition.bidiagonal.*; 
import org.ejml.dense.block.linsol.qr.*; 
import org.ejml.dense.block.linsol.chol.*; 
import org.ejml.dense.block.*; 
import org.ejml.generic.*; 
import org.ejml.sparse.*; 
import org.ejml.sparse.csc.*; 
import org.ejml.sparse.csc.decomposition.qr.*; 
import org.ejml.sparse.csc.decomposition.chol.*; 
import org.ejml.sparse.csc.decomposition.lu.*; 
import org.ejml.sparse.csc.misc.*; 
import org.ejml.sparse.csc.linsol.qr.*; 
import org.ejml.sparse.csc.linsol.chol.*; 
import org.ejml.sparse.csc.linsol.lu.*; 
import org.ejml.sparse.csc.mult.*; 
import org.ejml.sparse.csc.factory.*; 
import org.ejml.sparse.triplet.*; 
import org.ejml.dense.densed2.mult.*; 
import org.ejml.dense.blockd3.*; 
import org.ejml.interfaces.*; 
import org.ejml.equation.*; 
import org.ejml.simple.*; 
import org.ejml.simple.ops.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class MathsClass extends PApplet {

ArrayList<PVector> vertList;

ArrayList<PVector> randSample;


public void setup() {
  

  vertList = new ArrayList<PVector>();
  int nbVert = 20;
  for (int i=0; i<nbVert; i++) {
    float a = norm(i, 0, nbVert) * TWO_PI;
    float r = random(20, 100);
    float x = width/2 + cos(a) * r;
    float y = height/2 + sin(a) * r;
    vertList.add(new PVector(x, y));
  }

  randSample = new ArrayList<PVector>();
  int nbSample = 200;
  for (int i=0; i<nbSample; i++) {
    float a = norm(i, 0, nbSample) * TWO_PI;
    float r = random(0, 40);
    float x = width/2 + cos(a) * r;
    float y = height/2 + sin(a) * r;
    randSample.add(new PVector(x, y));
  }
}

public void draw() {
  background(20);
/*
  float alpha = 0;
  PVector loc = new PVector(mouseX, mouseY);
  if(Maths.isInsidePoly(loc, vertList)){
    alpha = 255;
  }*/

  float ratio = Maths.getInsidePolyRatio(randSample, vertList);
  
  noStroke();
  fill(255);
  text("Inside polygon ratio = "+ratio, 20, 20);

  boolean allPointsInsidePoly = Maths.isInsidePoly(randSample, vertList);
  println(allPointsInsidePoly);

  noStroke();
  for(PVector v : randSample){
    if(Maths.isInsidePoly(v, vertList)){
      fill(0, 255, 0);
    }else{
      fill(0, 0, 255);
    }
    ellipse(v.x, v.y , 2, 2);
  }

  //fill(255, 0, 0, alpha);
  noFill();
  stroke(255, 0, 0);
  beginShape();
  for (PVector v : vertList) {
    vertex(v.x, v.y);
  }
  endShape(CLOSE);

 /* if(Maths.isInsidePoly(loc, vertList)) println("isInsidePoly");*/
}

/**
 * TO DO :
 * \u2192 Split Math class into differets type such as :
 * \u2192 \u2192 Maths.Easing
 * \u2192 \u2192 Maths.Geom.Triangle
 * \u2192 \u2192 Maths.Vector
 * \u2192 \u2192 Maths.Matrix
 * \u2192 \u2192 Maths.Array
 * \u2192 \u2192 ...
 */


//import org.ejml.simple.SimpleMatrix;

static class Maths {
  /**
   * LAPLACIAN HELPERS
   * The following methods will provide various snippet in order to smooth a 2D array of Vector using laplacian or centroid
   */
  private static int minDist = 100; //static vlaue for smoothing
  public static PVector[][] laplacianList;
  public static PVector[][] centroidList;

  //2D grid smoothing methods
  //Recursive methods
  static public void computeLaplacianIteration(PVector[][] raw, int loop)
  {
    if (loop < 1)
    {
    } else
    {
      laplacianList = getLaplacianSmooth(raw);
      loop --;
      computeLaplacianIteration(laplacianList, loop);
    }
  }

  static public void computeCentroidIteration(PVector[][] raw, int loop)
  {
    if (loop < 1)
    {
    } else
    {   
      centroidList = getCentroidSmooth(raw);
      loop --;
      computeCentroidIteration(centroidList, loop);
    }
  }

  //Smooth 2D array of Vector using laplace method
  static public PVector[][] getLaplacianSmooth(PVector[][] raw)
  {
    PVector[][] laplacianList = new PVector[raw.length][raw[0].length];

    for (int i=0; i<raw.length; i++)
    {
      for (int j=0; j<raw[0].length; j++)
      {
        if (i > 0 && i < raw.length-1 && j > 0 && j < raw[0].length-1)
        {
          PVector origin = raw[i][j].copy();
          PVector v0 = raw[i-1][j].copy();
          PVector v1 = raw[i+1][j].copy();
          PVector v2 = raw[i][j-1].copy();
          PVector v3 = raw[i][j+1].copy();

          //count null vertex        
          //Compute le sum of neighbores vertex
          PVector sum = origin.copy();
          int divider = 1;

          if (PVector.dist(origin, v0) < minDist) 
          {
            divider++;
            sum.add(v0);
          }
          if (PVector.dist(origin, v1) < minDist) {
            divider++;
            sum.add(v1);
          }
          if (PVector.dist(origin, v2) < minDist) {
            divider++;
            sum.add(v2);
          }
          if (PVector.dist(origin, v3) < minDist)
          {
            divider++;
            sum.add(v3);
          }


          //divide by numbers of neighbores
          sum.div(divider);

          laplacianList[i][j] = sum.copy();
        } else
        {
          //edges
          if (i > 0 && i<raw.length-1 && j == 0) //top
          {
            PVector origin = raw[i][j].copy();
            PVector v0 = raw[i-1][j].copy();
            PVector v1 = raw[i+1][j].copy();
            PVector v2 = raw[i][j+1].copy();

            //Compute le sum of neighbores vertex
            PVector sum = origin.copy().add(v0).add(v1).add(v2);

            //divide by numbers of neighbores
            sum.div(4);

            laplacianList[i][j] = sum.copy();
          } else if (i > 0 && i<raw.length-1 && j < raw[0].length) //bottom
          {
            PVector origin = raw[i][j].copy();
            PVector v0 = raw[i-1][j].copy();
            PVector v1 = raw[i+1][j].copy();
            PVector v2 = raw[i][j-1].copy();

            //Compute le sum of neighbores vertex
            PVector sum = origin.copy().add(v0).add(v1).add(v2);

            //divide by numbers of neighbores
            sum.div(4);

            laplacianList[i][j] = sum.copy();
          } else if (j > 0 && j<raw[0].length-1 && i == 0) //left
          {
            PVector origin = raw[i][j].copy();
            PVector v0 = raw[i][j+1].copy();
            PVector v1 = raw[i+1][j].copy();
            PVector v2 = raw[i][j-1].copy();

            //Compute le sum of neighbores vertex
            PVector sum = origin.copy().add(v0).add(v1).add(v2);

            //divide by numbers of neighbores
            sum.div(4);

            laplacianList[i][j] = sum.copy();
          } else if (j > 0 && j<raw[0].length-1 && i < raw.length) //right
          {
            PVector origin = raw[i][j].copy();
            PVector v0 = raw[i][j+1].copy();
            PVector v1 = raw[i-1][j].copy();
            PVector v2 = raw[i][j-1].copy();

            //Compute le sum of neighbores vertex
            PVector sum = origin.copy().add(v0).add(v1).add(v2);

            //divide by numbers of neighbores
            sum.div(4);

            laplacianList[i][j] = sum.copy();
          }
          //corners
          else if (i == 0 && j==0) //TOP LEFT
          {
            PVector origin = raw[i][j].copy();
            PVector v0 = raw[i+1][j].copy();
            PVector v1 = raw[i][j+1].copy();

            //Compute le sum of neighbores vertex
            PVector sum = origin.copy().add(v0).add(v1);

            //divide by numbers of neighbores
            sum.div(3);

            laplacianList[i][j] = sum.copy();
          } else if (i == 0 && j== raw[0].length-1) //BOTTOM LEFT
          {
            PVector origin = raw[i][j].copy();
            PVector v0 = raw[i+1][j].copy();
            PVector v1 = raw[i][j-1].copy();

            //Compute le sum of neighbores vertex
            PVector sum = origin.copy().add(v0).add(v1);

            //divide by numbers of neighbores
            sum.div(3);

            laplacianList[i][j] = sum.copy();
          } else if (i == raw.length-1 && j== 0) //TOP RIGHT
          {
            PVector origin = raw[i][j].copy();
            PVector v0 = raw[i-1][j].copy();
            PVector v1 = raw[i][j+1].copy();

            //Compute le sum of neighbores vertex
            PVector sum = origin.copy().add(v0).add(v1);

            //divide by numbers of neighbores
            sum.div(3);

            laplacianList[i][j] = sum.copy();
          } else if (i == raw.length-1 && j == raw[0].length-1) //BOTTOM RIGHT
          {
            PVector origin = raw[i][j].copy();
            PVector v0 = raw[i-1][j].copy();
            PVector v1 = raw[i][j-1].copy();

            //Compute le sum of neighbores vertex
            PVector sum = origin.copy().add(v0).add(v1);

            //divide by numbers of neighbores
            sum.div(3);

            laplacianList[i][j] = sum.copy();
          } else
          {
            laplacianList[i][j] = raw[i][j].copy();
          }
        }
      }
    }
    return laplacianList;
  }

  //Smooth 2D array of Vector using centroid method
  static public PVector[][] getCentroidSmooth(PVector[][] raw)
  {
    PVector[][] centroidList = new PVector[raw.length][raw[0].length];


    for (int i=0; i<raw.length; i++)
    { 
      for (int j=0; j<raw[0].length; j++)
      {
        if (i > 0 && i < raw.length-1 && j > 0 && j < raw[0].length-1)
        {
          PVector origin = raw[i][j].copy();

          PVector v0 = raw[i-1][j].copy();
          PVector v1 = raw[i+1][j].copy();
          PVector v2 = raw[i][j-1].copy();
          PVector v3 = raw[i][j+1].copy();

          PVector c0 = origin.copy();//.add(v0).add(v2);
          PVector c1 = origin.copy();//.add(v1).add(v2);
          PVector c2 = origin.copy();//.add(v1).add(v3);
          PVector c3 = origin.copy();//.add(v0).add(v3);
          /* c0.div(3);
           c1.div(3);
           c2.div(3);
           c3.div(3);
           
           PVector sum = c0.copy().add(c1).add(c2).add(c3);
           sum.div(4);*/


          PVector sum = new PVector();
          int divider = 0;

          if (PVector.dist(origin, v0) < minDist*2 && PVector.dist(origin, v2) < minDist*2) 
          {
            divider++;
            c0.add(v0).add(v2);
            c0.div(3);
            sum.add(c0);
          }
          if (PVector.dist(origin, v1) < minDist*2 && PVector.dist(origin, v2) < minDist*2) {
            divider++;
            c1.add(v1).add(v2);
            c1.div(3);
            sum.add(c1);
          }
          if (PVector.dist(origin, v1) < minDist*2 && PVector.dist(origin, v3) < minDist*2) {
            divider++;
            c2.add(v1).add(v3);
            c2.div(3);
            sum.add(c2);
          }
          if (PVector.dist(origin, v0) < minDist*2 && PVector.dist(origin, v3) < minDist*2)
          {
            divider++;
            c3.add(v0).add(v3);
            c3.div(3);
            sum.add(c3);
          }

          //divide by numbers of neighbores
          sum.div(divider);

          centroidList[i][j] = sum;
        } else
        {
          if (i > 0 && i<raw.length-1 && j == 0) //top
          {
            PVector origin = raw[i][j].copy();

            PVector v0 = raw[i-1][j].copy();
            PVector v1 = raw[i+1][j].copy();
            PVector v2 = raw[i][j+1].copy();

            PVector c0 = origin.copy().add(v0).add(v2);
            c0.div(3);
            PVector c1 = origin.copy().add(v1).add(v2);
            c1.div(3);


            //Compute le sum of neighbores vertex
            PVector sum = c0.copy().add(c1);

            //divide by numbers of neighbores
            sum.div(2);

            centroidList[i][j] = sum.copy();
          } else if (i > 0 && i<raw.length-1 && j < raw[0].length) //bottom
          {
            PVector origin = raw[i][j].copy();

            PVector v0 = raw[i-1][j].copy();
            PVector v1 = raw[i+1][j].copy();
            PVector v2 = raw[i][j-1].copy();

            PVector c0 = origin.copy().add(v0).add(v2);
            c0.div(3);
            PVector c1 = origin.copy().add(v1).add(v2);
            c1.div(3);


            //Compute le sum of neighbores vertex
            PVector sum = c0.copy().add(c1);

            //divide by numbers of neighbores
            sum.div(2);

            centroidList[i][j] = sum.copy();
          } else if (j > 0 && j<raw[0].length-1 && i == 0) //left
          {
            PVector origin = raw[i][j].copy();

            PVector v0 = raw[i][j+1].copy();
            PVector v1 = raw[i+1][j].copy();
            PVector v2 = raw[i][j-1].copy();

            PVector c0 = origin.copy().add(v0).add(v2);
            c0.div(3);
            PVector c1 = origin.copy().add(v1).add(v2);
            c1.div(3);


            //Compute le sum of neighbores vertex
            PVector sum = c0.copy().add(c1);

            //divide by numbers of neighbores
            sum.div(2);

            centroidList[i][j] = sum.copy();
          } else if (j > 0 && j<raw[0].length-1 && i < raw.length) //right
          {
            PVector origin = raw[i][j].copy();

            PVector v0 = raw[i][j+1].copy();
            PVector v1 = raw[i-1][j].copy();
            PVector v2 = raw[i][j-1].copy();

            PVector c0 = origin.copy().add(v0).add(v2);
            c0.div(3);
            PVector c1 = origin.copy().add(v1).add(v2);
            c1.div(3);


            //Compute le sum of neighbores vertex
            PVector sum = c0.copy().add(c1);

            //divide by numbers of neighbores
            sum.div(2);

            centroidList[i][j] = sum.copy();
          }
          //corners
          else if (i == 0 && j==0) //TOP LEFT
          {
            PVector origin = raw[i][j].copy();

            PVector v0 = raw[i+1][j].copy();
            PVector v1 = raw[i][j].copy();

            PVector c0 = origin.copy().add(v0).add(v1);
            c0.div(3);

            centroidList[i][j] = c0.copy();
          } else if (i == 0 && j== raw[0].length-1) //BOTTOM LEFT
          {
            PVector origin = raw[i][j].copy();

            PVector v0 = raw[i+1][j].copy();
            PVector v1 = raw[i][j-1].copy();

            PVector c0 = origin.copy().add(v0).add(v1);
            c0.div(3);

            centroidList[i][j] = c0.copy();
          } else if (i == raw.length-1 && j== 0) //TOP RIGHT
          {
            PVector origin = raw[i][j].copy();

            PVector v0 = raw[i-1][j].copy();
            PVector v1 = raw[i][j+1].copy();

            PVector c0 = origin.copy().add(v0).add(v1);
            c0.div(3);

            centroidList[i][j] = c0.copy();
          } else if (i == raw.length-1 && j == raw[0].length-1) //BOTTOM RIGHT
          {
            PVector origin = raw[i][j].copy();

            PVector v0 = raw[i-1][j].copy();
            PVector v1 = raw[i][j-1].copy();

            PVector c0 = origin.copy().add(v0).add(v1);
            c0.div(3);

            centroidList[i][j] = c0.copy();
          } else
          {
            centroidList[i][j] = raw[i][j].copy();
          }
        }
      }
    }
    return centroidList;
  }


  /**
   * Matrix
   * The following methods willprovide various helper for matrix computation such as SVD, Inverse, Finding RT matrix...
   * It use EJML library
   */
  
  //find Rotation and Translation matrix between two identical dataset in a 3D Space
  //from : http://nghiaho.com/?page_id=671
  public static PMatrix3D[] findRotationTranslationMatrices(ArrayList<PVector> dataA, ArrayList<PVector> dataB) {
    //get the centroid of each data set
    PVector centroidA = getCentroid(dataA);
    PVector centroidB = getCentroid(dataB);

    subCentroid(dataA, centroidA);
    subCentroid(dataB, centroidB);

    //H = MatA(transposed) * MatB
    SimpleMatrix matAT = getMatrix(dataA).transpose();
    SimpleMatrix matB = getMatrix(dataB);
    SimpleMatrix H = matAT.mult(matB);

    //get the SVD of H
    SimpleSVD SVD = H.svd();

    SimpleMatrix V = (SimpleMatrix)SVD.getV();
    SimpleMatrix UT = (SimpleMatrix)SVD.getU().transpose();

    //Find the Rotation Matrix
    SimpleMatrix R = V.mult(UT);

    //check if SVD has returned a reflection matrix
    if (R.determinant() < 0) {
      double c30 = V.get(2) * -1;
      double c31 = V.get(5) * -1;
      double c32 = V.get(8) * -1;
      V.set(2, c30);
      V.set(5, c31);
      V.set(8, c32);
      R = V.mult(UT);
    }

    //convert the SimpleMatrix (3*3) into a PMartix3D (4*4)
    PMatrix3D P5R = new PMatrix3D(
      (float) R.get(0), (float) R.get(1), (float) R.get(2), 0, 
      (float) R.get(3), (float) R.get(4), (float) R.get(5), 0, 
      (float) R.get(6), (float) R.get(7), (float) R.get(8), 0, 
      0, 0, 0, 0
      );

    //Find the Translation Matrix given by T = -R * centroidA(t) + centroidB(t)
    //convert centroid into an EJML matrix for finding translation matrix
    SimpleMatrix cAT = getMatrix(centroidA).transpose();
    SimpleMatrix cBT = getMatrix(centroidB).transpose();
    SimpleMatrix T = (R.negative().mult(cAT)).plus(cBT);
    //R.print();
    //T.print();

    //Convert SimpleMatrix (3*3) into a PMatrix3D (4*4)
    PMatrix3D P5T = new PMatrix3D(
      1, 0, 0, (float) T.get(0), 
      0, 1, 0, (float) T.get(1), 
      0, 0, 1, (float) T.get(2), 
      0, 0, 0, 1
      );

    PMatrix3D[] matrices = {P5R, P5T};

    return matrices;
  }

   //Transform <List> of Point by a given Rotation and translation Matrix
  public static void transformAndRotatePoints(ArrayList<PVector> src, PMatrix3D R, PMatrix3D T) {
    for (int i=0; i<src.size(); i++) {
      PVector v = src.get(i);
      PVector nv = new PVector();

      R.mult(v, nv);
      nv.x += T.m03;
      nv.y += T.m13;
      nv.z += T.m23;
      src.set(i, nv);
    }
  }

  //Transform 2DList[][] of Point by a given Rotation and translation Matrix
  public static void transformAndRotatePoints(PVector[][] src, PMatrix3D R, PMatrix3D T) {
    for (int i=0; i<src.length; i++) {
      for (int j=0; j<src[0].length; j++) {
        if (src[i][j] != null) {
          PVector v = src[i][j].copy();
          PVector nv = new PVector();
          R.mult(v, nv);
          nv.x += T.m03;
          nv.y += T.m13;
          nv.z += T.m23;
          src[i][j] = nv;
        }
      }
    }
  }

   //Transform a Point by a given Rotation and translation Matrix
  public static PVector transformAndRotatePoints(PVector src, PMatrix3D R, PMatrix3D T) {
    PVector v =  src.copy();
    PVector nv = new PVector();
    R.mult(v, nv);
    nv.x += T.m03;
    nv.y += T.m13;
    nv.z += T.m23;
    return nv;
  }

  //animated transformation with a normalized time nt
  public static ArrayList<PVector> animateTransformAndRotatePoints(ArrayList<PVector> src, PMatrix3D R, PMatrix3D T, float nt) {
    ArrayList<PVector> apc = new ArrayList<PVector>();
    PMatrix3D identity = new PMatrix3D(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1);
    float ntR = map(nt, 0, 0.5f, 0.0f, 1.0f);
    float ntT = map(nt, 0.5f, 1.0f, 0.0f, 1.0f);
    ntR = constrain(ntR, 0.0f, 1.0f);
    PMatrix3D R_ = lerpMatrix(identity, R, ntR);
    PMatrix3D T_ = lerpMatrix(identity, T, ntT);


    for (int i=0; i<src.size(); i++) {
      PVector v = src.get(i);
      PVector nv = new PVector();

      R_.mult(v, nv);
      nv.x += T_.m03;
      nv.y += T_.m13;
      nv.z += T_.m23;

      apc.add(nv);
    }

    return apc;
  }

  //Linear interpolation between two matrix
  public static PMatrix3D lerpMatrix(PMatrix3D matA, PMatrix3D matB, float nt) {
    float m00 = lerp(matA.m00, matB.m00, nt);
    float m01 = lerp(matA.m01, matB.m01, nt);
    float m02 = lerp(matA.m02, matB.m02, nt);
    float m03 = lerp(matA.m03, matB.m03, nt);
    float m10 = lerp(matA.m10, matB.m10, nt);
    float m11 = lerp(matA.m11, matB.m11, nt);
    float m12 = lerp(matA.m12, matB.m12, nt);
    float m13 = lerp(matA.m13, matB.m13, nt);
    float m20 = lerp(matA.m20, matB.m20, nt);
    float m21 = lerp(matA.m21, matB.m21, nt);
    float m22 = lerp(matA.m22, matB.m22, nt);
    float m23 = lerp(matA.m23, matB.m23, nt);
    float m30 = lerp(matA.m30, matB.m30, nt);
    float m31 = lerp(matA.m31, matB.m31, nt);
    float m32 = lerp(matA.m32, matB.m32, nt);
    float m33 = lerp(matA.m33, matB.m33, nt);

    return new PMatrix3D(m00, m01, m02, m03, m10, m11, m12, m13, m20, m21, m22, m23, m30, m31, m32, m33);
  }

  //Get a matrix as a float array
  public static float[] getMatrix(PMatrix3D matA) {
    float[] array = {matA.m00, matA.m01, matA.m02, matA.m03, matA.m10, matA.m11, matA.m12, matA.m13, matA.m20, matA.m21, matA.m22, matA.m23, matA.m30, matA.m31, matA.m32, matA.m33};
    return array;
  }

  //Get a matrix as a double array
  public static PMatrix3D getMatrix(double[] mat) {
    return new PMatrix3D(
      (float) mat[0], (float) mat[1], (float) mat[2], (float) mat[3], 
      (float) mat[4], (float) mat[5], (float) mat[6], (float) mat[7], 
      (float) mat[8], (float) mat[9], (float) mat[10], (float) mat[11], 
      (float) mat[12], (float) mat[13], (float) mat[14], (float) mat[15]
      );
  }

  /**
   * GEOMETRY.VECTOR
   * The following methods will provide various methods for vector & vectorlist computation sur as Center
   */
  //get the centroid from a <List>
  public static PVector getCentroid(ArrayList<PVector> list) {
    float n = 1.0f/list.size();
    PVector centroid = new PVector();
    for (PVector v : list) {
      centroid.add(v);
    }
    centroid.mult(n);
    return centroid;
  }

    //Substract centroid to vector list (recenter shape at 0,0,0)
  public static void subCentroid(ArrayList<PVector> data, PVector centroid) {
    for (int i=0; i<data.size(); i++) {
      PVector v = data.get(i).copy();
      v.sub(centroid);
      data.set(i, v);
    }
  }

  /**
   * GEOMETRY.POINTS
   * The following methods will provide various methods for points list comparison and computation
   */

  //get the normalized Root Mean Squared Error between two list (value and target)
  //from : https://en.wikipedia.org/wiki/Root_mean_square
  public static float RMSE(ArrayList<PVector> values, ArrayList<PVector> expected) {
    try {
      return findRMSE(values, expected);
    }
    catch(Exception e) {
      e.printStackTrace();
      return 1.0f;
    }
  }

  public static float findRMSE(ArrayList<PVector> values, ArrayList<PVector> expected) throws Exception {
    float RMSE = 1.0f;
    if (values.size() == expected.size()) {
      float MEANX = 0;
      float MEANY = 0;
      float MEANZ = 0;

      for (int i=0; i<values.size(); i++) {
        PVector v = values.get(i);
        PVector e = expected.get(i);

        float diffx = e.x - v.x;
        float diffy = e.y - v.y;
        float diffz = e.z - v.z;
/*
        println(i+" diffx: "+diffx);
        println(i+" diffy: "+diffy);
        println(i+" diffz: "+diffz);
*/
        MEANX += diffx;
        MEANY += diffy;
        MEANZ += diffz;
      }

      MEANX /= values.size();
      MEANY /= values.size();
      MEANZ /= values.size();
/*
      println("MEANX: "+MEANX);
      println("MEANY: "+MEANY);
      println("MEANZ: "+MEANZ);
*/
      float MEAN = (MEANX + MEANY + MEANZ) / 3.0f;

      RMSE = sqrt(pow(MEAN, 2));
    } else {
      throw new Exception("Lists must be the same size");
    }
    return RMSE;
  }


  /**
   * Compute the ratio of overlapping point from list A on List B based on a specific threshold
   */
  public static float getOverlappingRatio(ArrayList<PVector> list1_, ArrayList<PVector> list2_, float threshold) {
    float ratio = 0.0f;

    for (PVector v1 : list1_) {
      for (PVector v2 : list2_) {
        float d = PVector.dist(v1, v2);
        if (d <= threshold) {
          ratio++;
          break;
        }
      }
    }

    return (float) ratio / (float) list1_.size();// / list1_.size();
  }

  /**
   * Return true if list of point A is inside the poly polyvert
   * @param  {[type]}  ArrayList<PVector> pointList     [description]
   * @param  {[type]}  ArrayList<PVector> polyVert      [description]
   * @return {Boolean}                    [description]
   */
  static public boolean isInsidePoly(ArrayList<PVector> pointList, ArrayList<PVector> polyVert){
    float ratio = getInsidePolyRatio(pointList, polyVert);
    boolean result = false;
    if(ratio >= 1){
      result = true;
    }else{
      result = false;
    }
    return result;
  }

  /**
   * Return bool of point inside a poly
   * @param  {[type]}  PVector            loc           [description]
   * @param  {[type]}  ArrayList<PVector> polyVert      [description]
   * @return {Boolean}                    [description]
   */
  static public boolean isInsidePoly(PVector loc, ArrayList<PVector> polyVert){
    boolean result = false;
    try{
      result = isInsidePolygon(loc, polyVert);
    }catch(Exception e){
      e.printStackTrace();
    }
    return result;
  }

  /**
   * Return bool of point inside a poly
   */
  static public boolean isInsidePolygon(PVector loc, ArrayList<PVector> polyVert)  throws Exception {
    //Base on Paul Bourke algorithm : http://paulbourke.net/geometry/polygonmesh/
    /**
     * Determining if a point lies on the interior of a polygon
     */
    boolean result = false;
    if(polyVert.size() == 0){
      throw new Exception("Polygon has not any vertices");
    }else if(polyVert.size() < 3){
      throw new Exception("Polygon has not enough vertices, you need more than 2 vertices");
    }else{
      int i, j;
      int sides = polyVert.size();
      for (i=0, j=sides-1; i<sides; j=i++) {
        if ((((polyVert.get(i).y <= loc.y) && (loc.y < polyVert.get(j).y)) || ((polyVert.get(j).y <= loc.y) && (loc.y < polyVert.get(i).y))) 
          && (loc.x < (polyVert.get(j).x - polyVert.get(i).x) * (loc.y - polyVert.get(i).y) / (polyVert.get(j).y - polyVert.get(i).y) + polyVert.get(i).x)) {
          result = !result;
        }
      }
    }
    
    return result;
  }

  /**
   * Return the ratio of point from a list which are inside a poly
   * @param  {[type]} ArrayList<PVector> pointList     [description]
   * @param  {[type]} ArrayList<PVector> polyVert      [description]
   * @return {[type]}                    [description]
   */
  static public float getInsidePolyRatio(ArrayList<PVector> pointList, ArrayList<PVector> polyVert){
    float ratio = 0.0f;
    for(PVector v : pointList){
      if(isInsidePoly(v, polyVert)){
        ratio ++;
      }
    }
    ratio = (float)ratio / (float)pointList.size();
    return ratio;
  }



  /**
   * EJML
   * The following methods provide bridge between P5 and EJML
   */
  //Get EJML Simple Matrix from <List>
  public static SimpleMatrix getMatrix(ArrayList<PVector> list) {
    double[][] data = new double[list.size()][3];
    for (int i=0; i<list.size(); i++) {
      data[i][0] = list.get(i).x;
      data[i][1] = list.get(i).y;
      data[i][2] = list.get(i).z;
    }
    return new SimpleMatrix(data);
  }

  //Get EJML Simple Matrix from PVector
  public static SimpleMatrix getMatrix(PVector list) {
    double[][] data = new double[1][3];

    data[0][0] = list.x;
    data[0][1] = list.y;
    data[0][2] = list.z;

    return new SimpleMatrix(data);
  }
}
  public void settings() {  size(800, 800); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "MathsClass" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
