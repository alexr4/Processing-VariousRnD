# Various RnD/POC
This repository gathers various RnD or POC project.
Some of them are temporary RnD which can be developped as library, project or snippets.

## Archived Content
* _ARCHIVES_ (old RnD sketch which have been implemented into libraries or snippets on the Bonjour Git platform)
* * DataMoshing (implemented into GPUImage)
* * * _DataMoshing_old_ : GLSL datamoshing shader based on GODPUS (https://github.com/GODPUS/shaders/blob/master/datamosh/glsl/datamosh.glsl)
* * * _DataMoshing_ : GLSL datamoshing shader 3 based for experiments
* * _encodingRGBA_ (implemented into GPUImage) : tests and comparisons of various Float to RGBA encoding/decoding. See [GPUImage library comparison doc](https://gitlab.bonjour-lab.com/alexr4/GPUImage/blob/master/floatToRGBAEncoding.md) for more information
* * _findRectangleFromArea_ (implemented into GPUImage): find width/height of a rectangle nearest to the squared size
* * _Image Filtering_ : (P5/GLSL) various glsl image filtering (implemented into GPUImage):
* * * _BlClean_ : Bilateral Filter (GLSL)
* * * _BilateralFilter_ : Bilateral Filter (GLSL)
* * * _DepthTest_ : Pixel completion using dilation (CPU approach)
* * * _DilateFilterGLSL_ :  Pixel completion using dilatation various neighbors (GLSL)
* * * _Filter4Processing_ : repository from Raphaël de Courville (https://github.com/SableRaf) (GLSL)
* * * _ImageFiltering_ : first image filtering wrapper class for Bonjour Lab (GLSL)
* * * _MedianFilter_ : 3×3 & 5×5 median filter (GLSL)
* * _kinectDepthMod_ : Encoding test using mod and index. An array width data from 0 to 4500 pack into an array from 0 to 255 (Grey value) and index of each mod column is troed as alpha map from 0 to 255 (4500/255 = 17 column). This approach is inspired by the kinect depth 256 view, which is a debug view, in order to create an image which carries the depth without using a Floating Point texture **working**
*	* _kinectDepthMod2_ : see _kinectDepthMod_. Same example with texture generation
* * _KinectRawDataBufferedImageTest_ : Writing simple modulo256 depth texture from Depth raw data of the kinect. It shows that the getRawDepthData() methods return array with values between [0-8000]
* * _SignedDistanceField_ (implemented into GPUImage): SDF implementation for CPU and GPU

## Main Content
* _BufferedImageTest_ : Test of writing rgba value of BufferedImage
* _cameraFocalTest_: Focal length and FOVxy computation
* _Color Grading_ : Various test for LUT implementation
	* _LUT_ : Simple 2D LUT implementation based on [Lev Zelnsky Paper](http://liovch.blogspot.fr/2012/07/add-instagram-like-effects-to-your-ios.html?m=1) [**Need to be implemented into GPUImage Library**](https://gitlab.bonjour-lab.com/alexr4/GPUImage)
	* _LUT_2_ : Simple 1D LUT implemantion inspired by ramp used in Unity3D and based on [Alain Galvan](http://alaingalvan.tumblr.com/post/79864187609/glsl-color-correction-shaders) [**implemented into GPUImage library**](https://gitlab.bonjour-lab.com/alexr4/GPUImage)
	* _LUT_Generator_ : 1D LUT generator [**implemented into GPUImage library**](https://gitlab.bonjour-lab.com/alexr4/GPUImage)
* CommandLinesHelpers : Various command line helpers
* * CMDLauncher : Launch/Kill app using command line
* * cmdLineWithArguments : example for mlaunching app with argument (size, position...) from command line
* _CPU-GPU rototranslation_ : various sketches testing rototranslation of point cloud data from kinect from CPU to GPU
* * _CPU_Rototranslation_ : Load dataset as ByteBuffer, perform back-projection and rototranslation into CPU then feed a custom interleaved _VBO_
* * _GPUBuffer_Rototranslation_ : Load dataset as ByteBuffer, perform back-projection and rototranslation into GPU using a GLSL shader + floatToRGBA Encoding methods using 3 rows (X,Y,Z)
* * _GPUBuffer_Rototranslation_CPUVBO_ : used _GPUBuffer_Rototranslation_ method to perform data matrix operation into GPU and feed a custom interleaved _VBO_
* * _GPUBuffer_Rototranslation_GPUVBO_ : used _GPUBuffer_Rototranslation_ method to perform data matrix operation into GPU and decode it using a vertex shader in a custom interleaved _VBO_
* * _GPUVert_Rototranslation_ : Load dataset as ByteBuffer, perform back-projection and rototranslation into GPU from a custom interleaved _VBO_ (int depth data unpacking produce stripes [gpu bug])
* * _IntPackingTest_ : int packing/unpacking test for depth data
* _DifferentialGrowthSimulation_ : Differential Growth simulation (line and ellipse) without any classes
* _easeBounce_ : Bouncing in/out easing function
* _EasingGLSL_ : easing methods set to glsl function
* _EnvironmentMap_ : simple environment map (cube) using cmft for generating mipmap from .ibl files
* _FFMPEGExport_ : simple mockup for video export
* _FloatingPointTextureWithPixelFlow_ :  (P5)Creating a pingpong Floating Point buffer using Pixelflow library  (example from processing github issue) + test for creating a native Floating Point Texture using PJOGL (low level) **working this pixelflow, not working with native implementation**
* _FXAA_ : Post process antialiasing filter (usefull for RayMarched shader)
* _Glitch Transition_ : glitch transition between two frames using gpuimage.filter.glitch
* _GPGPU3D-Iterations_ : Various GPGPU iteration using GPUImage library
* * _GPGPU3D_0_ : encoding/decoding position using FloatPacking and 3 buffers (x,y,z). CPU side only
* * _GPGPU3D_1_ : encoding/decoding position using FloatPacking and 3 buffers (x,y,z). Encoding into CPU, decoding into GPU shader
* * _GPGPU3D_2_ : encoding/decoding position using FloatPacking and 1 interleaved buffers (x,y,z). Encoding into CPU, decoding into GPU shader
* * _GPGPU3D_3_ : encoding/decoding position using FloatPacking and 1 interleaved buffers (x,y,z). CPU side only
* _GPUDLA & GPUDLA2_ : GLSL based diffuse limited aggregation
* _GPUImage_OpticalFlow_ : GLSL Optical flow using GPUImage — not optimize as clear() and blend(REPLACE) are not handle by the library
* _IncludeShader_ : simple #include method for shader (not suitable for prod as it save and load files)
* _imageStreaming_ : udp image sender/receiver
* _ImgFilteringTest_ : test for mimaps and filtering in processing
* _intEncodingUsingBitShifting_ : int encoding into RGBA using bitshift operation (CPU only, GPU shader cannot decode using bitshift operator)
* _KinectData_ : Guta's sketches loading raw kinect depth data as Bytes
* _LightTest_ : Lighting test using native P5 elements & EngineP5 lighting wrapper
* _LoopedNoise_ : looped noise using sin wave of an angle for polar shape
* _LowLevelGLWiki_ : Low level VBO from processing wiki
* _NDI_ : various NDI test using java binding from Walker Knapp https://github.com/WalkerKnapp/devolay
* _noisesFunctions_ : noise generators
* _Octree_ : octree system
* _PerPixelShader_ : Per pixel shader for P5 (base for EngineP5)
* _ParticleSystemModel_ : New Particles system based on Nature of Code with a more extendable Pattern
* _ParticleSystemModel3D_ : New 3D Particles system based on Nature of Code with a more extendable Pattern
* _PeasyPG_ : multiple peasyCam on multiple PGraphics buffer
* _PixelLeaking_ : Simple pixel leaking shader (one pass)
* _QuadTree_ : simple QuadTree system for 2D space division (and optimisation)
* _ReactionDiffusion_GreyScott_ : GLSL Reaction diffusion shader based on Karl Sim tutorial
* _Semi-TransparentTest_ : test d'alpha blending avec PGraphicsOpenGL
* _Shadow2DRayCasting_ : 2D shadow ray casting + glsl post process based on https://ncase.me/sight-and-light/
* _Shape3DSpawner_ : Partciles system spawned based on a input mesh (use _ParticleSystemModel3D_)
* _SketchModel_" : Simple sketch model for P using Time, config, ico and arguments for cmd line launchers
* _TimeCounter_ : Game like time counter systeme allowing to count time and deltatime and pause their computation
* _TimeHelpers_ : Various time helper manipulations (modTime, normTime, loopCount)
* _TimeOffset_ : Curve manipulation based on Gradient
* _TriangulationTest_ : test lib trangulate
* _VideoController_ : class extending Movie in order to add events and snapshot
* _Voronoi_ : full GLSL Voronoi texture generator (round and squared edges)

## To do, to debug or to finish
* Depth : (P5) trying to retreived/grab depth buffer from PJOGL
	* _getDepthAt_ : Retreived depth value at [x,y] on the depth buffer (example from p5 forum) **working**
	* _getDepthBuffer_ : Read the pixel from the buffer and update pixels Array from PImage **working**
	* _getDepthAtonG_ : Read depth buffer from g **working**
	* _BindLowLevelTextureEdit_ : test from nacho Cossio **not working**
	* _BindLowLevelTexture_ : test to copy depth directly into texture
* _FluidSimulation_ : Tutorial from Dan. Shiffman on Fluid Simulation → Goal : translate it into GLSL + refactorisation complete
* _GPU3DPhysicsSimulation_ : test de simulation physic 3D GPGPU : cassé côté shader. Probleme dans les coordonnées de texture XYZ qui sont "messed up"
* _MathsClass_ : first maths wrapper from Adidas project → Need to be implemented as a [Math library](https://github.com/Bonjour-Interactive-Lab/BMaths)
* _PixelLeaking_ : GLSL pixel leaking (straight line and wave) → Need to find a proper implemantion
* _RayMarching_ : GLSL Ray marching basics learning (See asana to list for courses list)
