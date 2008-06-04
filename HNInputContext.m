/*
 * Hanulim
 * $Id$
 *
 * http://www.osxdev.org
 * http://code.google.com/p/hanulim
 */

#import "HNAppController.h"
#import "HNInputController.h"
#import "HNInputContext.h"
#import "HNDebug.h"


/*
 * Key Conversion Code
 */
#define HNKeyType(aConv)  ((aConv & 0xff00) >> 8)
#define HNKeyValue(aConv) (aConv & 0xff)

enum
{
    HNKeyTypeSymbol = 0,
    HNKeyTypeInitial,
    HNKeyTypeMedial,
    HNKeyTypeFinal
};


/*
 * Keyboard Layout Table
 */
#define HNKeyCodeMax 51

typedef enum HNKeyboardLayoutType
{
    HNKeyboardLayoutTypeJamo = 0,
    HNKeyboardLayoutTypeJaso,
    HNKeyboardLayoutTypeMax
} HNKeyboardLayoutType;

typedef enum HNKeyboardLayoutScope
{
    HNKeyboardLayoutScopeModern = 0,
    HNKeyboardLayoutScopeArchaic,
    HNKeyboardLayoutScopeMax
} HNKeyboardLayoutScope;

struct HNKeyboardLayout
{
    const NSString        *mName;
    HNKeyboardLayoutType   mType;
    HNKeyboardLayoutScope  mScope;
    unsigned int           mValue[HNKeyCodeMax];
};

