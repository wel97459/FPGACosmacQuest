package Cosmac

import spinal.core._
import spinal.lib._
import spinal.lib.blackbox.lattice.ice40._
import spinal.core.sim._

import Spinal1802._
import Spinal1861._
import MySpinalHardware._
import scala.util.control.Breaks


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
            val MRD = in Bool()
            val N = in Bits(3 bits)
            val A15 = in Bool() //mod for running supermon
        }

        val ROMs_ = out Bool()
        val MW_ = out Bool()
        val WAIT_ = out Bool()
        val CLEAR_ = out Bool()
        val EF4_ = out Bool()
        val DMA_In_ = out Bool()
        val DE = out Bool()
        val IE = out Bool()

        val Debug = new Bundle {
            val regs = out Bits(11 bits)
        }
    }

    val Roms = Reg(Bool()) init(False)   
    val RamP = Reg(Bool()) init(False)   
    val Load = Reg(Bool()) init(False)   
    val I = Reg(Bool()) init(False)
    val Run = Reg(Bool()) init(False)
    val Run1 = Reg(Bool()) init(False)
    val Run2 = Reg(Bool()) init(False)
    val Step = Reg(Bool()) init(False)
    val Wait = Reg(Bool()) init(False)
    val N4 = io.CPU.N === 4
    val LoadN4 = Load || N4
    val GRise = io.Keys.G.rise() || io.Keys.M.fall()

    val RomTimer = new Timeout(200)

    when(io.WAIT_ || io.CPU.SC1){
        I := False
    }elsewhen((io.Keys.I).rise()){
        I := True
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

    when(io.Keys.M.fall()){
        Roms := True
        RomTimer.clear()
    }elsewhen(io.Keys.R || RomTimer){
        Roms := False
    }

    when(GRise){
        Run := True
    } elsewhen(io.Keys.R){
        Run := False
    }

    // when(!Run && !Run2){
    //     Run1 := True
    // } else
    when(!Run) {
        Run1 := True
    } elsewhen(!Run2) {
        Run1 := False
    } elsewhen((io.CPU.TPB || io.Keys.G.fall()).rise()){
        Run1 := True
    }

    when(Run1) {
        Run2 := False
    } elsewhen((!io.CPU.TPA).rise()){
        Run2 := True
    }    
    
    when(io.Keys.W){
        Wait := True
    }elsewhen(io.Keys.R || io.Keys.G){
        Wait := False
    }

    when(io.Keys.S){
        Step := True
    }elsewhen(io.Keys.R || io.Keys.W){
        Step := False
    }

    io.EF4_ := !io.Keys.I
    io.ROMs_ := !Roms
    io.MW_ := io.CPU.MWR || RamP
    io.DMA_In_ := !I

    io.CLEAR_ := !(!Run || Load)

    val w1 = Step && Run2
    val w2 = w1 || Wait 
    io.WAIT_ := !(Load || w2)

    val d1 = !io.CPU.MRD && !io.CPU.TPB && N4
    io.DE := d1 || Step || Load
    
    io.IE := io.CPU.MRD && LoadN4 && !RamP

    io.Debug.regs := Cat(io.WAIT_, io.CLEAR_, Roms,    RamP, Load, I, Run,   Run1, Run2, Step, Wait)
}    

