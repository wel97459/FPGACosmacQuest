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

    val LoadN2 = Load || io.CPU.N === 2
    val GRise = io.Keys.G.rise()

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

    when(io.Keys.M){
        Roms := True
    }elsewhen(io.Keys.R){
        Roms := False
    }

    when(GRise){
        Run := True
    } elsewhen(io.Keys.R){
        Run := False
    }

    when(!Run){
        Run1 := True
    } elsewhen(!Run2) {
        Run1 := False
    } elsewhen((io.CPU.TPB || !GRise).rise()){
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
    io.WAIT_ := !(!(!Run2 || !Step) || Wait || Load)

    io.DE := !((!io.CPU.MRD && io.CPU.TPB && LoadN2) && Step)
    io.IE := io.CPU.MRD && LoadN2 

    io.Debug.regs := Cat(io.WAIT_, io.CLEAR_, Roms,    RamP, Load, I, Run,   Run1, Run2, Step, Wait)
}    

//Hardware definition
class Quest(val divideBy: BigInt) extends Component {
    val io = new Bundle {
        val reset = in Bool()
        val Start = in Bool()
        val Wait = in Bool()

        val video = out Bool()
        val sync = out Bool()
        val q = out Bool()
        val DE = out Bool()
        val DI = in Bits(8 bits)

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
        Cpu.io.Wait_n := !(!io.Wait || !QLogic.io.WAIT_)
        Cpu.io.Clear_n := !(io.reset || !QLogic.io.CLEAR_)
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

    val Pixie = new Spinal1861(divideBy)
        //Connection to Pixie
        Pixie.io.DataIn := Cpu.io.DataOut
        Pixie.io.SC := Cpu.io.SC
        Pixie.io.TPA := Cpu.io.TPA
        Pixie.io.TPB := Cpu.io.TPB
        Pixie.io.Disp_On := (Cpu.io.N === 0 && Cpu.io.TPB && !Cpu.io.MWR)
        Pixie.io.Disp_Off := (Cpu.io.N === 1 && Cpu.io.TPB && !Cpu.io.MRD)
        Pixie.io.Reset_ := io.reset && QLogic.io.CLEAR_

        io.Pixie.VSync := Pixie.io.VSync
        io.Pixie.HSync := Pixie.io.HSync
        io.Pixie.INT := Pixie.io.INT
        io.Pixie.DMAO := Pixie.io.DMAO
        
    //Connection to CPU from Pixie
    Cpu.io.Interrupt_n := Pixie.io.INT
    Cpu.io.DMA_Out_n := Pixie.io.DMAO
    
    io.rom.addr := Cpu.io.Addr16(8 downto 0)
    
    io.ram.wr := !QLogic.io.MW_
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
        when(QLogic.io.IE){
            Cpu.io.DataIn := io.DI
        }elsewhen(!romBootLatch || Cpu.io.Addr16.asUInt >= 0x8000 && Cpu.io.Addr16.asUInt <= 0x81ff) {
            Cpu.io.DataIn := io.rom.data
        }elsewhen(Cpu.io.Addr16.asUInt < 0x2000) {
            Cpu.io.DataIn := io.ram.din
        }otherwise{
            Cpu.io.DataIn := 0x00
        }

    Cpu.io.EF_n := Cat(QLogic.io.EF4_,  B"1", B"1", Pixie.io.EFx)

    //Good beeper sounds
    val beeper = CounterFreeRun(1000)
    io.sync := Pixie.io.CompSync_
    io.video := Pixie.io.Video

    io.q := !(Cpu.io.Q & beeper < 100)
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

            dut.io.reset #= false
            dut.io.Wait #= true
            dut.clockDomain.waitRisingEdge()
            var c = 0;

            val loop = new Breaks;
            loop.breakable {
                while (true) {
                    if(c < 20){
                        dut.io.Keys.R #= true
                    }else if(c>=20 && c < 30) {
                        dut.io.Keys.S #= true
                        dut.io.Keys.R #= false
                    }else if(c>=30 && (c % 20) == 0) {
                        dut.io.Keys.S #= false
                        dut.io.Keys.G #= true
                    }else{
                        dut.io.Keys.G #= false
                    }

                    c+=1
                    if(c == 500) loop.break()
                    dut.clockDomain.waitRisingEdge()
                }
            }
        }
    }
}