static HNKeyboardLayout HNKeyboardLayoutTable[] =
{
    {
        @"org.osxdev.inputmethod.Hanulim.2standard",
        HNKeyboardLayoutTypeJamo,
        HNKeyboardLayoutScopeModern,
        {
            0x01060106, // a (00)
            0x01020102, // s (01)
            0x010b010b, // d (02)
            0x01050105, // f (03)
            0x02080208, // h (04)
            0x01120112, // g (05)
            0x010f010f, // z (06)
            0x01100110, // x (07)
            0x010e010e, // c (08)
            0x01110111, // v (09)
            0x00000000,
            0x02110211, // b (11)
            0x01080107, // q (12)
            0x010d010c, // w (13)
            0x01040103, // e (14)
            0x01010100, // r (15)
            0x020c020c, // y (16)
            0x010a0109, // t (17)
            0x00010011, // 1 (18)
            0x00200012, // 2 (19)
            0x00030013, // 3 (20)
            0x00040014, // 4 (21)
            0x00240016, // 6 (22)
            0x00050015, // 5 (23)
            0x000b001d, // = (24)
            0x00080019, // 9 (25)
            0x00060017, // 7 (26)
            0x0025000d, // - (27)
            0x000a0018, // 8 (28)
            0x00090010, // 0 (29)
            0x00290023, // ] (30)
            0x02030201, // o (31)
            0x02060206, // u (32)
            0x00270021, // [ (33)
            0x02020202, // i (34)
            0x02070205, // p (35)
            0x00000000,
            0x02140214, // l (37)
            0x02040204, // j (38)
            0x00020007, // ' (39)
            0x02000200, // k (40)
            0x001a001b, // ; (41)
            0x0028002f, // \ (42)
            0x001c000c, // , (43)
            0x001f000f, // / (44)
            0x020d020d, // n (45)
            0x02120212, // m (46)
            0x001e000e, // . (47)
            0x00000000,
            0x00000000,
            0x002a0026, // ` (50)
        }
    },

    {
        @"org.osxdev.inputmethod.Hanulim.2archaic",
        HNKeyboardLayoutTypeJamo,
        HNKeyboardLayoutScopeArchaic,
        {
            0x01400106, // a (00)
            0x03060102, // s (01)
            0x014c010b, // d (02)
            0x011a0105, // f (03)
            0x02220208, // h (04)
            0x01590112, // g (05)
            0x013c010f, // z (06)
            0x013e0110, // x (07)
            0x014e010e, // c (08)
            0x01500111, // v (09)
            0x00000000,
            0x01540211, // b (11)
            0x01080107, // q (12)
            0x010d010c, // w (13)
            0x01040103, // e (14)
            0x01010100, // r (15)
            0x020c020c, // y (16)
            0x010a0109, // t (17)
            0x00010011, // 1 (18)
            0x00200012, // 2 (19)
            0x00030013, // 3 (20)
            0x00040014, // 4 (21)
            0x00240016, // 6 (22)
            0x00050015, // 5 (23)
            0x000b001d, // = (24)
            0x00080019, // 9 (25)
            0x00060017, // 7 (26)
            0x0025000d, // - (27)
            0x000a0018, // 8 (28)
            0x00090010, // 0 (29)
            0x00290023, // ] (30)
            0x02030201, // o (31)
            0x02060206, // u (32)
            0x00270021, // [ (33)
            0x02020202, // i (34)
            0x02070205, // p (35)
            0x00000000,
            0x02330214, // l (37)
            0x02fe0204, // j (38)
            0x00020007, // ' (39)
            0x023d0200, // k (40)
            0x001a001b, // ; (41)
            0x0028002f, // \ (42)
            0x001c000c, // , (43)
            0x001f000f, // / (44)
            0x0155020d, // n (45)
            0x02120212, // m (46)
            0x001e000e, // . (47)
            0x00000000,
            0x00000000,
            0x002a0026, // ` (50)
        }
    },

    {
        @"org.osxdev.inputmethod.Hanulim.3final",
        HNKeyboardLayoutTypeJaso,
        HNKeyboardLayoutScopeModern,
        {
            0x03070315, // a (00)
            0x03060304, // s (01)
            0x030b0214, // d (02)
            0x030a0200, // f (03)
            0x00100102, // h (04)
            0x02030212, // g (05)
            0x03170310, // z (06)
            0x03120301, // x (07)
            0x03180205, // c (08)
            0x03030208, // v (09)
            0x00000000,
            0x001f020d, // b (11)
            0x031a0313, // q (12)
            0x03190308, // w (13)
            0x03050206, // e (14)
            0x030f0201, // r (15)
            0x00150105, // y (16)
            0x030c0204, // t (17)
            0x0302031b, // 1 (18)
            0x03090314, // 2 (19)
            0x03160311, // 3 (20)
            0x030e020c, // 4 (21)
            0x001d0202, // 6 (22)
            0x030d0211, // 5 (23)
            0x000b001e, // = (24)
            0x0007020d, // 9 (25)
            0x002c0207, // 7 (26)
            0x001b0009, // - (27)
            0x002d0213, // 8 (28)
            0x002a010f, // 0 (29)
            0x000f001c, // ] (30)
            0x0018010e, // o (31)
            0x00160103, // u (32)
            0x00050008, // [ (33)
            0x00170106, // i (34)
            0x00190111, // p (35)
            0x00000000,
            0x0013010c, // l (37)
            0x0011010b, // j (38)
            0x002b0110, // ' (39)
            0x00120100, // k (40)
            0x00140107, // ; (41)
            0x002f001a, // \ (42)
            0x000c000c, // , (43)
            0x00010208, // / (44)
            0x000d0109, // n (45)
            0x00020112, // m (46)
            0x000e000e, // . (47)
            0x00000000,
            0x00000000,
            0x002e000a, // ` (50)
        }
    },

    {
        @"org.osxdev.inputmethod.Hanulim.390",
        HNKeyboardLayoutTypeJaso,
        HNKeyboardLayoutScopeModern,
        {
            0x03070315, // a (00)
            0x03060304, // s (01)
            0x03090214, // d (02)
            0x03020200, // f (03)
            0x00070102, // h (04)
            0x000f0212, // g (05)
            0x03170310, // z (06)
            0x03120301, // x (07)
            0x030a0205, // c (08)
            0x030f0208, // v (09)
            0x00000000,
            0x0001020d, // b (11)
            0x031a0313, // q (12)
            0x03190308, // w (13)
            0x03180206, // e (14)
            0x02030201, // r (15)
            0x001c0105, // y (16)
            0x001b0204, // t (17)
            0x0316031b, // 1 (18)
            0x00200314, // 2 (19)
            0x00030311, // 3 (20)
            0x0004020c, // 4 (21)
            0x00240202, // 6 (22)
            0x00050211, // 5 (23)
            0x000b001d, // = (24)
            0x0008020d, // 9 (25)
            0x00060207, // 7 (26)
            0x0025000d, // - (27)
            0x000a0213, // 8 (28)
            0x0009010f, // 0 (29)
            0x00290023, // ] (30)
            0x0019010e, // o (31)
            0x00170103, // u (32)
            0x00270021, // [ (33)
            0x00180106, // i (34)
            0x001e0111, // p (35)
            0x00000000,
            0x0016010c, // l (37)
            0x0014010b, // j (38)
            0x00020110, // ' (39)
            0x00150100, // k (40)
            0x001a0107, // ; (41)
            0x0028002f, // \ (42)
            0x0012000c, // , (43)
            0x001f0208, // / (44)
            0x00100109, // n (45)
            0x00110112, // m (46)
            0x0013000e, // . (47)
            0x00000000,
            0x00000000,
            0x002a0026, // ` (50)
        }
    },

    {
        @"org.osxdev.inputmethod.Hanulim.3noshift",
        HNKeyboardLayoutTypeJaso,
        HNKeyboardLayoutScopeModern,
        {
            0x03150315, // a (00)
            0x00210304, // s (01)
            0x00230214, // d (02)
            0x02000200, // f (03)
            0x00070102, // h (04)
            0x000f0212, // g (05)
            0x000d0310, // z (06)
            0x001d0301, // x (07)
            0x002f0205, // c (08)
            0x02080208, // v (09)
            0x00000000,
            0x0001020d, // b (11)
            0x03130313, // q (12)
            0x03080308, // w (13)
            0x02060206, // e (14)
            0x02010201, // r (15)
            0x001c0105, // y (16)
            0x001b0204, // t (17)
            0x0001031b, // 1 (18)
            0x00200314, // 2 (19)
            0x00030311, // 3 (20)
            0x0004020c, // 4 (21)
            0x00240202, // 6 (22)
            0x00050211, // 5 (23)
            0x000b0317, // = (24)
            0x0008010f, // 9 (25)
            0x00060207, // 7 (26)
            0x00250316, // - (27)
            0x000a0213, // 8 (28)
            0x00090203, // 0 (29)
            0x0029031a, // ] (30)
            0x0019010e, // o (31)
            0x00170103, // u (32)
            0x00270319, // [ (33)
            0x00180106, // i (34)
            0x001e0111, // p (35)
            0x00000000,
            0x0016010c, // l (37)
            0x0014010b, // j (38)
            0x00020110, // ' (39)
            0x00150100, // k (40)
            0x001a0107, // ; (41)
            0x00280318, // \ (42)
            0x0012000c, // , (43)
            0x001f0307, // / (44)
            0x00100109, // n (45)
            0x00110112, // m (46)
            0x0013000e, // . (47)
            0x00000000,
            0x00000000,
            0x002a0026, // ` (50)
        }
    },

    {
        @"org.osxdev.inputmethod.Hanulim.393",
        HNKeyboardLayoutTypeJaso,
        HNKeyboardLayoutScopeArchaic,
        {
            0x03070315, // a (00)
            0x03060304, // s (01)
            0x03090214, // d (02)
            0x03020200, // f (03)
            0x00070102, // h (04)
            0x023d0212, // g (05)
            0x03170310, // z (06)
            0x03120301, // x (07)
            0x030a0205, // c (08)
            0x030f0208, // v (09)
            0x00000000,
            0x0001020d, // b (11)
            0x031a0313, // q (12)
            0x03190308, // w (13)
            0x03180206, // e (14)
            0x02030201, // r (15)
            0x00310105, // y (16)
            0x001b0204, // t (17)
            0x0316031b, // 1 (18)
            0x03440314, // 2 (19)
            0x00030311, // 3 (20)
            0x0004020c, // 4 (21)
            0x00240202, // 6 (22)
            0x00050211, // 5 (23)
            0x000b001d, // = (24)
            0x0008020d, // 9 (25)
            0x00060207, // 7 (26)
            0x0025000d, // - (27)
            0x000a0213, // 8 (28)
            0x0009010f, // 0 (29)
            0x00290023, // ] (30)
            0x0155010e, // o (31)
            0x00300103, // u (32)
            0x00270021, // [ (33)
            0x01540106, // i (34)
            0x001e0111, // p (35)
            0x00000000,
            0x0150010c, // l (37)
            0x014c010b, // j (38)
            0x00020110, // ' (39)
            0x014e0100, // k (40)
            0x001a0107, // ; (41)
            0x0028002f, // \ (42)
            0x013c000c, // , (43)
            0x001f0208, // / (44)
            0x01400109, // n (45)
            0x01590112, // m (46)
            0x013e000e, // . (47)
            0x00000000,
            0x00000000,
            0x03490352, // ` (50)
        }
    },

    {
        nil,
        HNKeyboardLayoutTypeJaso,
        HNKeyboardLayoutScopeArchaic,
        {
            0
        }
    }
};


