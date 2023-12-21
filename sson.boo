namespace sson

import System
import System.Collections.Generic

static class SSON:

	def trySetObjects(ref objects as Dictionary[of string, Dictionary[of string, string]], rawObjectData as (string)):
	
	objects = Dictionary[of string, Dictionary[of string, string]]();
	defaultValues = Dictionary[of string, Dictionary[of string, string]]();
	
	readingDefault = false
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
				
				readingDefault = true
				
				# removes the default out of the string.
				currentObject = str[7:].Trim();
				
			elif str.StartsWith("alias"):
				
				defaultValueToCopy = ""
				
				for k in defaultValues.Keys:
					
					if str.EndsWith(k):
						
						defaultValueToCopy = k
						break
						
				if defaultValueToCopy.Length == 0:
					
					print "couldn't match $str with an extant default object at line $lineCount."
					return false
				
				readingDefault = true
				
				# removes the alias out of the string.
				currentObject = str[5:str.Length-defaultValueToCopy.Length].Trim();
				
				if not defaultValues.ContainsKey(currentObject):
					defaultValues.Add(currentObject, Dictionary[of string, string]())
				
				for val in defaultValues[defaultValueToCopy]:
					
					if not defaultValues[currentObject].ContainsKey(val.Key):
						defaultValues[currentObject].Add(val.Key, val.Value)
						
					else:
						defaultValues[currentObject][val.Key] = val.Value
			else:
				
				cleanStr = str.Trim()
				
				currentObject = "$(cleanStr)_$lineCount"
				
				if defaultValues.ContainsKey(cleanStr):
					
					objects.Add(currentObject, Dictionary[of string, string]())
						
					for property in defaultValues[cleanStr]:
						objects[currentObject].Add(property.Key, property.Value)
			
	return true