# see https://fritzconnection.readthedocs.io/en/1.0.1/sources/library.html#module-fritzconnection.lib.fritzwlan
# pip3 install fritzconnection
# pip3 install requests
from fritzconnection import FritzConnection
from fritzconnection.lib.fritzwlan import FritzWLAN
from fritzconnection.lib.fritzhomeauto import FritzHomeAutomation


fc = FritzConnection(address='192.168.29.211', password='A1sanKohler20.03.2015')
#fw = FritzWLAN(fc) # all networks: 2.4GHz, 5GHz and guest network
fh = FritzHomeAutomation(fc)
# AIN of FritzDect in Living Room
ain = '08761 0050583'


# list of IPs that indicate that someone is at home
list_of_IPs = ['192.168.29.66', '192.168.29.83','3C:19:5E:0D:66:D2', 'EE:75:35:78:AC:B0']

def isIPinList(thisIP):
    try:
        result = next(ip for ip in list_of_IPs if ip == thisIP)
    except StopIteration:
        result = ''
    return (result != '')

def isAnyoneOnNetwork(serviceNo, filter):
    try:
        fw = FritzWLAN(fc, service=serviceNo)
        hosts = fw.get_hosts_info()
        if (not hosts):
            return False
        try:
            result = next(host for host in hosts if isIPinList(host[filter]))
            #print('Found %s on network %d using %s' % (result, serviceNo, filter))
        except StopIteration:
            result = ''
        return (result != '')
    except:
        # don't switch off my heating...
        return True

def isAnyoneAtHome():
    isIPonNet  = isAnyoneOnNetwork(1, 'ip') or isAnyoneOnNetwork(2, 'ip') or isAnyoneOnNetwork(3, 'ip') 
    isMAConNet = isAnyoneOnNetwork(1, 'mac') or isAnyoneOnNetwork(2, 'mac') or isAnyoneOnNetwork(3, 'mac') 
    return isIPonNet or isMAConNet

# Living room is the coldest room in the house
def getColdestRoomTemp():
    try:
        # FritzDect in living room
        roomFD=fh.get_device_information_by_identifier(ain)
    except:
        print('getColdestRoomTemp: connection to FritzBox lost')
        return 0

    if (roomFD['NewDeviceName'] == 'Living Room'
        and roomFD['NewPresent'] == 'CONNECTED'
        and roomFD['NewTemperatureIsEnabled'] == 'ENABLED'
        and roomFD['NewTemperatureIsValid'] == 'VALID'):
        return roomFD['NewTemperatureCelsius'] * 0.1
    else:
        return 0
    
