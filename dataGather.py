# Hard Coded Variables
##################################################################################################
url = "https://realtime.sdmts.com/api/api/gtfs_realtime/vehicle-positions-for-agency/MTS.pb?key="
key = "65855fcd-32a6-4ddc-8b70-ab58f6806e21"
link = url + key
path = "/home/pi/SDMTS"

data_dest = path + "/data.pb"
file_dest = path + "/ParsedDataFeed/"
extension = ".csv"

header = "route,trip_id,timestamp,latitude,longitude,vehicle_id\n"
first_bus = "00:00"
##################################################################################################

import os
import sys
sys.path.append(path)
import gtfs_realtime_pb2
import datetime
from time import time
from time import sleep
import urllib
import schedule
import threading

# Classes
##################################################################################################
class GTFS_feed_manager:
    
    def __init__(self):
        
        self.date = str(datetime.date.today())
        
        file_name = file_dest+self.date+extension
        f = open(file_name, 'w')
        f.write(header)
        f.close()
        self.file_name = file_name
	self.file_name_short = self.date+extension
    
    def get_info_string(self, entity):
        timestamp = str(entity.vehicle.timestamp)
        trip_id = entity.vehicle.trip.trip_id
        latitude = str(entity.vehicle.position.latitude)
        longitude = str(entity.vehicle.position.longitude)
        vehicle_id = entity.vehicle.vehicle.id
	route = entity.vehicle.trip.route_id
        return route+","+trip_id+","+timestamp+","+latitude+","+longitude+","+vehicle_id+"\n"

    def update(self):
	urllib.urlretrieve(link, filename=data_dest)
        d = open(data_dest, 'rb')
        vehicle_position = gtfs_realtime_pb2.FeedMessage()
        vehicle_position.ParseFromString(d.read())
        d.close()
        with open(self.file_name, 'a') as f:
            for entity in vehicle_position.entity:
                if entity.vehicle.trip.route_id != "":
                    f.seek(0,2)
                    info_string = self.get_info_string(entity)
                    f.write(info_string)
	os.system("rm "+data_dest) 
        return
    
    def mv(self): 
        os.system("mv "+self.file_name+" "+file_dest+"Completed")
        return
##################################################################################################

# Subroutines
##################################################################################################

def new_feed():
    feed_manager = GTFS_feed_manager()
    for _ in range(1440):
        try:
            feed_manager.update()
	    sleep(60)
        except:
            sleep(60)
   	    continue

    feed_manager.mv()
    return

def run_threaded(job_func):
    job_thread = threading.Thread(target=job_func)
    job_thread.start()

##################################################################################################

schedule.every().day.at(first_bus).do(run_threaded, new_feed)

while 1:
    schedule.run_pending()
    sleep(1)
