#!/usr/bin/env python3

'''
 A Pyton module for interfacing with the Basys3 FPGA board

 Prepared for Indiana University's E210 Cyber-Physical Systems I class

 Andrew Lukefahr -  lukefahr@iu.edu
 20220225
'''

import spidev
import time
import numpy as np

class basysSpi:
    ''' Enables communication between the raspberry pi and the Basys3 FPGA board'''
    def __init__(self,spi_device=0, ce_pin=0, speed=1000000):

        """
        spi_device: there are two spi ports. It is most common to use port 0. 
        ce_pin: there are two CE pins that are automatically controlled by the pi. 
        speed: the speed for the spi clock is specified here. used to limit spi speed. 
        """
        self.spi = spidev.SpiDev()
        self.spi.open(spi_device, ce_pin)
        self.spi.max_speed_hz = speed   # Sets the maximum speed of the SPI link 
        self.spi.mode = 0b00            # SPI Mode 0 
        time.sleep(0.5)
        if self.get_device_id() == 0x07:
            print("found Basys")
        else:
            raise Exception ("Basys3 not found")

    def get_device_id(self):
        return(self.read_register(0x00))

    def read_register(self, address):
        address = address | 0x80                     # Set the read mode 
        read_bytes = self.spi.xfer2([address,0x00])  # Send the register address and a dummy byte to clock back data
        print (read_bytes)
        print (hex(read_bytes[1]))
        return (read_bytes[1])

    def write_register(self, address, data):
        self.spi.xfer2([address,data])
        return(0)

    def read_LEDs(self):
        low = self.read_register(0x3)
        high = self.read_register(0x4)

        data_raw = high << 8 | low
        data_int = np.int16(data_raw)
        converted_data = (data_int/512) * 2 
        return (converted_data)

    def write_LEDs(self, leds):
        self.write_register (0x3, leds & 0xff)
        self.write_register (0x4, (leds >> 8) & 0xff)


if  __name__ == "__main__":
    sensor = basysSpi()
    print ( sensor.read_LEDs() )
    sensor.write_LEDs(0xffff)
    print ( sensor.read_LEDs() )
    time.sleep(0.5)
    sensor.write_LEDs(0x0000)
    print ( sensor.read_LEDs() )
    
    
