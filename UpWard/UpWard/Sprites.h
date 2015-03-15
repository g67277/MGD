// ---------------------------------------
// Sprite definitions for Sprites
// Generated with TexturePacker 3.6.0
//
// http://www.codeandweb.com/texturepacker
// ---------------------------------------

#ifndef __SPRITES_ATLAS__
#define __SPRITES_ATLAS__

// ------------------------
// name of the atlas bundle
// ------------------------
#define SPRITES_ATLAS_NAME @"Sprites"

// ------------
// sprite names
// ------------
#define SPRITES_SPR_ELLA_BLINK     @"ella_blink"
#define SPRITES_SPR_ELLA_FLAPDOWN  @"ella_flapDown"
#define SPRITES_SPR_ELLA_FLAPUP    @"ella_flapUp"
#define SPRITES_SPR_ELLA_LOOKLEFT  @"ella_lookLeft"
#define SPRITES_SPR_ELLA_LOOKRIGHT @"ella_lookRight"
#define SPRITES_SPR_ELLA_TEAR1     @"ella_tear1"
#define SPRITES_SPR_ELLA_TEAR2     @"ella_tear2"

// --------
// textures
// --------
#define SPRITES_TEX_ELLA_BLINK     [SKTexture textureWithImageNamed:@"ella_blink"]
#define SPRITES_TEX_ELLA_FLAPDOWN  [SKTexture textureWithImageNamed:@"ella_flapDown"]
#define SPRITES_TEX_ELLA_FLAPUP    [SKTexture textureWithImageNamed:@"ella_flapUp"]
#define SPRITES_TEX_ELLA_LOOKLEFT  [SKTexture textureWithImageNamed:@"ella_lookLeft"]
#define SPRITES_TEX_ELLA_LOOKRIGHT [SKTexture textureWithImageNamed:@"ella_lookRight"]
#define SPRITES_TEX_ELLA_TEAR1     [SKTexture textureWithImageNamed:@"ella_tear1"]
#define SPRITES_TEX_ELLA_TEAR2     [SKTexture textureWithImageNamed:@"ella_tear2"]

// ----------
// animations
// ----------
#define SPRITES_ANIM_ELLA_TEAR @[ \
        [SKTexture textureWithImageNamed:@"ella_tear1"], \
        [SKTexture textureWithImageNamed:@"ella_tear2"]  \
    ]

#define SPRITES_ANIM_ELLA_FLAP @[ \
        [SKTexture textureWithImageNamed:@"ella_flapDown"], \
        [SKTexture textureWithImageNamed:@"ella_flapUp"]  \
    ]

#define SPRITES_ANIM_ELLA_BLINK @[ \
        [SKTexture textureWithImageNamed:@"ella_flapDown"], \
        [SKTexture textureWithImageNamed:@"ella_blink"]  \
    ]

#endif // __SPRITES_ATLAS__
