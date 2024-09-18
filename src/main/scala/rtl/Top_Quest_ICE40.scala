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
        val video = out Bool()
        val sync = out Bool()

        val serial_txd = out Bool()
        val serial_rxd = in Bool()

        val led_red = out Bool()
        val led_green = out Bool()
        val led_blue = out Bool()

        val tape = new Bundle {
            val input = in Bool()
            val output = out Bool()
        }

        val keypad = new Bundle {
            val col = in Bits(6 bits)
            val row = out Bits(4 bits)
        }

        val lcd = new Bundle {
            val sck = ifGen(withLcd) (out Bool())
            val rst = ifGen(withLcd) (out Bool())
            val dc = ifGen(withLcd) (out Bool())
            val sdo = ifGen(withLcd) (out Bool())
        }

        val seven = new Bundle {
            val seg = out Bits(7 bits)
            val dis = out Bits(4 bits)
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

        val glow = new LedGlow(23)
        val pro = new ProgrammingInterface(57600)
        pro.io.FlagIn := 0x00

        val keyScanner = new KeypadScanner(6, 4, 1000)
        io.keypad.row := ~keyScanner.io.KeypadRow
        keyScanner.io.KeypadCol := ~io.keypad.col

        val debounce = Debounce(24, 10 ms)
        debounce.write(keyScanner.io.KeysOut)

        val keyDecoder = new KeypadHexDecoder()
        keyDecoder.io.KeysIn :=
            debounce(3) ## //f
            debounce(9) ## //e
            debounce(15) ## //d
            debounce(21) ## //c
            debounce(2) ## //b
            debounce(0) ## //a
            debounce(8 downto 6) ## 
            debounce(14 downto 12) ## 
            debounce(20 downto 18) ## 
            debounce(1)
        
        val seg7 = SevenSegmentDriver(3, 500 us)
        io.seven.seg := seg7.segments(6 downto 0) 
        io.seven.dis := seg7.displays
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

                questElf.io.Keys.W := debounce(4)
                questElf.io.Keys.I := debounce(5)
                questElf.io.Keys.G := debounce(10)
                questElf.io.Keys.P := debounce(11)
                questElf.io.Keys.R := debounce(16)
                questElf.io.Keys.S := debounce(17)
                questElf.io.Keys.L := debounce(22)
                questElf.io.Keys.M := debounce(23)

                questElf.io.KeyHeld_ := !pro.io.keys.valid
                questElf.io.DI := keyDecoder.io.HexOutLast ## keyDecoder.io.HexOut
                
                questElf.io.Parallel := pro.io.keys.payload

            val Rom = new RamInit(romFile, log2Up(0x3ff))
                Rom.io.ena := True
                Rom.io.wea := 0
                Rom.io.dina := 0x00
                Rom.io.addra := questElf.io.rom.addr
                questElf.io.rom.din := Rom.io.douta

            val Ram255 = new Ram(8) // 255 ram
                Ram255.io.wea := questElf.io.ram255.wr
                Ram255.io.ena := True
                Ram255.io.addra := questElf.io.ram255.addr
                questElf.io.ram255.din := Ram255.io.douta
                Ram255.io.dina := questElf.io.ram255.dout
            io.sync := questElf.io.sync
            io.video := questElf.io.video
            io.led_red := !questElf.io.q 
            io.tape.output := questElf.io.q

            questElf.io.TapeIn := True
        }

        pro.io.keys.ready := areaDiv.questElf.io.ParallelN.fall()
        
        val segData = B"00000000"
        val segAddr = B"00000000"
        val segDataReg = RegNextWhen(pro.io.RamInterface.DataOut, pro.io.RamInterface.Write)
        val segDataBus = RegNextWhen(areaDiv.questElf.io.CPU.DataOut, areaDiv.questElf.io.DE)

        seg7.setDigits(0, segData);
        seg7.setDigits(2, pro.io.keys.payload);

        pro.io.RamInterface.DataIn := Ram.io.douta
        when(pro.io.FlagOut(2))
        {
            Ram.io.dina := pro.io.RamInterface.DataOut
            Ram.io.wea := pro.io.RamInterface.Write.asBits
            Ram.io.addra := pro.io.RamInterface.Address.resized
            segData := segDataReg
            segAddr := pro.io.RamInterface.Address.resized
            io.led_blue := !glow.io.led 
        }otherwise{
            Ram.io.dina := areaDiv.questElf.io.ram.dout
            Ram.io.wea := areaDiv.questElf.io.ram.wr.asBits
            Ram.io.addra := areaDiv.questElf.io.ram.addr
            segData := segDataBus
            segAddr := areaDiv.questElf.io.CPU.Addr16.resized
            io.led_blue := True
        }

        when(pro.io.FlagOut(7)){
            io.serial_txd :=  pro.io.FlagOut(6) ? !areaDiv.questElf.io.q | areaDiv.questElf.io.q
            areaDiv.questElf.io.SerialIn := pro.io.FlagOut(5) ? !io.serial_rxd | io.serial_rxd
            pro.io.UartRX := False
            io.led_green := !(!io.serial_rxd && glow.io.led)
        }otherwise{
            areaDiv.questElf.io.SerialIn := True
            io.serial_txd := pro.io.UartTX
            pro.io.UartRX := io.serial_rxd
            io.led_green := True
        }
        
        val lcd = ifGen(withLcd) (new Area(){
            val startFrame = !areaDiv.questElf.io.Pixie.INT
            val startLine = !areaDiv.questElf.io.Pixie.DMAO
            val dataClk = (areaDiv.questElf.io.CPU.TPB && areaDiv.questElf.io.CPU.SC === 2)
            val data = areaDiv.questElf.io.CPU.DataOut
        })
    }

    val lcd = ifGen(withLcd) (new Area(){ 
        val Core48 = new ClockingArea(clk48Domain) {
            //Clock Crossing
            val startFrame = BufferCC(Core17.lcd.startFrame, False)
            val startLine = BufferCC(Core17.lcd.startLine, False)
            val dataClk = BufferCC(Core17.lcd.dataClk, False)
            val dataClkB = dataClk.fall()
            val dataClkC = RegNext(dataClkB)
            val data = RegNextWhen(Core17.lcd.data, dataClkB) init(0)
            
            var LCD = LCD_Pixie(10 ms)
            LCD.io.startFrame := startFrame
            LCD.io.startLine := startLine
            LCD.io.dataClk := dataClkC
            LCD.io.data := data
            
            io.lcd <> LCD.io.lcd
        }
    })
}

object Top_Quest_ICE40_Verilog extends App {
  Config.spinal.generateVerilog(new Top_Quest_ICE40(true, "./data/test_1861.bin", "./data/SUPRMON-v1.1-2708.bin"))
}