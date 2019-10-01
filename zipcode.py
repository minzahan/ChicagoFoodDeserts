import csv
import sys

from googlemaps import Client
from googlemaps import geocoding
import geocoder
import json



def getZipcode(loc):
    g = geocoder.osm(loc)
    #print("address: "+str(g)+"_____ location:"+loc)
    addressArr = str(g.json['address']).split(',',-1)
    return(addressArr[len(addressArr)-2])
    
def getZipcodeGoogle(lat, lon):
    gkey = ''
    g = Client(key=gkey)
    location = g.reverse_geocode((lat,lon))
    print(location)


def loadCrimeFile():
    with open('Crimes_-_2012 filtered.csv', newline='') as csvfile:
        crimes = csv.reader(csvfile, delimiter=',', quotechar='"')
        i = 0
        for row in crimes:
            if i < 10000:
                writeNewFile(row, i)
            i = i + 1 


def writeNewFile(row, num):
    with open('crimes_cleaned.csv',newline='', mode='a') as csvfile:
        output_file = csv.writer(csvfile, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)
        location = ','.join([row[18],row[20]])
        if num > 0:
            zipcode = getZipcode(location)
        else:
            zipcode = "Zipcode"
        values = [row[5],row[6],row[7],row[11], location, zipcode]
        #output_row = ','.join(values)
        #print(output_row)
        output_file.writerow(values)

if __name__ == "__main__":
    #loadCrimeFile()
    getZipcodeGoogle(float("41.7648409"),float("-87.67029776"))
