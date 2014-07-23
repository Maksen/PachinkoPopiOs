#!/usr/bin/python

"""
	JSON to BINARYJSON

	This converts a JSON file into a BINARY JSON format.
	This format is *NOT* the BSON format.  Instead it is an runtime readable format, it is meant to make random access
	of a JSON file much faster.  It does this by allowing memory mapping of the file.  
"""

"""
	BYTE ORDERING
		As this was intended for use on the iPhone the default byte ordering is little endian.
		Howevevr this must be determined depending upon the signature.  If the signature reads
		'JGFB' when bytes are read in order, then the fields of this file will be in little endian.

	header format:
		----------------------------------------------------------------------------
		| field name 		|	field size |   Description 					
		----------------------------------------------------------------------------
		| signature			| 	0x4 bytes  |   should always be 'BFGJ' or 'JGFB'
		| hierarchy block	| 	4 bytes    |   unsigned long - position of the hierarchy block.
		| data block		|	4 bytes	   |   unsigned long - position of the data block
		----------------------------------------------------------------------------
	
	The signature is meant to validate the file is an appropriate type.
	The hiearchy block specifies where the fields which represent the hierarchy of the 
	file live.   All relative offsets in the hierarchy block start at this position.
	The data block is the location where all the JSON file's data is stored. This means all
	data where the data in the JSON field was a data type, and not a storage type.

	The hierarchy contains all data required to find an object in the hierarchy, this includes
	key strings.

	The data block contains all data fields which are standard types.  i.e. integers, floats, and strings.

	HIERARCHY BLOCK:
		----------------------------------------------------------------------------
		| field name 		|	field size |   Description 					
		----------------------------------------------------------------------------
		| signature			| 	0x4 bytes  |   should always be 'hier'
		| block size		| 	0x4 bytes  |   unsigned long - size of the block.
		| object count		|	0x4 bytes  |   unsigned long - number of objects in the list of hierobjects
		| hierobject list	| 	N bytes	   |   beginning of the list of hierobjects
		----------------------------------------------------------------------------


		HierTypes:
			0x01	- 	HierTypeDictionary 	 (KeyValue dictionary storage)
			0x02	- 	HierTypeArray		 JSON '[]'

		hierarchy object:
			----------------------------------------------------------------------------
			| field name 		|	field size |   Description 					
			----------------------------------------------------------------------------
			| type			 	| 	0x04   	   |   HierType     
			----------------------------------------------------------------------------

		HierTypeDictionary:
			----------------------------------------------------------------------------
			| field name 		|	field size  	|   Description 					
			----------------------------------------------------------------------------
			| type			 	| 	0x04   	    	|   HierType  - HierTypeDictionary
			| keycount			|	0x04	   		|	unsigned long - number of keys.
			| keys				|	0x04 * keycount |	each entry contains an Adler32 CRC of the original key name.  
			| keynames			|	0x04 * keycount |	contains offset into data block of UTF-8 string value.
			| keytype			| 	0x04 * keycount |	unsigned longs defining a hier or data type.
			| keydata			| 	0x04 * keycount | 	if a data type, contains an offset into the data block.
			|					|					| 	if a hiertype, then this contains an offset in hier block, to that object.
			----------------------------------------------------------------------------
			
		HierTypeArray:
			----------------------------------------------------------------------------
			| field name 		|	field size  		|   Description 					
			----------------------------------------------------------------------------
			| type			 	| 	0x04   	    		|   HierType  - HierTypeDictionary
			| itemcount			|	0x04				| 	unsigned long - count of items in the array
			| itemtype			|	0x04 * itemcount	|	unsigned longs defining a hier or data type.
			| itemdata			| 	0x04 * itemcount	|	if a data type, contains an offset into the data block.
			|					|						| 	if a hiertype, then this contains an offset in hier block, to that object.
			----------------------------------------------------------------------------
			
	DATA BLOCK:
		----------------------------------------------------------------------------
		| field name 		|	field size |   Description 					
		----------------------------------------------------------------------------
		| signature			| 	0x04 bytes 	|   should always be 'data'
		| block size		| 	0x04 bytes	|	the size of the entire block
		| object count 		|	0x04 bytes	| 	number of data blocks.
		| data object list  |  	N bytes     |	list of data objects.
		----------------------------------------------------------------------------
		
		The data block contains a list of all the data objects.  Each data object 
		is in the list one right against the other.  Data objects are not read out 
		directly by accessing the data block. Instead type information is stored in
		the hierarchy fields, with offsets to the physical chunk of data in the data block. 
		
			DataTypes:
			0x10	-	UTF-8 string
			0x11	- 	32 bit float
			0x12	- 	Integer (Boolean values should be encoded as integers as well.)

			Data type : UTF-8 string (0x10) :

				----------------------------------------------------------------------------
				| field name 		|	field size 	|   Description 					
				----------------------------------------------------------------------------
				| length			| 	0x04 bytes 	|   Length in bytes of the UTF-8 string
				| strings			| 	length bytes| 	raw byte data of the UTF-8 string
				----------------------------------------------------------------------------

			Data type : 32 bit float (0x11) :
			 
				----------------------------------------------------------------------------
				| field name 		|	field size 	|   Description 					
				----------------------------------------------------------------------------
				| data				| 	0x04 bytes 	|   32 bit float
				----------------------------------------------------------------------------
				
			Data type : 32 bit INTEGER (0x12) :
			 
				----------------------------------------------------------------------------
				| field name 		|	field size 	|   Description 					
				----------------------------------------------------------------------------
				| data				| 	0x04 bytes 	|   32 bit integer
				----------------------------------------------------------------------------

	
"""