/*
 * Jaso Conversion Table (initial consonant -> final consonant)
 */
static unsigned char HNJasoInitialToFinal[] =
{
    0x01, 0x02, 0x04, 0x07, 0x00, 0x08, 0x10, 0x11, 0x00, 0x13,
    0x14, 0x15, 0x16, 0x00, 0x17, 0x18, 0x19, 0x1a, 0x1b,
    // archaic
    0x1e, 0x00, 0x1f, 0x00, 0x23, 0x26, 0x29, 0x00, 0x00, 0x35,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x3d, 0x3f, 0x00, 0x40, 0x00, 0x41, 0x42,
    0x00, 0x43, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x44, 0x45, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x47, 0x00, 0x00, 0x00, 0x00, 0x49, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x4c, 0x4d, 0x00,
    0x52,
};


/*
 * Jaso Composition Table
 */
typedef struct HNJasoComposition
{
    int             mCount[HNKeyboardLayoutScopeMax];
    unsigned short *mIn;
    char           *mOut;
} HNJasoComposition;

static unsigned short HNJasoCompositionInInitial[] =
{
    0x0000, 0x0303, 0x0707, 0x0909, 0x0c0c,
    // archaic
    0x0200, 0x0202, 0x0203, 0x0207, 0x0300, 0x0502, 0x0505, 0x0512, 0x054c, 0x0607,
    0x064c, 0x0700, 0x0702, 0x0703, 0x0709, 0x2100, 0x2103, 0x2107, 0x2109, 0x210c,
    0x070c, 0x070e, 0x0710, 0x0711, 0x074c, 0x084c, 0x0900, 0x0902, 0x0903, 0x0905,
    0x0906, 0x0907, 0x3300, 0x0a09, 0x094c, 0x090c, 0x090e, 0x090f, 0x0910, 0x0911,
    0x0912, 0x3c3c, 0x3e3e, 0x4c00, 0x4c03, 0x4c06, 0x4c07, 0x4c09, 0x4c40, 0x4c4c,
    0x4c0c, 0x4c0e, 0x4c10, 0x4c11, 0x0c4c, 0x4e4e, 0x5151, 0x0e0f, 0x0e12, 0x1107,
    0x114c, 0x1212
};

