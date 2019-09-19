// Character.asm
if !{defined __CHARACTER__} {
define __CHARACTER__()
print "included Character.asm\n"

// @ Description
// This file contains character related information, constants, and functions

include "Global.asm"
include "OS.asm"

scope Character {
    // @ Description
    // character id constants
    // constant names are loosely based on the debug names for characters
    scope id {
        constant MARIO(0x00)
        constant FOX(0x01)
        constant DONKEY_KONG(0x02)
        constant SAMUS(0x03)
        constant LUIGI(0x04)
        constant LINK(0x05)
        constant YOSHI(0x06)
        constant CAPTAIN_FALCON(0x07)
        constant KIRBY(0x08)
        constant PIKACHU(0x09)
        constant JIGGLYPUFF(0x0A)
        constant NESS(0x0B)
        constant BOSS(0x0C)
        constant METAL_MARIO(0x0D)
        constant NMARIO(0x0E)
        constant NFOX(0x0F)
        constant NDONKEY(0x10)
        constant NSAMUS(0x11)
        constant NLUIGI(0x12)
        constant NLINK(0x13)
        constant NYOSHI(0x14)
        constant NCAPTAIN(0x14)
        constant NKIRBY(0x15)
        constant NPIKACHU(0x17)
        constant NJIGGLY(0x18)
        constant NNESS(0x19)
        constant GDONKEY(0x1A)
        constant NONE(0x1C)
    }
    
    // @ Description
    // Adds a 32-bit signed int to the player's percentage
    // the game will crash if the player's % goes below 0
    // @ Arguments
    // a0 - address of the player struct
    // a1 - percentage to add to the player
    // @ Note
    // This function is not safe by STYLE.md conventions so it has been wrapped
    scope add_percent_: {
        OS.save_registers()
        jal     0x800EA248
        nop
        OS.restore_registers()
        jr      ra
        nop
    }
    
    // @ Description
    // Returns the address of the player struct for the given player.
    // @ Arguments 
    // a0 - player (p1 = 0, p4 = 3)
    // @ Returns
    // v0 - address of player X struct
    scope get_struct_: {
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // save registers

        li      t0, Global.p_struct_head    // t0 = address of player struct list head
        lw      t0, 0x0000(t0)              // t0 = address of player 1 struct
        lli     t1, Global.P_STRUCT_LENGTH  // t1 = player struct length
        mult    a0, t1                      // ~
        mflo    t1                          // t1 = offset = player struct length * player
        addu    v0, t0, t1                  // v0 = ret = address of player struct

        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // restore registers
        addiu   sp, sp, 0x0010              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // this function returns what character is selected by the tokens position
    // this is purely based on token position, not hand position

    // @ Returns
    // v0 - character id
    // 8013782C

    constant START_X(10)
    constant START_Y(20)
    constant START_VISUAL(15)
    constant NUM_ROWS(2)
    constant NUM_COLUMNS(6)
    constant NUM_TILES(NUM_ROWS * NUM_COLUMNS)
    constant ICON_SIZE(50)

    scope css_get_character_id_: {
        OS.patch_start(0x000135AEC, 0x8013786C)
        j       css_get_character_id_
        nop
        OS.patch_end()

        // make sure chip is down
            // if chip not down, return no character 0x1C
            // if chip down, return char id based on position
        
        mfc1    v1, f10             // original line 1 (v1 = (int) ypos)
        mfc1    a1, f6              // original line 2 (a1 = (int) xpos)

        // make the furthest left/up equal 0 for arithmetic purposes
        addiu   a1, a1, -START_X    // a1 = xpos - X_START
        addiu   v1, v1, -START_Y    // v1 = ypos - Y_START

        addiu   sp, sp,-0x0010      // allocate stack space
        sw      t0, 0x0004(sp)      // ~
        sw      t1, 0x0008(sp)      // ~
        sw      t2, 0x000C(sp)      // save registers

        // calculate id
        lli     t0, ICON_SIZE       // t0 = ICON_SIZE
        divu    a1, t0              // ~
        mflo    t1                  // t1 = x index
        divu    v1, t0              // ~
        mflo    t2                  // t2 = y index

        // multi dimmensional array math
        // index = (row * NUM_COLUMNS) + column
        lli     t0, NUM_COLUMNS     // ~
        multu   t0, t2              // ~
        mflo    t0                  // t0 = (row * NUM_COLUMNS)
        addu    t0, t0, t1          // t0 = index

        // return id.NONE if index is too large for table
        lli     t1, NUM_TILES       // t1 = num tiles
        sltu    t2, t0, t1          // if (t0 < t1), t2 = 0
        beqz    t2, _end            // explained above lol
        lli     v0, id.NONE         // also explained above lol

        li      t1, id_table        // t1 = id_table
        addu    t0, t0, t1          // t1 = id_table[index]
        lbu     v0, 0x0000(t0)      // v0 = character id
        
        _end:
        lw      t0, 0x0004(sp)      // ~
        lw      t1, 0x0008(sp)      // ~
        lw      t2, 0x000C(sp)      // save registers
        addiu   sp, sp, 0x0010      // deallocate stack space
        jr      ra                  // return (discard the rest of the function)
        addiu   sp, sp, 0x0028      // deallocate stack space (original function)

        id_table:
        // default
        db id.METAL_MARIO
        db id.MARIO
        db id.DONKEY_KONG
        db id.LINK
        db id.SAMUS
        db id.CAPTAIN_FALCON
        db id.NESS
        db id.YOSHI
        db id.KIRBY
        db id.FOX
        db id.PIKACHU
        db id.JIGGLYPUFF

        // actual custom
        db id.METAL_MARIO
        db id.FOX
        db id.DONKEY_KONG
        db id.SAMUS
        db id.LUIGI
        db id.LINK
        db id.YOSHI
        db id.CAPTAIN_FALCON
        db id.KIRBY
        db id.PIKACHU
        db id.JIGGLYPUFF
        db id.NESS
        db id.MARIO
        db id.FOX
        db id.DONKEY_KONG
        db id.SAMUS
        db id.LUIGI
        db id.LINK
        db id.YOSHI
        db id.CAPTAIN_FALCON
        db id.KIRBY
        db id.PIKACHU
        db id.JIGGLYPUFF
        db id.NESS
        db id.MARIO
        db id.FOX
        db id.DONKEY_KONG
        db id.SAMUS
        db id.LUIGI
        db id.LINK
        db id.YOSHI
        db id.CAPTAIN_FALCON
        db id.KIRBY
        db id.PIKACHU
        db id.JIGGLYPUFF
        db id.NESS
        db id.MARIO
        db id.FOX
        db id.DONKEY_KONG
        db id.SAMUS
        db id.LUIGI
        db id.LINK
        db id.YOSHI
        db id.CAPTAIN_FALCON
        db id.KIRBY
        db id.PIKACHU
        db id.JIGGLYPUFF
        db id.NESS
        OS.align(4)

    }

    scope run_: {

        addiu   sp, sp,-0x0028              // allocate stack space
        sw      ra, 0x0004(sp)              // ~
        sw      t0, 0x0008(sp)              // ~
        sw      t1, 0x000C(sp)              // ~
        sw      t2, 0x0010(sp)              // ~
        sw      t3, 0x0014(sp)              // ~
        sw      a0, 0x0018(sp)              // ~
        sw      a1, 0x001C(sp)              // ~
        sw      a2, 0x0020(sp)              // ~
        sw      a3, 0x0024(sp)              // restore registers
        

        // draw each character portrait
        // for each row
        // for each column

        lli     t0, NUM_ROWS                // init rows
        _outer_loop:
        beqz    t0, _end                    // once every row complete, end
        nop
        addiu   t0, t0,-0x0001              // decrement outer loop

        
        lli     t1, NUM_COLUMNS             // init columns
        _inner_loop:
        beqz    t1, _outer_loop             // once every column in row drawn, draw next row
        nop
        addiu   t1, t1,-0x0001              // decrement inner loop

        lli     a2, ICON_SIZE               // a2 - width 
        lli     a3, ICON_SIZE               // a3 - height
        multu   a2, t1                      // ~
        mflo    t3                          // t3 = ulx offset
        multu   a2, t0                      // ~
        mflo    t4                          // t4 = uly offset


        lli     a0, Color.ORANGE
        jal     Overlay.set_color_          // fill color = RED
        nop
        lli     a0, START_X + START_VISUAL  // ~
        addu    a0, a0, t3                  // a0 - ulx
        lli     a1, START_Y + START_VISUAL  // ~
        addu    a1, a1, t4                  // a1 - uly
        lli     a2, ICON_SIZE - 1           // a2 - width
        lli     a3, ICON_SIZE - 1           // a3 - height
        jal     Overlay.draw_rectangle_     // draw rectangle
        nop

        b       _inner_loop                 // loop
        nop

        _end:
        lw      ra, 0x0004(sp)              // ~
        lw      t0, 0x0008(sp)              // ~
        lw      t1, 0x000C(sp)              // ~
        lw      t2, 0x0010(sp)              // ~
        lw      t3, 0x0014(sp)              // ~
        lw      a0, 0x0018(sp)              // ~
        lw      a1, 0x001C(sp)              // ~
        lw      a2, 0x0020(sp)              // ~
        lw      a3, 0x0024(sp)              // restore registers
        addiu   sp, sp, 0x0028              // deallocate stack space
        jr      ra                          // return
        nop


    }


    // lol what the fuck this is this find_file_load_ function lmao
    scope find_file_load_: {
        dw 0x3C1A8003                       // original line 1
        dw 0x275A0C80                       // original line 2

        addiu   sp, sp,-0x0020
        sw      t0, 0x0004(sp)
        sw      a0, 0x0008(sp)
        sw      a1, 0x000C(sp)
        sw      a2, 0x0010(sp)
        sw      a3, 0x0014(sp)

        lli     t0, 0x00CB                  // mario attribute data file id
        beq     a0, t0, _pause
        nop 
        beq     a1, t0, _pause
        nop 
        beq     a2, t0, _pause
        nop 
        beq     a3, t0, _pause
        nop

        _pause:
        nop
        nop
        nop

        _end:
        lw      t0, 0x0004(sp)
        lw      a0, 0x0008(sp)
        lw      a1, 0x000C(sp)
        lw      a2, 0x0010(sp)
        lw      a3, 0x0014(sp)
        addiu   sp, sp, 0x0020
        j       0x80000188          // return
        nop
    }

    // TODO
    // improve chip movement when picked up
        // likely needs a complete rewrite
    // find the dlist for the character tiles
    // add announcer sound fx for extra chars
    // add background/series logo for extra chars
    // add name textures for extra chars
    // add white circle size for extra chars
    // update character zoom for extra chars
    // create memory module for loading extra character files
        // or dynamically load characters(?)

    // @ Description
    // this function moves chip always to a set position when chip is down
    // 801388A4
    // values of importance
    // t7 - "player data structure" for p1 as defined by tehzz
    // v0 - "player data structure" for px (calculated value)
    // t8 - 0x0004(v0), cursor info stuct
    // f6 - 0x0090(v0), increment x value?
    // v1 - 0x0074(t8), some pointer in cursor info struct (position pointer?)
    // f4 - 0x0058(v1), ?
    // f8 - f4 + f6, aka ? + ?
    // store f8 @ 0x0058(v1) aka f4 = f4 + f6

    // more on the increment x value
    // written to @ 
        // 80139560 - appears to get value from some table EXTEND
        // 801396F4 - appears to just write 0 to increment x

    // lol we can just ignore all of this by getting rid of the function
    // that slightly move the chip on placement with little consequence
    // @ 80139460
    OS.patch_start(0x001376E0, 0x80139460)
    jr      ra
    nop
    OS.patch_end()


    


    // lines that read from p2 selected character
    // something to do with animations
//  80138B38                // something something animation (unsure)

    // some white circle shit
//  80139BFC                // something something check for 0x1C/nochar
//  80139C28                // size of circle under char aka not even important
//  80139C40                // size of circle again (?)
//  80139C58                // size of circle AGAIN (?)


    // this line controls how many chars are loaded on the VS. CSS
    OS.patch_start(0x0013944C, 0x8013B1CC)
    slti    at, s0, id.NMARIO + 1
    OS.patch_end()

    // this is the call to play_fgm_ for announcing chars
    // 8013689C

    // this loads the zoom table for each character so they all appear the same
    // size. this table has been moved and extended [Fray]
    OS.patch_start(0x00132E58, 0x80134BD8)
    li      t2, zoom_table                  // original line 1/3
    cvt.s.w f10, f8                         // original line 2
    OS.patch_end()

    zoom_table:
    float32 1.25                            // Mario
    float32 1.15                            // Fox
    float32 1.00                            // Donkey Kong
    float32 1.03                            // Samus
    float32 1.21                            // Luigi
    float32 1.33                            // Link
    float32 1.05                            // Yoshi
    float32 1.07                            // Captain Falcon
    float32 1.22                            // Kirby
    float32 1.20                            // Pikachu
    float32 1.25                            // Jigglypuff
    float32 1.30                            // Ness
    float32 1.00                            // Master Hand
    float32 1.25                            // Metal Mario
    float32 1.25                            // Polygon Mario
    float32 1.15                            // Polygon Fox
    float32 1.00                            // Polygon Donkey Kong
    float32 1.03                            // Polygon Samus
    float32 1.21                            // Polygon Luigi
    float32 1.33                            // Polygon Link
    float32 1.05                            // Polygon Yoshi
    float32 1.07                            // Polygon Captain Falcon
    float32 1.22                            // Polygon Kirby
    float32 1.20                            // Polygon Pikachu
    float32 1.25                            // Polygon Jigglypuff
    float32 1.30                            // Polygon Ness
    float32 0.00                            // Unknown (Placeholder)
    float32 0.90                            // Giant Donkey Kong
    float32 0.00                            // None (Placeholder)

}

} // __CHARACTER__