import json
import os
import string
import zlib
import sys
import struct
import array

hiertype_dictionary	=0x01
hiertype_array		=0x02
datatype_utf8string =0x10
datatype_float		=0x11
datatype_integer	=0x12

byteorder = "<"

def string_literal(literal):
	result=0
	adjust=3
	
	for i in literal:
		x=ord(i) 
		result= result | (x << (adjust*8))
		adjust-=1
	return result

"""
	Multiple Passes

	- Turn original JSON into JSON with serialized data objects.
	- Build data object with serialized data objects, put offset references into the JSON structure.
	- Serialize hierarchical objects keeping object references to hierarchichal objects.
	- Build hierarchical objects datablock put references into block.

"""

nextoffset=12
dataentries=[]
hierkeys={}
hiernextpos=0
hiernextobj=0
hierobjects={}
hierpositions={}

def encodeType(item):
	global nextoffset

	if (type(item)==type(True)):
		value= item==True
		entry=(nextoffset,struct.pack(byteorder+"l",value),0x12)
		pos=nextoffset
		nextoffset+=4
		return entry		

	if (type(item)==type(u"") or type(item)==type("")):
		text=item.encode('utf8')
		packstr=byteorder+"L%ds"%(len(text))
		packedstring=struct.pack(packstr,len(text),text)
		entry=(nextoffset,packedstring,0x10)
		pos=nextoffset
		nextoffset+=len(text)+4
		return entry

	if (type(item)==type(float(1.0))):
		entry=(nextoffset,struct.pack(byteorder+"f",item),0x11)
		pos=nextoffset
		nextoffset+=4
		return entry
				
	if (type(item)==type(1)):
		entry=(nextoffset,struct.pack(byteorder+"l",item),0x12)
		pos=nextoffset
		nextoffset+=4
		return entry
	

def generateSerializedData(inputjson):
	global dataentries
	if (type(inputjson)==type([])):
		newlist=[]
		for item in inputjson:
			if (type(item)==type([])):
				newlist.append(generateSerializedData(item))
			elif (type(item)==type({})):
				newlist.append(generateSerializedData(item))
			else:
				newitem =encodeType(item)
				dataentries.append(newitem)
				newlist.append(newitem)
		return newlist
		
	if (type(inputjson)==type({})):
		newdict={}
		for item in inputjson:
			d=inputjson[item]
			if (type(d)==type([])):
				newdict[item]=generateSerializedData(d)
			elif (type(d)==type({})):
				newdict[item]=generateSerializedData(d)
			else:
				newdict[item]=encodeType(d)
				dataentries.append(newdict[item])
		return newdict

def generateSerializedKeys(inputjson):
	global dataentries
	if (type(inputjson)==type([])):
		newlist=[]
		for item in inputjson:
			if (type(item)==type([])):
				newlist.append(generateSerializedKeys(item))
			elif (type(item)==type({})):
				newlist.append(generateSerializedKeys(item))
			else:
				newlist.append(item)
		return newlist
		
	if (type(inputjson)==type({})):
		newdict={}
		for item in inputjson:
			if (not hierkeys.has_key(item)):
				t=encodeType(item)
				hierkeys[item]=(zlib.adler32(item),t[0],t[1])
				dataentries.append(t)

			d=inputjson[item]
			if (type(d)==type([])):
				newdict[item]=generateSerializedKeys(d)
			elif (type(d)==type({})):
				newdict[item]=generateSerializedKeys(d)
			else:
				newdict[item]=d
		return newdict

def generateDataBlock():
	global dataentries
	global hierkeys	

	sz=(dataentries[-1][0]-12)+len(dataentries[-1][1])
	result=struct.pack(byteorder+"LLL",string_literal("data"),sz,len(dataentries))

	for item in dataentries:
		result+=item[1]
	
	return result

def objectsize(id):
	global hierobjects
	object=hierobjects[id]
	sz=8
	if (object["type"]==0x02):
		sz+=(len(object["types"])*8)
	if (object["type"]==0x01):
		sz+=(len(object["types"])*16)
	return sz