static unsigned short HNJasoCompositionInMedial[] =
{
    0x0014, 0x0214, 0x0414, 0x0614, 0x0800, 0x0801, 0x0914, 0x0814, 0x0d04, 0x0d05,
    0x0e14, 0x0d14, 0x1214,
    // archaic
    0x0008, 0x000d, 0x0208, 0x020c, 0x0408, 0x040d, 0x0412, 0x0608, 0x060d, 0x0804,
    0x0805, 0x1e14, 0x0807, 0x0808, 0x080d, 0x0c02, 0x0c03, 0x2314, 0x0c06, 0x0c08,
    0x0c14, 0x0d00, 0x0d01, 0x2814, 0x0e12, 0x0d07, 0x0d0d, 0x1100, 0x1104, 0x1105,
    0x2e14, 0x1106, 0x1107, 0x3014, 0x110d, 0x1114, 0x120d, 0x1212, 0x130d, 0x1400,
    0x1402, 0x1408, 0x140d, 0x1412, 0x143d, 0x3d04, 0x3d0d, 0x3d14, 0x3d3d
};

static unsigned short HNJasoCompositionInFinal[] =
{
    0x0101, 0x0113, 0x0416, 0x041b, 0x0801, 0x0810, 0x0811, 0x0813, 0x0819, 0x081a,
    0x081b, 0x1113, 0x1313,
    // archaic
    0x0108, 0x0301, 0x0401, 0x0407, 0x0413, 0x0444, 0x0419, 0x0701, 0x0708, 0x0803,
    0x0913, 0x0804, 0x0807, 0x271b, 0x0808, 0x0a01, 0x0a13, 0x0812, 0x0b13, 0x0b1b,
    0x0b49, 0x0814, 0x0844, 0x0818, 0x0852, 0x1001, 0x1008, 0x1011, 0x1013, 0x1014,
    0x3613, 0x1044, 0x1017, 0x101b, 0x1049, 0x1108, 0x111a, 0x111b, 0x1149, 0x1301,
    0x1307, 0x1308, 0x1311, 0x4901, 0x4902, 0x4501, 0x4949, 0x4918, 0x4913, 0x4944,
    0x1a11, 0x1a49, 0x1b04, 0x1b08, 0x1b10, 0x1b11
};

static char HNJasoCompositionOutInitial[] =
{
    0x01, 0x04, 0x08, 0x0a, 0x0d,
    // archaic
    0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1a, 0x1b, 0x1c,
    0x1d, 0x1e, 0x1f, 0x20, 0x21, 0x22, 0x23, 0x24, 0x25, 0x26,
    0x27, 0x28, 0x29, 0x2a, 0x2b, 0x2c, 0x2d, 0x2e, 0x2f, 0x30,
    0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x3a,
    0x3b, 0x3d, 0x3f, 0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47,
    0x48, 0x49, 0x4a, 0x4b, 0x4d, 0x4f, 0x51, 0x52, 0x53, 0x56,
    0x57, 0x58
};

static char HNJasoCompositionOutMedial[] =
{
    0x01, 0x03, 0x05, 0x07, 0x09, 0x0a, 0x0a, 0x0b, 0x0e, 0x0f,
    0x0f, 0x10, 0x13,
    // archaic
    0x15, 0x16, 0x17, 0x18, 0x19, 0x1a, 0x1b, 0x1c, 0x1d, 0x1e,
    0x1f, 0x1f, 0x20, 0x21, 0x22, 0x23, 0x24, 0x24, 0x25, 0x26,
    0x27, 0x28, 0x29, 0x29, 0x2a, 0x2b, 0x2c, 0x2d, 0x2e, 0x2f,
    0x2f, 0x30, 0x31, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37,
    0x38, 0x39, 0x3a, 0x3b, 0x3c, 0x3e, 0x3f, 0x40, 0x41
};