//Hardware definition
class Quest(val divideBy: BigInt) extends Component {
    val io = new Bundle {
        val Clear_ = in Bool()
        val Wait_ = in Bool()
        val ModeCon = in Bool() 
        val video = out Bool()
        val sync = out Bool()
        val q = out Bool()
        val DE = out Bool()
        val DI = in Bits(8 bits)

        val SerialIn = in Bool()
        val TapeIn = in Bool()

        val rom = new Bundle {
            val addr = out Bits(10 bits)
            val din = in Bits(8 bits)
        }

        val ram = new Bundle {
            val addr = out Bits(13 bits)
            val din = in Bits(8 bits)
            val dout = out Bits(8 bits)
            val wr = out Bool()
        }

        val ram255 = new Bundle {
            val addr = out Bits(8 bits)
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

        val Debug = new Bundle {
            val regs = out Bits(11 bits)
        }
    }        

    val QLogic = new QuestControlLogic()
        QLogic.io.Keys <> io.Keys
        io.Debug <> QLogic.io.Debug
        io.DE := QLogic.io.DE

    val Cpu = new Spinal1802()
        Cpu.io.Wait_n := io.ModeCon ? io.Wait_ | QLogic.io.WAIT_
        Cpu.io.Clear_n := io.ModeCon ? io.Clear_ | QLogic.io.CLEAR_ 
        Cpu.io.DMA_In_n := QLogic.io.DMA_In_
        io.CPU.TPB := Cpu.io.TPB
        io.CPU.SC := Cpu.io.SC
        io.CPU.DataOut := Cpu.io.DataOut
        io.CPU.Addr16 := Cpu.io.Addr16

        QLogic.io.CPU.TPA := Cpu.io.TPA
        QLogic.io.CPU.TPB := Cpu.io.TPB
        QLogic.io.CPU.SC1 := Cpu.io.SC(1)
        QLogic.io.CPU.MWR := Cpu.io.MWR
        QLogic.io.CPU.MRD := Cpu.io.MRD
        QLogic.io.CPU.N := Cpu.io.N
        QLogic.io.CPU.A15 := Cpu.io.Addr16(15) && Cpu.io.MRD

    val Pixie = new Spinal1861(divideBy)
        //Connection to Pixie
        Pixie.io.DataIn := Cpu.io.DataOut
        Pixie.io.SC := Cpu.io.SC
        Pixie.io.TPA := Cpu.io.TPA
        Pixie.io.TPB := Cpu.io.TPB
        Pixie.io.Disp_On := (Cpu.io.N === 1 && Cpu.io.TPB && !Cpu.io.MRD)
        Pixie.io.Disp_Off := (Cpu.io.N === 2 && Cpu.io.TPB && !Cpu.io.MRD)
        Pixie.io.Reset_ := QLogic.io.CLEAR_

        io.Pixie.VSync := Pixie.io.VSync
        io.Pixie.HSync := Pixie.io.HSync
        io.Pixie.INT := Pixie.io.INT
        io.Pixie.DMAO := Pixie.io.DMAO
        
    //Connection to CPU from Pixie
    Cpu.io.Interrupt_n := Pixie.io.INT
    Cpu.io.DMA_Out_n := Pixie.io.DMAO
    
    val ramSel = Cpu.io.Addr16.asUInt < 0x2000
    val romSel = (Cpu.io.Addr16.asUInt >= 0x8000 && Cpu.io.Addr16.asUInt <= 0x8fff)
    val ram255Sel = (Cpu.io.Addr16.asUInt >= 0x9800 && Cpu.io.Addr16.asUInt <= 0x98ff)

    io.rom.addr := Cpu.io.Addr16(9 downto 0)
    
    io.ram.wr := !QLogic.io.MW_ && ramSel
    io.ram.dout := Cpu.io.DataOut
    io.ram.addr := Cpu.io.Addr16(12 downto 0)

    io.ram255.wr := !QLogic.io.MW_ && ram255Sel
    io.ram255.dout := Cpu.io.DataOut
    io.ram255.addr := Cpu.io.Addr16(7 downto 0)

    when(QLogic.io.IE){
        Cpu.io.DataIn := io.DI
    }elsewhen(!QLogic.io.ROMs_ || romSel) {
        Cpu.io.DataIn := io.rom.din
    }elsewhen(ram255Sel) {
        Cpu.io.DataIn := io.ram255.din
    }elsewhen(ramSel) {
        Cpu.io.DataIn := io.ram.din
    }otherwise{
        Cpu.io.DataIn := 0x00
    }

    Cpu.io.EF_n := Cat(QLogic.io.EF4_,  io.TapeIn, io.SerialIn, Pixie.io.EFx)

    //Good beeper sounds
    io.sync := Pixie.io.CompSync_
    io.video := Pixie.io.Video

    io.q := Cpu.io.Q
}

object Quest_Test {
    def main(args: Array[String]) {
        SimConfig.withFstWave.compile{
            val dut = new Quest(1)
            dut
        }.doSim { dut =>
            //Fork a process to generate the reset and the clock on the dut
            dut.clockDomain.forkStimulus(period = 10)
            dut.io.Keys.I #= false
            dut.io.Keys.S #= false
            dut.io.Keys.W #= false
            dut.io.Keys.G #= false
            dut.io.Keys.M #= false
            dut.io.Keys.L #= false
            dut.io.Keys.P #= false
            dut.io.Keys.R #= true 

            dut.io.Clear_ #= false
            dut.io.Wait_ #= true
            dut.io.ModeCon #= false
            dut.clockDomain.waitRisingEdge()
            var c = 0;

            var ram255 = new Memory(0xff)
            var ram = new Memory(0x1ffff)
            var rom = new Memory(0x3ff)
            rom.loadBin(0x000, "./data/SUPRMON-v1.1-2708.bin")
            ram.loadBin(0x000, "./data/counter.bin")
            
            val loop = new Breaks;
            loop.breakable {
                while (true) {
                    dut.io.ram.din #= ram.read(dut.io.ram.addr.toInt)
                    dut.io.ram255.din #= ram255.read(dut.io.ram255.addr.toInt)
                    dut.io.rom.din #= rom.read(dut.io.rom.addr.toInt)
                    
                    if(dut.io.ram.wr.toBoolean)
                        ram.write(dut.io.ram.addr.toInt, dut.io.ram.dout.toInt)

                    if(dut.io.ram255.wr.toBoolean)
                        ram255.write(dut.io.ram255.addr.toInt, dut.io.ram255.dout.toInt)

                    if(c < 20){
                        dut.io.Keys.R #= true
                    }else if(c >= 20 && c < 30) {
                        dut.io.Keys.R #= false
                        dut.io.Keys.G #= true
                    // }else if(c >= 30 && c < 40) {
                    //     dut.io.Keys.G #= false
                    // }else if(c >= 440 && c < 450) {
                    //     dut.io.Keys.I #= true
                    // }else if(c >= 435 && c < 460) {
                    //     dut.io.Keys.I #= false
                    } else {
                        dut.io.Keys.G #= false
                    }

                    c+=1
                    if(c == 20000) loop.break()
                    dut.clockDomain.waitRisingEdge()
                }
            }
        }
    }
}