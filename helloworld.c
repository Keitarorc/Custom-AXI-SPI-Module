/*
 * SPI controller test application for custom AXI SPI core
 *
 * Register map:
 *   0x00 FPGA_REV_REG
 *   0x04 SW_RST_REG
 *   0x08 SPI_CTRL_REG
 *   0x0C SPI_STATUS_REG
 *   0x10 SPI_TX_REG
 *   0x14 SPI_RX_REG
 *   0x18 SPI_CLK_DIV_REG
 */

#include <stdio.h>
#include <stdint.h>
#include "platform.h"
#include "xparameters.h"
#include "xil_printf.h"
#include "xil_io.h"

#define SPI_CTRL_BASE       0x43C00000U

#define FPGA_REV_REG        0x00U
#define SW_RST_REG          0x04U
#define SPI_CTRL_REG        0x08U
#define SPI_STATUS_REG      0x0CU
#define SPI_TX_REG          0x10U
#define SPI_RX_REG          0x14U
#define SPI_CLK_DIV_REG     0x18U

#define BIT0_MASK           0x00000001U
#define BIT1_MASK           0x00000002U

#define SPI_START_MASK      BIT0_MASK   /* SPI_CTRL_REG[0] */
#define SPI_EN_MASK         BIT1_MASK   /* SPI_CTRL_REG[1] */

#define SPI_BUSY_MASK       BIT0_MASK   /* SPI_STATUS_REG[0] */
#define SPI_DONE_MASK       BIT1_MASK   /* SPI_STATUS_REG[1] */

#define SPI_TIMEOUT_CYCLES  10000000U

static inline void SPI_WriteReg(uint32_t offset, uint32_t value)
{
    Xil_Out32(SPI_CTRL_BASE + offset, value);
}

static inline uint32_t SPI_ReadReg(uint32_t offset)
{
    return Xil_In32(SPI_CTRL_BASE + offset);
}

static void SPI_Enable(void)
{
    uint32_t val = SPI_ReadReg(SPI_CTRL_REG);
    val |= SPI_EN_MASK;
    SPI_WriteReg(SPI_CTRL_REG, val);
}

static void SPI_Disable(void)
{
    uint32_t val = SPI_ReadReg(SPI_CTRL_REG);
    val &= ~SPI_EN_MASK;
    SPI_WriteReg(SPI_CTRL_REG, val);
}

static void SPI_StartTransfer(void)
{
    uint32_t val = SPI_ReadReg(SPI_CTRL_REG);
    val |= SPI_START_MASK;
    SPI_WriteReg(SPI_CTRL_REG, val);
}

static void SPI_SoftwareReset(void)
{
    SPI_WriteReg(SW_RST_REG, 0x00000001U);
}

static void SPI_SetClkDiv(uint8_t div)
{
    SPI_WriteReg(SPI_CLK_DIV_REG, (uint32_t)div);
}

static uint8_t SPI_GetClkDiv(void)
{
    return (uint8_t)(SPI_ReadReg(SPI_CLK_DIV_REG) & 0xFFU);
}

static void SPI_WriteTxData(uint16_t data)
{
    SPI_WriteReg(SPI_TX_REG, (uint32_t)data);
}

static uint16_t SPI_ReadRxData(void)
{
    return (uint16_t)(SPI_ReadReg(SPI_RX_REG) & 0xFFFFU);
}

static uint32_t SPI_ReadStatus(void)
{
    return SPI_ReadReg(SPI_STATUS_REG);
}

static int SPI_IsBusy(void)
{
    return ((SPI_ReadStatus() & SPI_BUSY_MASK) != 0U);
}

static int SPI_IsDone(void)
{
    return ((SPI_ReadStatus() & SPI_DONE_MASK) != 0U);
}

static int SPI_WaitUntilBusy(uint32_t timeout_cycles)
{
    while (timeout_cycles--)
    {
        if (SPI_IsBusy())
        {
            return 0;
        }
    }
    return -1;
}

static int SPI_WaitWhileBusy(uint32_t timeout_cycles)
{
    while (timeout_cycles--)
    {
        if (!SPI_IsBusy())
        {
            return 0;
        }
    }
    return -1;
}

static int SPI_WaitDone(uint32_t timeout_cycles)
{
    while (timeout_cycles--)
    {
        if (SPI_IsDone())
        {
            return 0;
        }
    }
    return -1;
}