static char HNJasoCompositionOutFinal[] =
{
    0x02, 0x03, 0x05, 0x06, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e,
    0x0f, 0x12, 0x14,
    // archaic
    0x1c, 0x1d, 0x1e, 0x1f, 0x20, 0x21, 0x22, 0x23, 0x24, 0x25,
    0x25, 0x26, 0x27, 0x28, 0x29, 0x2a, 0x2b, 0x2c, 0x2c, 0x2d,
    0x2e, 0x2f, 0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37,
    0x37, 0x38, 0x39, 0x3a, 0x3b, 0x3c, 0x3d, 0x3e, 0x3f, 0x40,
    0x41, 0x42, 0x43, 0x45, 0x46, 0x46, 0x47, 0x48, 0x4a, 0x4b,
    0x4c, 0x4d, 0x4e, 0x4f, 0x50, 0x51
};

static HNJasoComposition HNJasoCompositionTable[] =
{
    {
        {
            0,
            0
        },
        NULL,
        NULL
    },
    {
        {
            5,
            67
        },
        HNJasoCompositionInInitial,
        HNJasoCompositionOutInitial
    },
    {
        {
            13,
            62
        },
        HNJasoCompositionInMedial,
        HNJasoCompositionOutMedial
    },
    {
        {
            13,
            69
        },
        HNJasoCompositionInFinal,
        HNJasoCompositionOutFinal
    }
};


/*
 * Unicode Table
 */
#define HNUnicodeSymbolMax 0x32

static unichar HNUnicodeSymbol[HNUnicodeSymbolMax] =
{
    0x0000, // 00 N/A
    0x0021, // 01 !
    0x0022, // 02 "
    0x0023, // 03 #
    0x0024, // 04 $
    0x0025, // 05 %
    0x0026, // 06 &
    0x0027, // 07 '
    0x0028, // 08 (
    0x0029, // 09 )
    0x002a, // 0a *
    0x002b, // 0b +
    0x002c, // 0c ,
    0x002d, // 0d -
    0x002e, // 0e .
    0x002f, // 0f /
    0x0030, // 10 0
    0x0031, // 11 1
    0x0032, // 12 2
    0x0033, // 13 3
    0x0034, // 14 4
    0x0035, // 15 5
    0x0036, // 16 6
    0x0037, // 17 7
    0x0038, // 18 8
    0x0039, // 19 9
    0x003a, // 1a :
    0x003b, // 1b ;
    0x003c, // 1c <
    0x003d, // 1d =
    0x003e, // 1e >
    0x003f, // 1f ?
    0x0040, // 20 @
    0x005b, // 21 [
    0x005c, // 22 \ //
    0x005d, // 23 ]
    0x005e, // 24 ^
    0x005f, // 25 _
    0x0060, // 26 `
    0x007b, // 27 {
    0x007c, // 28 |
    0x007d, // 29 }
    0x007e, // 2a ~
    0x00b7, // 2b ·
    0x201c, // 2c “
    0x201d, // 2d ”
    0x203b, // 2e ※
    0xffe6, // 2f ￦
    0x302e, // 30 (HANGUL SINGLE DOT TONE MARK)
    0x302f, // 31 (HANGUL DOUBLE DOT TONE MARK)
};

static unichar HNUnicodeInitial[] =
{
    0x3131, 0x3132, 0x3134, 0x3137, 0x3138, 0x3139, 0x3141, 0x3142, 0x3143, 0x3145,
    0x3146, 0x3147, 0x3148, 0x3149, 0x314a, 0x314b, 0x314c, 0x314d, 0x314e
};

static unichar HNUnicodeMedial[] =
{
    0x314f, 0x3150, 0x3151, 0x3152, 0x3153, 0x3154, 0x3155, 0x3156, 0x3157, 0x3158,
    0x3159, 0x315a, 0x315b, 0x315c, 0x315d, 0x315e, 0x315f, 0x3160, 0x3161, 0x3162,
    0x3163
};

static unichar HNUnicodeFinal[] =
{
    0x0000, 0x3131, 0x3132, 0x3133, 0x3134, 0x3135, 0x3136, 0x3137, 0x3139, 0x313a,
    0x313b, 0x313c, 0x313d, 0x313e, 0x313f, 0x3140, 0x3141, 0x3142, 0x3144, 0x3145,
    0x3146, 0x3147, 0x3148, 0x314a, 0x314b, 0x314c, 0x314d, 0x314e
};

static unichar *HNUnicodeJamo[] =
{
    NULL,
    HNUnicodeInitial,
    HNUnicodeMedial,
    HNUnicodeFinal
};


/*
 * Character Composition Buffer
 */
typedef union HNCharacter
{
    struct
    {
        unsigned char mType;
        char          mInitial;
        char          mMedial;
        char          mFinal;
    } mByKey;

    struct
    {
        char mValue[4];
    } mByIndex;

#define CH_TYPE mByKey.mType
#define CH_CHO  mByKey.mInitial
#define CH_JUNG mByKey.mMedial
#define CH_JONG mByKey.mFinal
#define CH_VAL  mByIndex.mValue
#define CH_NIL  ((char)-1)
#define CH_FILL ((char)-2)

} HNCharacter;


