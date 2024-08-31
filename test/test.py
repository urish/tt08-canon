# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, FallingEdge, RisingEdge, Timer
from cocotb.utils import get_sim_time

from PIL import Image

async def do_start(dut, inputs = 0):
    dut._log.info("Start")

    # 36MHz clock
    clock = Clock(dut.clk, 27.778, units="ns")
    cocotb.start_soon(clock.start())

    dut.ena.value = 1
    dut.ui_in.value = inputs
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

    await ClockCycles(dut.clk, 5)
    assert dut.pwm.value == 1

    start_time = get_sim_time("us")
    
    sample_duration = 22
    last_pwm_state = 1
    last_sample_time = start_time
    last_edge_time = start_time
    high_time = 0
    samples = []


    while len(samples) < 200:
        await FallingEdge(dut.pwm)
        cur_time = get_sim_time("us")
        while cur_time - last_sample_time >= sample_duration:
            high_time += sample_duration - (cur_time - last_sample_time)
            samples.append(int(1000 * high_time / sample_duration))
            high_time = 0
            last_sample_time += sample_duration
            if len(samples) > 2:
                assert samples[-1] != samples[-2] or samples[-1] != samples[-3]
            last_edge_time = last_sample_time
        high_time += cur_time - last_edge_time
        
        await RisingEdge(dut.pwm)
        cur_time = get_sim_time("us")
        while cur_time - last_sample_time >= sample_duration:
            samples.append(int(1000 * high_time / sample_duration))
            high_time = 0
            last_sample_time += sample_duration
            if len(samples) > 2:
                assert samples[-1] != samples[-2] or samples[-1] != samples[-3]

        last_edge_time = cur_time

    #print(samples)

    saved_samples = [367, 409, 446, 476, 478, 665, 614, 604, 598, 422, 454, 459, 462, 446, 587, 539, 558, 595, 425, 459, 446, 417, 397, 521, 483, 472, 469, 476, 350, 344, 328, 313, 405, 395, 397, 373, 353, 237, 247, 255, 266, 347, 337, 333, 339, 351, 349, 259, 246, 237, 323, 339, 356, 375, 381, 396, 296, 315, 311, 389, 329, 372, 436, 502, 532, 360, 380, 368, 352, 344, 492, 529, 553, 560, 541, 363, 356, 356, 378, 409, 586, 529, 505, 482, 321, 347, 349, 349, 357, 524, 491, 467, 444, 438, 314, 330, 333, 318, 417, 397, 409, 428, 440, 305, 335, 340, 349, 357, 478, 457, 464, 481, 507, 379, 395, 397, 407, 419, 603, 537, 482, 438, 307, 376, 424, 453, 459, 445, 605, 577, 555, 551, 405, 415, 428, 417, 552, 491, 507, 541, 579, 410, 411, 380, 358, 464, 422, 410, 405, 407, 276, 306, 291, 277, 374, 362, 366, 351, 332, 311, 218, 234, 242, 377, 356, 372, 391, 406, 411, 280, 299, 289, 287, 299, 425, 444, 454, 487, 513, 368, 367, 367, 332, 327, 536, 588, 619, 603, 402, 415, 410, 405, 405, 419, 446, 650, 631, 597, 402, 407]
    for i in range(len(samples)):
        assert samples[i] == saved_samples[i]

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

async def frame_dump(dut, frame, filename):
    await do_start(dut, frame << 3)

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

    
    image = Image.new("RGB", (800, 600))

    for i in range(600):
        for j in range(800):
            assert dut.vsync.value == 0
            assert dut.hsync.value == 0
            red = dut.red.value * 63
            green = dut.green.value * 63
            blue = dut.blue.value * 63
            image.putpixel((j, i), (red, green, blue))
            await ClockCycles(dut.clk, 1)
        for j in range(24):
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

    image.save(filename)

@cocotb.test()
async def test_frames(dut):
    await frame_dump(dut,  2, "frame02.png")
    await frame_dump(dut,  4, "frame04.png")
    await frame_dump(dut,  8, "frame08.png")
    await frame_dump(dut, 12, "frame12.png")
    await frame_dump(dut, 13, "frame13.png")
    await frame_dump(dut, 14, "frame14.png")
    await frame_dump(dut, 16, "frame16.png")
    await frame_dump(dut, 17, "frame17.png")
    await frame_dump(dut, 18, "frame18.png")
    await frame_dump(dut, 19, "frame19.png")
    await frame_dump(dut, 20, "frame20.png")
    await frame_dump(dut, 23, "frame23.png")
    await frame_dump(dut, 24, "frame24.png")
    await frame_dump(dut, 26, "frame26.png")