static int SPI_Transfer16(uint16_t tx_word, uint16_t *rx_word)
{
    SPI_WriteTxData(tx_word);
    SPI_StartTransfer();

    /* Optional: confirm transfer actually started */
    if (SPI_WaitUntilBusy(SPI_TIMEOUT_CYCLES) != 0)
    {
        xil_printf("WARNING: BUSY never asserted\r\n");
    }

    /* Main completion check */
    if (SPI_WaitWhileBusy(SPI_TIMEOUT_CYCLES) != 0)
    {
        xil_printf("ERROR: timeout waiting for BUSY to clear\r\n");
        return -1;
    }

    /* DONE is now latched in hardware, so this should be reliable */
    if (SPI_WaitDone(SPI_TIMEOUT_CYCLES) != 0)
    {
        xil_printf("WARNING: DONE bit not observed before timeout\r\n");
    }

    if (rx_word != NULL)
    {
        *rx_word = SPI_ReadRxData();
    }

    return 0;
}

static void PrintRegisters(void)
{
    xil_printf("[0x%02X] FPGA_REV_REG    = 0x%08X\r\n", FPGA_REV_REG,    SPI_ReadReg(FPGA_REV_REG));
    xil_printf("[0x%02X] SW_RST_REG      = 0x%08X\r\n", SW_RST_REG,      SPI_ReadReg(SW_RST_REG));
    xil_printf("[0x%02X] SPI_CTRL_REG    = 0x%08X\r\n", SPI_CTRL_REG,    SPI_ReadReg(SPI_CTRL_REG));
    xil_printf("[0x%02X] SPI_STATUS_REG  = 0x%08X\r\n", SPI_STATUS_REG,  SPI_ReadReg(SPI_STATUS_REG));
    xil_printf("[0x%02X] SPI_TX_REG      = 0x%08X\r\n", SPI_TX_REG,      SPI_ReadReg(SPI_TX_REG));
    xil_printf("[0x%02X] SPI_RX_REG      = 0x%08X\r\n", SPI_RX_REG,      SPI_ReadReg(SPI_RX_REG));
    xil_printf("[0x%02X] SPI_CLK_DIV_REG = 0x%08X\r\n", SPI_CLK_DIV_REG, SPI_ReadReg(SPI_CLK_DIV_REG));
    xil_printf("\r\n");
}

static void PrintMenu(void)
{
    xil_printf("SPI controller Menu\r\n");
    xil_printf("--------------------------------------------------\r\n");
    xil_printf("1. Perform a single PmodALS read\r\n");
    xil_printf("2. Enable the SPI controller\r\n");
    xil_printf("3. Disable the SPI controller\r\n");
    xil_printf("4. Read and print all registers\r\n");
    xil_printf("5. Enter new CLK_DIV value in hexadecimal\r\n");
    xil_printf("6. Perform 16 consecutive PmodALS reads\r\n");
    xil_printf("7. Run PmodALS sensor self-test\r\n");
    xil_printf("8. Run one SPI debug transfer\r\n");
    xil_printf("h. Display menu\r\n");
    xil_printf("r. Software reset\r\n");
    xil_printf("--------------------------------------------------\r\n\r\n");
}

static int HexCharToNibble(char c)
{
    if (c >= '0' && c <= '9') return c - '0';
    if (c >= 'a' && c <= 'f') return c - 'a' + 10;
    if (c >= 'A' && c <= 'F') return c - 'A' + 10;
    return -1;
}

static uint8_t ReadHexByteFromUart(void)
{
    char c;
    int nibble;
    int count = 0;
    uint8_t value = 0;

    while (count < 2)
    {
        c = inbyte();

        if (c == '\r' || c == '\n')
        {
            continue;
        }

        nibble = HexCharToNibble(c);
        if (nibble < 0)
        {
            xil_printf("\r\nInvalid hex digit: %c\r\n", c);
            xil_printf("Enter exactly 2 hex digits: 0x");
            value = 0;
            count = 0;
            continue;
        }

        xil_printf("%c", c);
        value = (uint8_t)((value << 4) | (uint8_t)nibble);
        count++;
    }

    do
    {
        c = inbyte();
    } while (c != '\r' && c != '\n');

    xil_printf("\r\n");
    return value;
}

/*
 * PmodALS frame decode
 * If values look shifted, change >>5 to >>4.
 */
static uint8_t PmodALS_ExtractSample(uint16_t rx_word)
{
    return (uint8_t)((rx_word >> 5) & 0xFFU);
}

static int PmodALS_ReadSampleDebug(uint8_t *sample, uint16_t *raw_word)
{
    uint16_t rx_word;

    if (SPI_Transfer16(0x0000U, &rx_word) != 0)
    {
        return -1;
    }

    if (raw_word != NULL)
    {
        *raw_word = rx_word;
    }

    if (sample != NULL)
    {
        *sample = PmodALS_ExtractSample(rx_word);
    }

    return 0;
}

