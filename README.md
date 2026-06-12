# Custom-AXI-SPI-Module

Built a complete hardware/software system by integrating a verified SPI Master module into a custom AXI-Lite peripheral IP. The IP is be packaged in Vivado and connected to the Zynq Processing System (PS) using an AXI interconnect. The SPI signals are routed through the FPGA to a Digital PMOD ALS (ambient light sensor), which uses a Texas Instruments ADC081S021 8-bit SPI ADC.
Using the Vitis IDE I develop a C software application that configures my SPI Controller IP through memory-mapped registers. This software can read the ambient light data from the PMOD ALS and present an interactive menu in the serial terminal.
 
<img width="1538" height="688" alt="image" src="https://github.com/user-attachments/assets/1015098c-77d6-4a9e-86d9-59c49189eeff" />
