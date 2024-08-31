# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, FallingEdge, RisingEdge, Timer


async def do_start(dut, fast_start = 0):
    dut._log.info("Start")

    # 36MHz clock
    clock = Clock(dut.clk, 27.778, units="ns")
    cocotb.start_soon(clock.start())

    dut.ena.value = 1
    dut.ui_in.value = fast_start
    dut.uio_in.value = 0
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 2)

    # Reset
    dut._log.info("Reset")
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 2)

    dut.rst_n.value = 1

    assert dut.uio_oe.value == 0b10000000


@cocotb.test()
async def test_audio(dut):
    await do_start(dut, 1)

    await Timer(1000, "us")

@cocotb.test()
async def test_sync(dut):
    await do_start(dut)

    dut._log.info("Test sync")

    await ClockCycles(dut.clk, 1)

    for i in range(25):
        vsync = 1 if i in (1, 2) else 0
        for j in range(800):
            assert dut.vsync.value == vsync
            assert dut.hsync.value == 0
            assert dut.rgb.value == 0
            await ClockCycles(dut.clk, 1)
        vsync = 1 if i in (0, 1) else 0
        for j in range(24):
            assert dut.vsync.value == vsync
            assert dut.hsync.value == 0
            assert dut.rgb.value == 0
            await ClockCycles(dut.clk, 1)
        for j in range(72):
            assert dut.vsync.value == vsync
            assert dut.hsync.value == 1
            assert dut.rgb.value == 0
            await ClockCycles(dut.clk, 1)
        for j in range(128):
            assert dut.vsync.value == vsync
            assert dut.hsync.value == 0
            assert dut.rgb.value == 0
            await ClockCycles(dut.clk, 1)

    # First frame
    for i in range(600):
        for j in range(799):  # TODO This is wrong
            assert dut.vsync.value == 0
            assert dut.hsync.value == 0
            assert dut.rgb.value == 1
            await ClockCycles(dut.clk, 1)
        for j in range(25):
            assert dut.vsync.value == 0
            assert dut.hsync.value == 0
            assert dut.rgb.value == 0
            await ClockCycles(dut.clk, 1)
        for j in range(72):
            assert dut.vsync.value == 0
            assert dut.hsync.value == 1
            assert dut.rgb.value == 0
            await ClockCycles(dut.clk, 1)
        for j in range(128):
            assert dut.vsync.value == 0
            assert dut.hsync.value == 0
            assert dut.rgb.value == 0
            await ClockCycles(dut.clk, 1)

    for i in range(25):
        vsync = 1 if i in (1, 2) else 0
        for j in range(800):
            assert dut.vsync.value == vsync
            assert dut.hsync.value == 0
            assert dut.rgb.value == 0
            await ClockCycles(dut.clk, 1)
        vsync = 1 if i in (0, 1) else 0
        for j in range(24):
            assert dut.vsync.value == vsync
            assert dut.hsync.value == 0
            assert dut.rgb.value == 0
            await ClockCycles(dut.clk, 1)
        for j in range(72):
            assert dut.vsync.value == vsync
            assert dut.hsync.value == 1
            assert dut.rgb.value == 0
            await ClockCycles(dut.clk, 1)
        for j in range(128):
            assert dut.vsync.value == vsync
            assert dut.hsync.value == 0
            assert dut.rgb.value == 0
            await ClockCycles(dut.clk, 1)

    # Beginning second frame
    for i in range(25):
        for j in range(799):  # TODO This is wrong
            assert dut.vsync.value == 0
            assert dut.hsync.value == 0
            assert dut.rgb.value == 1
            await ClockCycles(dut.clk, 1)
        for j in range(25):
            assert dut.vsync.value == 0
            assert dut.hsync.value == 0
            assert dut.rgb.value == 0
            await ClockCycles(dut.clk, 1)
        for j in range(72):
            assert dut.vsync.value == 0
            assert dut.hsync.value == 1
            assert dut.rgb.value == 0
            await ClockCycles(dut.clk, 1)
        for j in range(128):
            assert dut.vsync.value == 0
            assert dut.hsync.value == 0
            assert dut.rgb.value == 0
            await ClockCycles(dut.clk, 1)

