namespace sson

import System
import System.Collections.Generic

static class SSON:

	def trySetObjects(ref objects as Dictionary[of string, Dictionary[of string, string]], rawObjectData as (string)):
	
	objects = Dictionary[of string, Dictionary[of string, string]]();
	defaultValues = Dictionary[of string, Dictionary[of string, string]]();
	
	readingObject, readingDefault = false, false
	currentObject = ""
	lineCount = 0
	
	for str in rawObjectData:
		
		++lineCount
		
		if str.StartsWith("#") or str.Length == 0:
			continue
			
		if str.StartsWith("."):
				
			keyValuePair = str.Split("=".ToCharArray(), 2)
			
			if keyValuePair.Length < 2:
				
				print "expected a value after $str at line $lineCount; property cannot be empty"
				return false
			
			keyValuePair[0] = keyValuePair[0][1:]
			keyValuePair[0] = keyValuePair[0].Trim() 
			keyValuePair[1] = keyValuePair[1].Trim()
			
			if readingDefault:
				
				if not defaultValues.ContainsKey(currentObject):
					defaultValues.Add(currentObject, Dictionary[of string, string]())
					
				if not defaultValues[currentObject].ContainsKey(keyValuePair[0]):
					defaultValues[currentObject].Add(keyValuePair[0], keyValuePair[1])
					
				else:
					defaultValues[currentObject][keyValuePair[0]] = keyValuePair[1]
					
			else:
				
				if not objects.ContainsKey(currentObject):
					objects.Add(currentObject, Dictionary[of string, string]())
					
				if not objects[currentObject].ContainsKey(keyValuePair[0]):
					objects[currentObject].Add(keyValuePair[0], keyValuePair[1])
					
				else:
					objects[currentObject][keyValuePair[0]] = keyValuePair[1]
		else:
				
			if str.StartsWith("default"):
				
				readingObject, readingDefault = true, true
				
				# removes the default out of the string.
				currentObject = str[7:].Trim();
			
			else:
				
				cleanStr = str.Trim()
				
				currentObject = "$(cleanStr)_$lineCount"
				readingObject = true
				
				if defaultValues.ContainsKey(cleanStr):
					
					objects.Add(currentObject, Dictionary[of string, string]())
						
					for property in defaultValues[cleanStr]:
						objects[currentObject].Add(property.Key, property.Value)
			
	return true