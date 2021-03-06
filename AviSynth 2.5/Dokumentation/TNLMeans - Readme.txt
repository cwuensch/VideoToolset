                                                                                                       |
                                    TNLMeans for Avisynth v2.5.x                                       |
                                       v1.0.3  (28 August 2007)                                        |
                                            by tritical                                                |
                                                                                                       |
                                             HELP FILE                                                 |
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------


INFO:


      TNLMeans is an implementation of the NL-means denoising algorithm. Aside from the original
   method, TNLMeans also supports extension into 3D, a faster, block based approach, and a
   multiscale version.


   Syntax =>

      TNLMeans(int Ax, int Ay, int Az, int Sx, int Sy, int Bx, int By, bool ms, int rm, float a,
                 float h, bool sse)



THEORY OF OPERATION:


      The NL-means algorithm works in the following manner.  For each pixel in the image define
   a search window in which to look for similar pixels.  The search window is defined by the
   parameters Ax and Ay, which set the x-axis radius and y-axis radius.  For each pixel in the
   window determine a weight based on the similarity of that pixel's gray level neighborhood to
   the center pixel's gray level neighborhood.  The neighborhood is defined by the Sx and Sy
   parameters, which set the x-axis radius and y-axis radius.  The similarity between two
   neighborhoods is measured using gaussian weighted (as a function of distance, the standard
   deviation is set by the "a" parameter) sum of squared differences. The final weight for a pixel
   is computed as:

          exp(-(total_sse_difference/sum_of_gaussian_weights)/(h*h));

   If the parameter 'sse' is set to false, then sum of absolute differences is used instead of
   sum of squared differences.  In that case, the final weight for a pixel is computed as:

          exp(-(total_sad_difference/sum_of_gaussian_weights)/h);

      Once a weight for each pixel in the window is acquired, the final pixel value is simply
   the weighted average of all the pixels.  In order for the center pixel to not be too heavily
   weighted, it is assigned a weight equal to the largest weight given to another pixel in the
   search window.

      The block based modification changes the base step (or base window) from 1 pixel to blocks
   with size Bx and By where Bx and By set the x-axis radius and y-axis radius. The support and
   search windows still work the same way, but now whole blocks are computed/averaged at once
   instead of individual pixels.  This modification cuts the computation time down by
   (Bx*2+1)*(By*2+1) times.

      The 3D extension allows extending the search window into neighbor frames.  The parameter
   Az sets the temporal (z-axis) radius.  With Az=1 frames n-1 and n+1 would be included.

      The multiscale version works by running the normal algorithm with Ax/Ay = 2 on the original
   image, and then running the algorithm again on a downsampled (width/2,height/2) version of
   the original image with Ax/Ay/Bx/By/Sx/Sy all divided by 2.  The weights from the two scales
   are then combined to form the final image.  This process can greatly speed up processing for
   large search windows but sacrifices quality (especially around edges/lines/fine details).
   The type of downsampling that is used is set by the 'rm' parameter.


      More information can be found by following the links to papers about NL-means under
   the TNLMeans portion of http://bengal.missouri.edu/~kes25c/.



PARAMETERS:


   Ax, Ay, Az -

      These set the x-axis, y-axis, and z-axis radii of the search window.  These must be
      greater than or equal to 0.  The full window size will be:

           (Ax*2+1) x (Ay*2+1) x (Az*2+1)

      Generally, the larger the search window the better the result of the denoising. Of
      course, the larger the search window the longer the denoising takes.

      Default:  Ax = 4 (int)
                Ay = 4 (int)
                Az = 0 (int)


   Sx, Sy -

      These set the x-axis and y-axis radii of the support (similarity neighborhood) window.
      These must be greater than or equal to 0.  A larger similarity window will retain more
      detail/texture but will also cause less noise removal.  Typical values for Sx/Sy are 2
      or 3.  The full window size will be:

           (Sx*2+1) x (Sy*2+1)

      Default:  Sx = 2 (int)
                Sy = 2 (int)


   BX, By -

      These set the x-axis and y-axis radii of the base window.  In the original NL-means
      algorithm the base was a single pixel (Bx=0 and By=0).  Using blocks larger than a
      single pixel will sacrifice some quality for speed.  Note that Sx must be greater than
      or equal to Bx and Sy must be greater than or equal to By.  It is recommended that
      sx/sy be larger than bx/by.

      Default:  Bx = 1 (int)
                By = 1 (int)


   ms -

      Controls whether or not the multiscale version is used.  The multiscale version is
      faster but lower quality.  The larger ax/ay are the greater the speed increase from
      using the multiscale version will be. If ax/ay are less than or equal to 2 then the
      multiscale version will not give any speed up and will make things slower. The
      multiscale version requires mod 8 input (width divisible by 8).

      Default:  false (bool)


   rm -

      If ms = true, then rm sets the type of resizing used for downsampling.  Possible options:

          0 - Point
          1 - Bilinear
          2 - Bicubic
          3 - Lanczos3
          4 - Spline16
          5 - Spline36

      Default:  4 (int)


   a -

      Sets the standard deviation of the gaussian used for weighting the difference calculation
      used for computing neighborhood similarity.  Smaller values will result in less noise removal
      but will retain more detail/texture.

      Default:  1.0 (float)


   h -

      Controls the strength of the filtering (blurring).  Larger values will remove more noise
      but will also destroy more detail. 'h' should typically be set equal to the standard deviation
      of the noise in the image when using sse=true and assuming the noise fits the zero mean,
      gaussian model.

      Default:  if sse = true  - 1.8 (float)
                if sse = false - 0.5 (float)


   sse -

      Controls whether sum of squared differences or sum of absolute differences is used when
      computing neighborhood similarity. sse is slightly slower but retains fine detail/texture
      better.  sad typically works better for cartoons/anime.  The 'h' parameter usually needs
      to be set about 4 times lower when using sad than when using sse.

         true - use sse
         false - use sad

      Default:  true (bool)



CHANGE LIST:


   08/28/2007  v1.0.3

       - Removed fast exp() approximation that was used for sse=false.  Turns out it was quite
            inaccurate and had overflow problems resulting in artifacts.


   07/30/2006  v1.0.2

       - Fixed a problem with small weights causing artifacts


   06/19/2006  v1.0.1

       - Fixed a bug that caused a crash when ms=true was used with yuy2 input


   05/31/2006  v1.0 Final

       - Fixed always creating the downsampled clip unless ms=false was explicitly
           specified


   05/25/2006  v1.0 Beta 2

       + Added multiscale version (parameters ms/rm)
       + Added sse parameter
       + optimized non-block based routines by buffering (100% speed increase)
       - removed b parameter
       - fixed a bug in the block based routines that caused some blocks
           in the search window not to be tested
       - changed defaults for ax/ay/sx/sy/h


   05/17/2006  v1.0 Beta 1

       - Initial Release



TO DO LIST (for v2.0):


     - adaptively adjust the 'h' parameter in different parts of the image



contact:    doom9.org forum (nick = tritical)