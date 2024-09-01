package Cosmac

import spinal.core._
import spinal.lib._
import spinal.lib.blackbox.lattice.ice40._

import Spinal1802._
import Spinal1861._
import MySpinalHardware._

class QuestControlLogic() extends Component{
    val io = new Bundle {
        val Keys = new Bundle {
            val R = in Bool()
            val G = in Bool()
            val S = in Bool()
            val W = in Bool()

            val M = in Bool()
            val P = in Bool()
            val I = in Bool()
            val L = in Bool()
        }
        val CPU = new Bundle {
            val TPA = in Bool()
            val TPB = in Bool()
            val SC1 = in Bool()
            val MWR = in Bool()
        }
        val ROMs_ = out Bool()
        val MW_ = out Bool()
        val WAIT_ = out Bool()
        val CLEAR_ = out Bool()
        val EF4_ = out Bool()
        val DMA_In_ = out Bool()
    }

    val Roms = Reg(Bool()) init(False)   
    val RamP = Reg(Bool()) init(False)   
    val Load = Reg(Bool()) init(False)   
    val I = Reg(Bool()) init(False)
    val Run = Reg(Bool()) init(False)
    val Step = Reg(Bool()) init(False)
    val Wait = Reg(Bool()) init(False)
    
    io.EF4_ := io.Keys.I
    when(io.Keys.I.rise()){
        I := True
    }elsewhen(Wait || io.CPU.SC1){
        I := Flase
    }

    when(io.Keys.L){
        Load := True
    }elsewhen(io.Keys.R){
        Load := False
    }

    when(io.Keys.P){
        RamP := True
    }elsewhen(io.Keys.R || io.Keys.W){
        RamP := False
    }

    when(io.Keys.P){
        Roms := True
    }elsewhen(io.Keys.R){
        Roms := False
    }

    when(io.Keys.G.rise()){
        Run := True
    } elsewhen(io.Keys.R){
        Run := False
    }
}    

//Hardware definition
class Quest(val divideBy: BigInt) extends Component {
    val io = new Bundle {
        val reset = in Bool()
        val video = out Bool()
        val sync = out Bool()
        val q = out Bool()

        val Start = in Bool()
        val Wait = in Bool()
        val rom = new Bundle {
            val addr = out Bits(9 bits)
            val data = in Bits(8 bits)
        }

        val ram = new Bundle {
            val addr = out Bits(13 bits)
            val din = in Bits(8 bits)
            val dout = out Bits(8 bits)
            val wr = out Bool()
        }

        val Pixie = new Bundle {
            val INT = out Bool()
            val DMAO = out Bool()
            val VSync = out Bool()
            val HSync = out Bool()
        }

        val CPU = new Bundle {
            val TPB = out Bool()
            val SC = out Bits(2 bit)
            val DataOut = out Bits(8 bits)
            val Addr16 = out Bits(16 bits)
        }
    }        

    val Cpu = new Spinal1802()
        Cpu.io.Wait_n := io.Wait
        Cpu.io.DMA_In_n := True
        io.CPU.TPB := Cpu.io.TPB
        io.CPU.SC := Cpu.io.SC
        io.CPU.DataOut := Cpu.io.DataOut
        io.CPU.Addr16 := Cpu.io.Addr16

    val Pixie = new Spinal1861(divideBy)
        //Connection to Pixie
        Pixie.io.DataIn := Cpu.io.DataOut
        Pixie.io.SC := Cpu.io.SC
        Pixie.io.TPA := Cpu.io.TPA
        Pixie.io.TPB := Cpu.io.TPB
        Pixie.io.Disp_On := (Cpu.io.N === 1 && Cpu.io.TPB && !Cpu.io.MWR)
        Pixie.io.Disp_Off := (Cpu.io.N === 1 && Cpu.io.TPB && !Cpu.io.MRD)
        Pixie.io.Reset_ := io.reset

        io.Pixie.VSync := Pixie.io.VSync
        io.Pixie.HSync := Pixie.io.HSync
        io.Pixie.INT := Pixie.io.INT
        io.Pixie.DMAO := Pixie.io.DMAO
        
    //Connection to CPU from Pixie
    Cpu.io.Interrupt_n := Pixie.io.INT
    Cpu.io.DMA_Out_n := Pixie.io.DMAO
    Cpu.io.Clear_n := Pixie.io.Clear
    
    io.rom.addr := Cpu.io.Addr16(8 downto 0)
    
    io.ram.wr := !Cpu.io.MWR
    io.ram.dout := Cpu.io.DataOut
    io.ram.addr := Cpu.io.Addr16(12 downto 0)

    val romBootLatch = Reg(Bool) init (False)
        //When reset, clear the latch so system boots from ROM. 
        when(!Pixie.io.Clear) {
            romBootLatch := False
        //The ROM contains the monitor program which uses a 64h instruction to pulse the N2 line.
        } elsewhen (Cpu.io.N === 4) {
            romBootLatch := True
        }

        when(!romBootLatch || Cpu.io.Addr16.asUInt >= 0x8000 && Cpu.io.Addr16.asUInt <= 0x81ff) {
            Cpu.io.DataIn := io.rom.data
        }elsewhen(Cpu.io.Addr16.asUInt < 0x2000) {
            Cpu.io.DataIn := io.ram.din
        }otherwise{
            Cpu.io.DataIn := 0x00
        }

    val keypad = new Keypad()
        keypad.io.LatchKey := (Cpu.io.N === 2 && Cpu.io.TPB && !Cpu.io.MRD)
        keypad.io.Key := Cpu.io.DataOut(3 downto 0)
        io.keypad.row := ~keypad.io.KeypadRow
        keypad.io.KeypadCol := io.keypad.col

    Cpu.io.EF_n := Cat(B"1", keypad.io.KeyOut, B"1", Pixie.io.EFx)

    //Good beeper sounds
    val beeper = CounterFreeRun(1000)
    io.sync := Pixie.io.CompSync_
    io.video := Pixie.io.Video

    io.q := !(Cpu.io.Q & beeper < 100)
}