static void PmodALS_SelfTest(void)
{
    uint8_t s1, s2, s3;
    uint16_t r1, r2, r3;

    xil_printf("PmodALS self-test\r\n");

    if (PmodALS_ReadSampleDebug(&s1, &r1) != 0 ||
        PmodALS_ReadSampleDebug(&s2, &r2) != 0 ||
        PmodALS_ReadSampleDebug(&s3, &r3) != 0)
    {
        xil_printf("ERROR: SPI transfer failed\r\n\r\n");
        return;
    }

    xil_printf("Sample 1: RAW = 0x%04X, ALS = %d (0x%02X)\r\n", r1, s1, s1);
    xil_printf("Sample 2: RAW = 0x%04X, ALS = %d (0x%02X)\r\n", r2, s2, s2);
    xil_printf("Sample 3: RAW = 0x%04X, ALS = %d (0x%02X)\r\n", r3, s3, s3);

    xil_printf("Communication looks plausible if these values change when you\r\n");
    xil_printf("cover the sensor and then shine light on it.\r\n\r\n");
}

static void SPI_DebugTransferOnce(void)
{
    uint16_t rx_word = 0;

    xil_printf("Before transfer:\r\n");
    xil_printf("  CTRL   = 0x%08X\r\n", SPI_ReadReg(SPI_CTRL_REG));
    xil_printf("  STATUS = 0x%08X\r\n", SPI_ReadReg(SPI_STATUS_REG));
    xil_printf("  TX     = 0x%08X\r\n", SPI_ReadReg(SPI_TX_REG));
    xil_printf("  RX     = 0x%08X\r\n", SPI_ReadReg(SPI_RX_REG));

    if (SPI_Transfer16(0x0000U, &rx_word) == 0)
    {
        xil_printf("After transfer:\r\n");
        xil_printf("  CTRL   = 0x%08X\r\n", SPI_ReadReg(SPI_CTRL_REG));
        xil_printf("  STATUS = 0x%08X\r\n", SPI_ReadReg(SPI_STATUS_REG));
        xil_printf("  TX     = 0x%08X\r\n", SPI_ReadReg(SPI_TX_REG));
        xil_printf("  RX     = 0x%08X\r\n", SPI_ReadReg(SPI_RX_REG));
        xil_printf("  RAW RX = 0x%04X\r\n\r\n", rx_word);
    }
    else
    {
        xil_printf("Transfer failed\r\n\r\n");
    }
}

int main(void)
{
    char cmd;
    uint16_t rx_word;
    int i;

    init_platform();

    xil_printf("Start of SPI controller test\r\n\r\n");
    xil_printf("Base Address: 0x%08X\r\n\r\n", SPI_CTRL_BASE);

    PrintRegisters();
    PrintMenu();

    while (1)
    {
        xil_printf("Enter command: ");

        do
        {
            cmd = inbyte();
        } while ((cmd == '\r') || (cmd == '\n'));

        xil_printf("%c\r\n", cmd);

        switch (cmd)
        {
            case '1':
            {
                uint8_t als_value;

                if (PmodALS_ReadSampleDebug(&als_value, &rx_word) == 0)
                {
                    xil_printf("Single read complete. RAW RX = 0x%04X, ALS = %d (0x%02X)\r\n\r\n",
                               rx_word, als_value, als_value);
                }
                else
                {
                    xil_printf("Single read failed\r\n\r\n");
                }
                break;
            }

            case '2':
            {
                SPI_Enable();
                xil_printf("SPI controller enabled\r\n\r\n");
                break;
            }

            case '3':
            {
                SPI_Disable();
                xil_printf("SPI controller disabled\r\n\r\n");
                break;
            }

            case '4':
            {
                PrintRegisters();
                break;
            }

            case '5':
            {
                uint8_t div;
                xil_printf("Enter CLK_DIV (2 hex digits): 0x");
                div = ReadHexByteFromUart();
                SPI_SetClkDiv(div);
                xil_printf("CLK_DIV set to 0x%02X\r\n\r\n", SPI_GetClkDiv());
                break;
            }

            case '6':
            {
                uint8_t als_value;

                xil_printf("Performing 16 consecutive PmodALS reads...\r\n");
                for (i = 0; i < 16; i++)
                {
                    if (PmodALS_ReadSampleDebug(&als_value, &rx_word) == 0)
                    {
                        xil_printf("[%02d] RAW = 0x%04X, ALS = %3d (0x%02X)\r\n",
                                   i, rx_word, als_value, als_value);
                    }
                    else
                    {
                        xil_printf("[%02d] Transfer failed\r\n", i);
                    }
                }
                xil_printf("\r\n");
                break;
            }

            case '7':
            {
                PmodALS_SelfTest();
                break;
            }

            case '8':
            {
                SPI_DebugTransferOnce();
                break;
            }

            case 'h':
            {
                PrintMenu();
                break;
            }

            case 'r':
            {
                SPI_SoftwareReset();
                xil_printf("Software reset issued\r\n\r\n");
                break;
            }

            default:
            {
                xil_printf("Invalid command.\r\n\r\n");
                break;
            }
        }
    }

    cleanup_platform();
    return 0;
}
