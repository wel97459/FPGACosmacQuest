package Cosmac

import spinal.core._
import spinal.lib._
import spinal.lib.blackbox.lattice.ice40._

import Spinal1802._
import Spinal1861._
import TFT_Driver._
import MySpinalHardware._


//Hardware definition
class Top_Quest_ICE40(val withLcd: Boolean, val ramFile: String, val romFile: String) extends Component {
    val io = new Bundle {
        val reset_ = in Bool()
        val clk_12Mhz = in Bool() //12Mhz CLK
        //val video = out Bool()
        //val sync = out Bool()

        val serial_txd = out Bool()
        val serial_rxd = in Bool()

        val led_red = out Bool()
        val keypad = new Bundle {
            val col = in Bits(6 bits)
            val row = out Bits(4 bits)
        }

        // val lcd = new Bundle {
        //     val sck = ifGen(withLcd) (out Bool())
        //     val rst = ifGen(withLcd) (out Bool())
        //     val dc = ifGen(withLcd) (out Bool())
        //     val sdo = ifGen(withLcd) (out Bool())
        // }

        val seven = new Bundle {
            val seg = out Bits(7 bits)
            val dis = out Bits(6 bits)
        }

    }
    noIoPrefix()
    
    //Define clock domains
    val clk48Domain = ClockDomain.internal(name = "Core48",  frequency = FixedFrequency(48 MHz))
    val clk17Domain = ClockDomain.internal(name = "Core17",  frequency = FixedFrequency(17.625 MHz))
    val clk12Domain = ClockDomain.internal(name = "Core12",  frequency = FixedFrequency(12 MHz))

    val Core12 = new ClockingArea(clk12Domain) {
        var reset = Reg(Bool) init (False)
        var rstCounter = CounterFreeRun(255)
        when(rstCounter.willOverflow){
            reset := True
        }
    }

    //Allow clock domain crossing.
    clk48Domain.setSyncronousWith(clk17Domain)

    //PLL Settings for 17.625MHz
    val PLL_CONFIG = SB_PLL40_PAD_CONFIG(
        DIVR = B"0000", DIVF = B"0101110", DIVQ = B"101", FILTER_RANGE = B"001",
        FEEDBACK_PATH = "SIMPLE", PLLOUT_SELECT = "GENCLK", 
        DELAY_ADJUSTMENT_MODE_FEEDBACK = "FIXED", DELAY_ADJUSTMENT_MODE_RELATIVE = "FIXED", //NO DELAY
        FDA_FEEDBACK = B"0000", FDA_RELATIVE = B"0000", SHIFTREG_DIV_MODE = B"0", ENABLE_ICEGATE = False //NOT USED
    ) 

    //Define PLL
    val PLL = new SB_PLL40_CORE(PLL_CONFIG)
    //Setup signals of PLL
    PLL.BYPASS := False
    PLL.RESETB := True
    PLL.REFERENCECLK := io.clk_12Mhz

    //Define the internal oscillator
    val intOSC = new IntOSC()
    intOSC.io.CLKHFEN := True
    intOSC.io.CLKHFPU := True
    
    //Connect the PLL output of 12Mhz to the 12MHz clock domain
    clk12Domain.clock := io.clk_12Mhz
    clk12Domain.reset := !io.reset_

    //Connect the PLL output of 17.625Mhz to the 17.625MHz clock domain
    clk17Domain.clock := PLL.PLLOUTGLOBAL
    clk17Domain.reset := !Core12.reset

    //Connect the internal oscillator output to the 48MHz clock domain
    clk48Domain.clock := intOSC.io.CLKHF
    clk48Domain.reset := !Core12.reset