def encodeHierObject(object):
	global hieroffset
	global hiernextobj
	global hierobjects
	global hierpositions
	global hiernextpos
	global dataentries

	if (type(object)==type([])):
		itemtypes=[]
		itemdata=[]
		result=""
		curid=hiernextobj
		hiernextobj+=1
		hierpositions[curid]=hiernextpos
		hiernextpos+=8+(len(object)*8)
		for item in object:
			if (type(item)==type({})):
				itemtypes.append(0x01)
				itemdata.append(encodeHierObject(item))
			elif (type(item)==type([])):
				itemtypes.append(0x02)
				itemdata.append(encodeHierObject(item))
			else:
				r=item
				itemtypes.append(r[2])
				itemdata.append(r[0])
										
		hierobjects[curid] = {"type":0x02, "types":itemtypes, "data":itemdata}

		return curid

	if (type(object)==type({})):
		keytypes=[]
		keydata=[]
		keynames=[]
		keycrc=[]
		result=""
		curid=hiernextobj
		hiernextobj+=1
		hierpositions[curid]=hiernextpos
		hiernextpos+=8+(len(object.keys())*16)
		for item in object:
			hkey=hierkeys[item]
			if (type(object[item])==type({})):
				keytypes.append(0x01)
				keycrc.append(hkey[0])
				keynames.append(hkey[1])
				keydata.append(encodeHierObject(object[item]))
			elif (type(object[item])==type([])):
				keytypes.append(0x02)
				keycrc.append(hkey[0])
				keynames.append(hkey[1])
				keydata.append(encodeHierObject(object[item]))
			else:
				r=object[item]
				keytypes.append(r[2])
				keycrc.append(hkey[0])
				keynames.append(hkey[1])
				keydata.append(r[0])

		hierobjects[curid] = {"type":0x01, "types":keytypes, "data":keydata, "names":keynames, "crcs":keycrc }
	
		return curid
	return None
		
def serializeobject(object):
	global hierpositions
	result=""
	childcount=len(object["types"])
	result=struct.pack(byteorder+"LL",object["type"],childcount)
	curchild=""
	if (object["type"]==0x01):
		# add crcs
		for n in range(0,childcount):
			curchild+=struct.pack(byteorder+"l",object["crcs"][n])
		for n in range(0,childcount):
			curchild+=struct.pack(byteorder+"L",object["names"][n])
		for n in range(0,childcount):
			curchild+=struct.pack(byteorder+"L",object["types"][n])
		for n in range(0,childcount):
			keydata=None
			if (object["types"][n]>=0x10):
				keydata=object["data"][n]
			else:
				keydata=hierpositions[object["data"][n]]+12
			curchild+=struct.pack(byteorder+"L",keydata)

	if (object["type"]==0x02):
		# add crcs
		for n in range(0,childcount):
			curchild+=struct.pack(byteorder+"L",object["types"][n])
		for n in range(0,childcount):
			keydata=None
			if (object["types"][n]>=0x10):
				keydata=object["data"][n]
			else:
				keydata=hierpositions[object["data"][n]]+12
			curchild+=struct.pack(byteorder+"L",keydata)
	result+=curchild
	return result

def generateHierBlock(inputjson):
	global hierkeys	
	global hierobjects
	global hierpositions

	baseobj=encodeHierObject(inputjson)

	total=0
	for objid in hierobjects:
		total+=objectsize(objid)
	
	result=""

	count=0
	while (count<total):
		count+=1;
		result+="\0"
	
	buffer=array.array("c",result)
	
	for objid in hierobjects:
		object=hierobjects[objid]
		serialized=serializeobject(object)
		struct.pack_into("%ds"%(len(serialized)),buffer,hierpositions[objid],serialized)

	result = struct.pack(byteorder+"LLL",string_literal("hier"),len(result)+12,len(hierobjects))+buffer.tostring()

	return result

def generateBlocks(jsonfile,outputfile):
	hierblock=0
	datablock=0

	datablock=generateDataBlock()
	hierblock=generateHierBlock(jsonfile)

	signature=string_literal("BFGJ")
	headerblock = struct.pack(byteorder+"LLL",signature,12,12+len(hierblock))

	f=open(outputfile,"wb")
	f.write(headerblock)
	f.write(hierblock)
	f.write(datablock)
	f.close()


def JSONToBinary(inputjson,outputfile):	
	global dataentries
	inputjson=generateSerializedData(inputjson)
	inputjson=generateSerializedKeys(inputjson)

	generateBlocks(inputjson,outputfile)


if (__name__=="__main__"):
	
	filepathin	= sys.argv[1]
	filepathout = sys.argv[2]
	
	"""
	filepathin	= "testconvert.json"
	filepathout = "testconvert.jsonb"
	"""

	f=open(filepathin,"rb")
	d=f.read()
	f.close()
	j=json.JSONDecoder().decode(d)
	
	JSONToBinary(j,filepathout)



"""
	To do make key generator which generates the CRC'd keys.
"""

	







