from DepthDatabase.BasicDepthDatabase import BasicDepthDatabase
from Configuration.ConversionParameters import ConversionParameters, Resolution,\
    ResizeFactor
from Converter.ConversionTask import ConversionTask

database = BasicDepthDatabase("soccer")

#database.addImageData("/Users/OmarEltobgy/Dropbox/Workspace/V3VCore/Test/RGB", "/Users/OmarEltobgy/Dropbox/Workspace/V3VCore/Test/Depth")
#database.loadImageData()

conversionParam = ConversionParameters(resolution=Resolution.HD, resizeFactor=ResizeFactor.EIGHT)
#database.computeFeatures(conversionParam)

#database.addImageData("/Users/OmarEltobgy/Dropbox/Workspace/V3VCore/Test/RGB", "/Users/OmarEltobgy/Dropbox/Workspace/V3VCore/Test/Depth")

#databaseFeatures = database.getFeatures(conversionParam)

ConversionTask.convert("", "", conversionParam, database)
