'''
Created on Jun 21, 2015

@author: qcriadmin
'''
import sys
import getopt
import shutil

class ConversionEngine(object):
    '''
    classdocs
    '''

    def __init__(self, params):
        '''
        Constructor
        '''
    def execute(self, input_file, output_file):
        shutil.copyfile(input_file, output_file)
    
if __name__ == '__main__':
    inputfile = ''
    outputfile = ''
    try:
        opts, args = getopt.getopt(sys.argv,"hi:o:",["ifile=","ofile="])
    except getopt.GetoptError:
        print('conversionengine.py -i <inputfile> -o <outputfile>')
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print('conversionengine.py -i <inputfile> -o <outputfile>')
            sys.exit()
        elif opt in ("-i", "--ifile"):
            input_file = arg
        elif opt in ("-o", "--ofile"):
            output_file = arg
    print('Input file is "', input_file)
    print('Output file is "', output_file)
    convEngine=ConversionEngine()
    convEngine.execute(input_file,output_file)