/*
 * Key Code Extraction Functions
 */
static BOOL HNCouldHandleKey(NSUInteger aModifiers)
{
    static NSUInteger sMask = NSDeviceIndependentModifierFlagsMask & ~(NSAlphaShiftKeyMask | NSShiftKeyMask);

    return (aModifiers & sMask) ? NO : YES;
}

static unsigned short HNKeyboardGetCode(HNInputContext *aContext, unsigned short aKeyCode, NSUInteger aModifiers)
{
    unsigned int   sShift;
    unsigned short sKeyConv;
    unsigned char  sType;
    unsigned char  sValue;

    if ((aModifiers & NSShiftKeyMask) || ((aModifiers & NSAlphaShiftKeyMask) && [aContext->mOptionDelegate handlesCapsLockAsShift]))
    {
        sShift = 16;
    }
    else
    {
        sShift = 0;
    }

    if (aKeyCode < HNKeyCodeMax)
    {
        sKeyConv = aContext->mKeyboardLayout->mValue[aKeyCode] >> sShift;
        sType    = HNKeyType(sKeyConv);
        sValue   = HNKeyValue(sKeyConv);

        if ((sType != HNKeyTypeSymbol) || ((sValue < HNUnicodeSymbolMax) && (HNUnicodeSymbol[sValue] != 0)))
        {
            return sKeyConv;
        }
    }

    return 0;
}


/*
 * Jaso Composition Functions
 */
static char HNJasoCompose(HNInputContext *aContext, unsigned char aType, char aValue1, char aValue2)
{

    unsigned short sIn;
    int            sCount;
    int            i;

    sCount = HNJasoCompositionTable[aType].mCount[aContext->mKeyboardLayout->mScope];
    sIn    = (aValue1 << 8) | aValue2;

    for (i = 0; i < sCount; i++)
    {
        if (HNJasoCompositionTable[aType].mIn[i] == sIn)
        {
            return HNJasoCompositionTable[aType].mOut[i];
        }
    }

    return CH_NIL;
}


/*
 * Character Composition Functions
 */
static void HNCharacterClear(HNCharacter *aChar)
{
    aChar->CH_TYPE = 0;
    aChar->CH_CHO  = CH_NIL;
    aChar->CH_JUNG = CH_NIL;
    aChar->CH_JONG = CH_NIL;
}

static void HNCharacterCopy(HNCharacter *aSrcChar, HNCharacter *aDstChar)
{
    *aDstChar = *aSrcChar;
}

static void HNCharacterSet(HNCharacter *aChar, char aType, char aValue)
{
    aChar->CH_TYPE       = aType;
    aChar->CH_VAL[aType] = aValue;
}

static NSUInteger HNCharacterCompose(HNInputContext *aContext, HNCharacter *aChar, unichar *aOutput)
{
    static const char    sMin[4]    = { 0, 0, 0, 1 };
    static const char    sCMax[4]   = { 0, 89, 65, 82 };
    static const char    sSMax[4]   = { 0, 18, 20, 27 };
    static const unichar sBase[4]   = { 0, 0x1100, 0x1161, 0x11a7 };
    static const unichar sFiller[4] = { 0, 0x115f, 0x1160, 0 };
    NSUInteger           sLength    = 0;
    int                  i;

    if ((aContext->mKeyboardLayout->mScope == HNKeyboardLayoutScopeArchaic) || [aContext->mOptionDelegate usesDecomposedUnicode])
    {
        for (i = HNKeyTypeInitial; i <= HNKeyTypeFinal; i++)
        {
            if ((aChar->CH_VAL[i] >= sMin[i]) && (aChar->CH_VAL[i] <= sCMax[i]))
            {
                aOutput[i - 1] = sBase[i] + aChar->CH_VAL[i];
                sLength = i;
            }
            else
            {
                aOutput[i - 1] = sFiller[i];
            }
        }
    }
    else
    {
        HNCharacter   sChar;
        unsigned char sCount = 0;
        unsigned char sType  = 0;

        HNCharacterCopy(aChar, &sChar);

        if (sChar.CH_JONG == CH_NIL)
        {
            sChar.CH_JONG = 0;
        }

        for (i = HNKeyTypeInitial; i <= HNKeyTypeFinal; i++)
        {
            if ((sChar.CH_VAL[i] >= sMin[i]) && (sChar.CH_VAL[i] <= sSMax[i]))
            {
                sCount++;
                sType = i;
            }
        }

        if (sCount == ((sType == HNKeyTypeFinal) ? 3 : 2))
        {
            *aOutput = 0xac00 + (sChar.CH_CHO * 21 * 28) + (sChar.CH_JUNG * 28) + sChar.CH_JONG;
            sLength  = 1;
        }
        else if (sCount == 1)
        {
            *aOutput = HNUnicodeJamo[sType][sChar.CH_VAL[sType]];
            sLength  = 1;
        }
        else
        {
            sLength = 0;
        }
    }

    return sLength;
}

