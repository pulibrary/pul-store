#get_coords.py

from requests import get
import csv
import json

GEONAMES_UNAME = ''
SEARCH_URI = 'http://api.geonames.org/searchJSON' #?q=london&maxRows=10&username=demo
INFO_URI = 'http://api.geonames.org/countryInfoJSON' #?formatted=true&lang=it&country=DE&username=demo&style=full
AREAS_IN = '/home/jstroop/Desktop/new_areas.csv'
OUTPUT = '/home/jstroop/Desktop/lae_areas.csv'

def info_for_code(code):
    params = { 'country': code, 'username': GEONAMES_UNAME }
    r = get(INFO_URI, params=params, allow_redirects=False)
    return json.loads(r.text)['geonames'][0]#headers[URI_HEADER] if r.status_code == 302 else None


with open(AREAS_IN, 'rb') as area_file, open(OUTPUT, 'wb') as output_file:
    reader = csv.reader(area_file)
    next(reader, None) # skip header row
    writer = csv.writer(output_file, quoting=csv.QUOTE_ALL)
    writer.writerow(('label','iso_3166_2_code','gac_code','uri','geoname_id','north','south','east','west'))
    for row in reader:
        if row[1]:
            info = info_for_code(row[1])
            new_fields = [info[k] for k in ['geonameId','north','south','east','west']]           
            new_row = row + new_fields
            writer.writerow(new_row)
        else:
            writer.writerow(row)

        

