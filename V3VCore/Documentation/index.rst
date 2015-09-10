.. V3V documentation master file, created by
   sphinx-quickstart on Wed Sep  9 16:37:06 2015.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Welcome to V3V's documentation!
===============================

Code Overview:
--------------
    - First of all, There is the initialisation and configuration phase done by the developers, by setting all the Internal Configuration parameters, also setting the Conversion Parameters that are tuned and set by the developers
    - Then, Initialise the list of commonly used  Conversion Parameters to allow the user to choose from them
    - After that, Initialisation and preparation of the DepthDatabases used by the conversion tasks, This is done by giving snapshots of raw images and corresponding depth maps from soccer games as FIFA 2010
    - The final step is to use the Converter.ConversionTask.convert method by giving it the needed parameters
        1) Input Path
        2) Output Path
        3) ConversionParameters
        4) DepthDatabases
    - Then this method does all the steps needed for the conversion:
        1) Read the input video and initialize the parameters needed - InputInterface
        2) Divide the video into chunks to allow parallelization 
        3) Construct the Image Objects by sampling each chunk - InputProcessor
        4) For each Image in each chunk:
            a) Classify this frame (long, medium, close shot) - SceneClassification
            b) Call the appropriate method for conversion, If the method is DGC, then pass to it the needed features and the needed masks - StereoCreator, DGC
        5) Save the output video after conversion finishes - OutputProcessor, OutputInterface

The code consists of 4 main packages:
-------------------------------------
    1) DepthDatabase Package:
        Depth Database package contains all the details of handling the database part of the project (Database Details)

    2) Converter Package:
        Converter package contains all details of the conversion task including: Scene classification, Depth Estimation, Motion Estimation, and Stereo (3D) Creation

    3) Configuration Package:  
        Configuration package contains all the needed parameters either the conversion task parameter or the internal configuration parameters for the whole project    

    4) IOHandling Package:
        IO Handling package deals with different inputs and outputs and defines Input Interfaces, Input Processing, Output Interfaces, and Output Processing

Contents:
---------
.. toctree::
   :maxdepth: 4

   Configuration
   Converter
   DepthDatabase
   IOHandling
   Test




Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`