static unichar HNQuotationMark(HNInputContext *aContext, unichar aChar)
{
    static unichar sSingleQuots[] = { 0x2018, 0x2019 };
    static unichar sDoubleQuots[] = { 0x201c, 0x201d };

    if (aChar == 0x27) /* single quotation mark */
    {
        aContext->mSingleQuot ^= 1;

        return sSingleQuots[aContext->mSingleQuot];
    }
    else if (aChar == 0x22) /* double quotation mark */
    {
        aContext->mDoubleQuot ^= 1;

        return sDoubleQuots[aContext->mDoubleQuot];
    }
    else
    {
        return aChar;
    }
}


/*
 * Composition Buffer Functions
 */
static void HNCommit(HNInputContext *aContext, const unichar *aBuffer, NSUInteger aLength, unsigned int aKeyCount)
{
    NSString     *sString;
    unsigned int  i;

    aContext->mKeyCount -= aKeyCount;

    for (i = 0; i < aContext->mKeyCount; i++)
    {
        aContext->mKeyBuffer[i] = aContext->mKeyBuffer[i + aKeyCount];
    }

    sString = [[NSString alloc] initWithCharacters:aBuffer length:aLength];

    if (aContext->mFinishedString)
    {
        sString = [[aContext->mFinishedString stringByAppendingString:[sString autorelease]] retain];

        [aContext->mFinishedString release];
    }

    aContext->mFinishedString = sString;
}

static void HNFinishComposition(HNInputContext *aContext)
{
    if (aContext->mComposedString)
    {
        if (aContext->mFinishedString)
        {
            NSString *sString;

            sString = [[aContext->mFinishedString stringByAppendingString:aContext->mComposedString] retain];

            [aContext->mFinishedString release];
            [aContext->mComposedString release];

            aContext->mFinishedString = sString;
        }
        else
        {
            aContext->mFinishedString = aContext->mComposedString;
        }

        aContext->mComposedString = nil;
    }

    aContext->mKeyCount = 0;
}


/*
 * Hangul Composition Functions
 */
static void HNCompose(HNInputContext *aContext)
{
    HNCharacter   sChar;
    unichar       sCharBuffer[1024];
    unichar      *sCharPtr = sCharBuffer;
    NSUInteger    sCharCnt = 0;
    NSUInteger    sLength;
    unsigned int  i;

    HNCharacterClear(&sChar);

    for (i = 0; i < aContext->mKeyCount; i++)
    {
        unsigned short sCode  = aContext->mKeyBuffer[i];
        unsigned char  sType  = HNKeyType(sCode);
        char           sValue = HNKeyValue(sCode);

        if (aContext->mKeyboardLayout->mType == HNKeyboardLayoutTypeJamo)
        {
            if ((sType == HNKeyTypeInitial) && (sChar.CH_TYPE > sType))
            {
                char sFinal = HNJasoInitialToFinal[sValue];

                if (sFinal &&
                    ((sChar.CH_JONG == CH_NIL) ||
                     ((sChar.CH_JONG != sFinal) &&
                      ((sFinal = HNJasoCompose(aContext, HNKeyTypeFinal, sChar.CH_JONG, sFinal)) != CH_NIL))))
                {
                    HNCharacter sTmpChar;

                    HNCharacterCopy(&sChar, &sTmpChar);
                    HNCharacterSet(&sTmpChar, HNKeyTypeFinal, sFinal);

                    if (HNCharacterCompose(aContext, &sTmpChar, sCharPtr))
                    {
                        sType  = HNKeyTypeFinal;
                        sValue = HNJasoInitialToFinal[sValue];
                    }
                }
            }
            else if ((sType == HNKeyTypeMedial) && (sChar.CH_TYPE == HNKeyTypeFinal))
            {
                char sInitial;
                char sFinal;

                sInitial = HNKeyValue(aContext->mKeyBuffer[i - 1]);
                sFinal   = ((i > 1) && (HNKeyType(aContext->mKeyBuffer[i - 2]) == HNKeyTypeInitial)) ?
                HNJasoInitialToFinal[HNKeyValue(aContext->mKeyBuffer[i - 2])] :
                CH_NIL;

                sChar.CH_JONG = sFinal;
                sLength       = HNCharacterCompose(aContext, &sChar, sCharPtr);

                if ([aContext->mOptionDelegate commitsImmediately])
                {
                    HNCommit(aContext, sCharBuffer, sLength, i - 1);

                    i = 1;
                }
                else
                {
                    sCharCnt += sLength;
                    sCharPtr += sLength;
                }

                HNCharacterClear(&sChar);
                HNCharacterSet(&sChar, HNKeyTypeInitial, sInitial);
            }
        }

        if (sChar.CH_TYPE <= sType)
        {
            char sNewValue = (sChar.CH_VAL[sType] != CH_NIL) ? HNJasoCompose(aContext, sType, sChar.CH_VAL[sType], sValue) : sValue;

            if (sNewValue != CH_NIL)
            {
                HNCharacter sTmpChar;

                HNCharacterCopy(&sChar, &sTmpChar);
                HNCharacterSet(&sTmpChar, sType, sNewValue);

                if (HNCharacterCompose(aContext, &sTmpChar, sCharPtr))
                {
                    HNCharacterCopy(&sTmpChar, &sChar);

                    continue;
                }
            }
        }

        sLength = HNCharacterCompose(aContext, &sChar, sCharPtr);

        HNCharacterClear(&sChar);
        HNCharacterSet(&sChar, sType, sValue);

        if (sLength)
        {
            if ([aContext->mOptionDelegate commitsImmediately])
            {
                HNCommit(aContext, sCharBuffer, sLength, i);

                i = 0;
            }
            else
            {
                sCharCnt += sLength;
                sCharPtr += sLength;
            }
        }
    }

    sCharCnt += HNCharacterCompose(aContext, &sChar, sCharPtr);

    [aContext->mComposedString release];
    aContext->mComposedString = [[NSString alloc] initWithCharacters:sCharBuffer length:sCharCnt];
}