    val Core17 = new ClockingArea(clk17Domain) {

        val pro = new ProgrammingInterface(57600)
        io.serial_txd := pro.io.UartTX
        pro.io.UartRX := io.serial_rxd
        pro.io.FlagIn := 0x00
        val keyReady = False
        pro.io.keys.ready := keyReady.fall()

        val keyScanner = new KeypadScanner(6, 4, 1000)
        io.keypad.row := ~keyScanner.io.KeypadRow
        keyScanner.io.KeypadCol := ~io.keypad.col

        val keyDecoder = new KeypadHexDecoder()
        keyDecoder.io.KeysIn :=
            keyScanner.io.KeysOut(3) ## //f
            keyScanner.io.KeysOut(9) ## //e
            keyScanner.io.KeysOut(15) ## //d
            keyScanner.io.KeysOut(21) ## //c
            keyScanner.io.KeysOut(2) ## //b
            keyScanner.io.KeysOut(0) ## //a
            keyScanner.io.KeysOut(8 downto 6) ## 
            keyScanner.io.KeysOut(14 downto 12) ## 
            keyScanner.io.KeysOut(20 downto 18) ## 
            keyScanner.io.KeysOut(1)
        
        val seg7 = SevenSegmentDriver(5, 500 us)
        io.seven.seg := seg7.segments(6 downto 0) 
        io.seven.dis := seg7.displays(5 downto 0)
        seg7.setDecPoint(0);

        val Ram = new RamInit(ramFile, log2Up(0x1fff))
            Ram.io.ena := True

        //Dived the 17.625Mhz by 10 = 1.7625Mhz
        val areaDiv = new SlowArea(10) {
            var questElf = new Quest(10)
                questElf.io.Clear_ := !pro.io.FlagOut(0)
                questElf.io.Wait_ := !pro.io.FlagOut(1)
                questElf.io.ModeCon := pro.io.FlagOut(2)
                questElf.io.ram.din := Ram.io.douta

                questElf.io.Keys.W := keyScanner.io.KeysOut(4)
                questElf.io.Keys.I := keyScanner.io.KeysOut(5)
                questElf.io.Keys.G := keyScanner.io.KeysOut(10)
                questElf.io.Keys.P := keyScanner.io.KeysOut(11)
                questElf.io.Keys.R := keyScanner.io.KeysOut(16)
                questElf.io.Keys.S := keyScanner.io.KeysOut(17)
                questElf.io.Keys.L := keyScanner.io.KeysOut(22)
                questElf.io.Keys.M := keyScanner.io.KeysOut(23)
                questElf.io.DI := keyDecoder.io.HexOutLast ## keyDecoder.io.HexOut

            val Rom = new RamInit(romFile, log2Up(0x3ff))
                Rom.io.ena := True
                Rom.io.wea := 0
                Rom.io.dina := 0x00
                Rom.io.addra := questElf.io.rom.addr
                questElf.io.rom.data := Rom.io.douta

            val Ram255 = new Ram(8) // 255 ram
                Ram255.io.wea := questElf.io.ram255.wr
                Ram255.io.ena := True
                Ram255.io.addra := questElf.io.ram255.addr
                questElf.io.ram255.din := Ram255.io.douta
                Ram255.io.dina := questElf.io.ram255.dout
            //io.sync := questElf.io.sync
            //io.video := questElf.io.video
            io.led_red := questElf.io.q
        }

        val segData = B"00000000"
        val segAddr = B"0000000000000000"
        val segDataReg = RegNextWhen(pro.io.RamInterface.DataOut, pro.io.RamInterface.Write)
        val segDataBus = RegNextWhen(areaDiv.questElf.io.CPU.DataOut, areaDiv.questElf.io.DE)

        seg7.setDigits(0, segData);
        seg7.setDigits(2, segAddr(7 downto 0));
        seg7.setDigits(4, segAddr(15 downto 8));

        pro.io.RamInterface.DataIn := Ram.io.douta
        when(pro.io.FlagOut(2))
        {
            Ram.io.dina := pro.io.RamInterface.DataOut
            Ram.io.wea := pro.io.RamInterface.Write.asBits
            Ram.io.addra := pro.io.RamInterface.Address.resized
            segData := segDataReg
            segAddr := pro.io.RamInterface.Address
        }otherwise{
            Ram.io.dina := areaDiv.questElf.io.ram.dout
            Ram.io.wea := areaDiv.questElf.io.ram.wr.asBits
            Ram.io.addra := areaDiv.questElf.io.ram.addr
            segData := segDataBus
            segAddr := areaDiv.questElf.io.CPU.Addr16
        }

        // val lcd = ifGen(withLcd) (new Area(){  
        //     val startFrame = !areaDiv.questElf.io.Pixie.INT
        //     val startLine = !areaDiv.questElf.io.Pixie.DMAO
        //     val dataClk = (areaDiv.questElf.io.CPU.TPB && areaDiv.questElf.io.CPU.SC === 2)
        //     val data = areaDiv.questElf.io.CPU.DataOut
        // })
    }

    val lcd = ifGen(withLcd) (new Area(){    
        // val Core48 = new ClockingArea(clk48Domain) {
            
        //     //Clock Crossing
        //     val startFrame = BufferCC(Core17.lcd.startFrame, False)
        //     val startLine = BufferCC(Core17.lcd.startLine, False)
        //     val dataClkB = BufferCC(Core17.lcd.dataClk, False)
        //     val dataClk = dataClkB.fall()
        //     val dataClkD = RegNext(dataClk)
        //     val data = RegNextWhen(Core17.lcd.data, dataClk) init(0)
            
        //     var LCD = LCD_Pixie(10 ms)
        //     LCD.io.startFrame := startFrame
        //     LCD.io.startLine := startLine
        //     LCD.io.dataClk := dataClkD
        //     LCD.io.data := data
            
        //     io.lcd <> LCD.io.lcd
        // }
    })
}

object Top_Quest_ICE40_Verilog extends App {
  Config.spinal.generateVerilog(new Top_Quest_ICE40(false, "./data/test_1861.bin", "./data/SUPRMON-v1.1-2708.bin"))
}