/*
 * Public Functions
 */
void HNICInitialize(HNInputContext *aContext)
{
    aContext->mKeyboardLayout = NULL;
    aContext->mOptionDelegate = nil;

    aContext->mComposedString = nil;
    aContext->mFinishedString = nil;

    aContext->mSingleQuot     = 1;
    aContext->mDoubleQuot     = 1;

    aContext->mKeyCount       = 0;
}

void HNICFinalize(HNInputContext *aContext)
{
    [aContext->mComposedString release];
    [aContext->mFinishedString release];
}

void HNICSetKeyboardLayout(HNInputContext *aContext, NSString *aName)
{
    int i;

    for (i = 0; HNKeyboardLayoutTable[i].mName; i++)
    {
        if ([HNKeyboardLayoutTable[i].mName isEqualToString:aName])
        {
            aContext->mKeyboardLayout = &HNKeyboardLayoutTable[i];
            break;
        }
    }
}

void HNICSetOptionDelegate(HNInputContext *aContext, id aDelegate)
{
    aContext->mOptionDelegate = aDelegate;
}

BOOL HNICHandleEvent(HNInputContext *aContext, NSEvent *aEvent)
{
    BOOL           sCouldHandle;
    unsigned short sKeyConv;
    unichar        sSymbol;

    sCouldHandle = HNCouldHandleKey([aEvent modifierFlags]);

    if (sCouldHandle)
    {
        sKeyConv = HNKeyboardGetCode(aContext, [aEvent keyCode], [aEvent modifierFlags]);
    }
    else
    {
        sKeyConv = 0;
    }

    if (sKeyConv)
    {
        if (HNKeyType(sKeyConv) == HNKeyTypeSymbol)
        {
            sSymbol = HNUnicodeSymbol[HNKeyValue(sKeyConv)];

            if ([aContext->mOptionDelegate usesSmartQuotationMarks])
            {
                sSymbol = HNQuotationMark(aContext, sSymbol);
            }

            HNFinishComposition(aContext);
            HNCommit(aContext, &sSymbol, 1, 0);
        }
        else if (aContext->mKeyCount < HNBufferSize)
        {
            aContext->mKeyBuffer[aContext->mKeyCount] = sKeyConv;
            aContext->mKeyCount++;

            HNCompose(aContext);
        }
        else
        {
            fprintf(stderr, "HANULIM ERROR: Buffer overflow. Key ignored.\n");
        }

        return YES;
    }
    else if (sCouldHandle && aContext->mKeyCount)
    {
        NSString *sString = [aEvent characters];

        if (([sString length] > 0) && ([sString characterAtIndex:0] == 0x08)) /* delete */
        {
            aContext->mKeyCount--;

            HNCompose(aContext);
            return YES;
        }
        else
        {
            HNFinishComposition(aContext);
            return NO;
        }
    }
    else
    {
        HNFinishComposition(aContext);
        return NO;
    }
}

void HNICClear(HNInputContext *aContext)
{
    [aContext->mComposedString release];
    [aContext->mFinishedString release];
    aContext->mComposedString = nil;
    aContext->mFinishedString = nil;
    aContext->mKeyCount       = 0;
}

NSString *HNICComposedString(HNInputContext *aContext)
{
    return aContext->mComposedString;
}

NSString *HNICFinishedString(HNInputContext *aContext)
{
    NSString *sRet = [aContext->mFinishedString autorelease];

    aContext->mFinishedString = nil;

    return sRet;
}
