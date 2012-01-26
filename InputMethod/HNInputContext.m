/*
 * Hanulim
 * $Id$
 *
 * http://code.google.com/p/hanulim
 */

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
    HNKeyTypeFinal,
    HNKeyTypeDiacritic
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
        @"org.cocomelo.inputmethod.Hanulim.2standard",
        HNKeyboardLayoutTypeJamo,
        HNKeyboardLayoutScopeModern,
        {
            0x01070107, // a (00)
            0x01030103, // s (01)
            0x010c010c, // d (02)
            0x01060106, // f (03)
            0x02090209, // h (04)
            0x01130113, // g (05)
            0x01100110, // z (06)
            0x01110111, // x (07)
            0x010f010f, // c (08)
            0x01120112, // v (09)
            0x00000000,
            0x02120212, // b (11)
            0x01090108, // q (12)
            0x010e010d, // w (13)
            0x01050104, // e (14)
            0x01020101, // r (15)
            0x020d020d, // y (16)
            0x010b010a, // t (17)
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
            0x02040202, // o (31)
            0x02070207, // u (32)
            0x00270021, // [ (33)
            0x02030203, // i (34)
            0x02080206, // p (35)
            0x00000000,
            0x02150215, // l (37)
            0x02050205, // j (38)
            0x00020007, // ' (39)
            0x02010201, // k (40)
            0x001a001b, // ; (41)
            0x0028002f, // \ (42)
            0x001c000c, // , (43)
            0x001f000f, // / (44)
            0x020e020e, // n (45)
            0x02130213, // m (46)
            0x001e000e, // . (47)
            0x00000000,
            0x00000000,
            0x002a0026, // ` (50)
        }
    },

    {
        @"org.cocomelo.inputmethod.Hanulim.2archaic",
        HNKeyboardLayoutTypeJamo,
        HNKeyboardLayoutScopeArchaic,
        {
            0x01410107, // a (00)
            0x015e0103, // s (01)
            0x014d010c, // d (02)
            0x011b0106, // f (03)
            0x02230209, // h (04)
            0x015a0113, // g (05)
            0x013d0110, // z (06)
            0x013f0111, // x (07)
            0x014f010f, // c (08)
            0x01510112, // v (09)
            0x00000000,
            0x01550212, // b (11)
            0x01090108, // q (12)
            0x010e010d, // w (13)
            0x01050104, // e (14)
            0x01020101, // r (15)
            0x0402020d, // y (16)
            0x010b010a, // t (17)
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
            0x02040202, // o (31)
            0x04010207, // u (32)
            0x00270021, // [ (33)
            0x02030203, // i (34)
            0x02080206, // p (35)
            0x00000000,
            0x02340215, // l (37)
            0x02000205, // j (38)
            0x00020007, // ' (39)
            0x023e0201, // k (40)
            0x001a001b, // ; (41)
            0x0028002f, // \ (42)
            0x001c000c, // , (43)
            0x001f000f, // / (44)
            0x0156020e, // n (45)
            0x02130213, // m (46)
            0x001e000e, // . (47)
            0x00000000,
            0x00000000,
            0x002a0026, // ` (50)
        }
    },

    {
        @"org.cocomelo.inputmethod.Hanulim.3final",
        HNKeyboardLayoutTypeJaso,
        HNKeyboardLayoutScopeModern,
        {
            0x03070315, // a (00)
            0x03060304, // s (01)
            0x030b0215, // d (02)
            0x030a0201, // f (03)
            0x00100103, // h (04)
            0x02040213, // g (05)
            0x03170310, // z (06)
            0x03120301, // x (07)
            0x03180206, // c (08)
            0x03030209, // v (09)
            0x00000000,
            0x001f020e, // b (11)
            0x031a0313, // q (12)
            0x03190308, // w (13)
            0x03050207, // e (14)
            0x030f0202, // r (15)
            0x00150106, // y (16)
            0x030c0205, // t (17)
            0x0302031b, // 1 (18)
            0x03090314, // 2 (19)
            0x03160311, // 3 (20)
            0x030e020d, // 4 (21)
            0x001d0203, // 6 (22)
            0x030d0212, // 5 (23)
            0x000b001e, // = (24)
            0x0007020e, // 9 (25)
            0x002c0208, // 7 (26)
            0x001b0009, // - (27)
            0x002d0214, // 8 (28)
            0x002a0110, // 0 (29)
            0x000f001c, // ] (30)
            0x0018010f, // o (31)
            0x00160104, // u (32)
            0x00050008, // [ (33)
            0x00170107, // i (34)
            0x00190112, // p (35)
            0x00000000,
            0x0013010d, // l (37)
            0x0011010c, // j (38)
            0x002b0111, // ' (39)
            0x00120101, // k (40)
            0x00140108, // ; (41)
            0x002f001a, // \ (42)
            0x000c000c, // , (43)
            0x00010209, // / (44)
            0x000d010a, // n (45)
            0x00020113, // m (46)
            0x000e000e, // . (47)
            0x00000000,
            0x00000000,
            0x002e000a, // ` (50)
        }
    },

    {
        @"org.cocomelo.inputmethod.Hanulim.390",
        HNKeyboardLayoutTypeJaso,
        HNKeyboardLayoutScopeModern,
        {
            0x03070315, // a (00)
            0x03060304, // s (01)
            0x03090215, // d (02)
            0x03020201, // f (03)
            0x00070103, // h (04)
            0x000f0213, // g (05)
            0x03170310, // z (06)
            0x03120301, // x (07)
            0x030a0206, // c (08)
            0x030f0209, // v (09)
            0x00000000,
            0x0001020e, // b (11)
            0x031a0313, // q (12)
            0x03190308, // w (13)
            0x03180207, // e (14)
            0x02040202, // r (15)
            0x001c0106, // y (16)
            0x001b0205, // t (17)
            0x0316031b, // 1 (18)
            0x00200314, // 2 (19)
            0x00030311, // 3 (20)
            0x0004020d, // 4 (21)
            0x00240203, // 6 (22)
            0x00050212, // 5 (23)
            0x000b001d, // = (24)
            0x0008020e, // 9 (25)
            0x00060208, // 7 (26)
            0x0025000d, // - (27)
            0x000a0214, // 8 (28)
            0x00090110, // 0 (29)
            0x00290023, // ] (30)
            0x0019010f, // o (31)
            0x00170104, // u (32)
            0x00270021, // [ (33)
            0x00180107, // i (34)
            0x001e0112, // p (35)
            0x00000000,
            0x0016010d, // l (37)
            0x0014010c, // j (38)
            0x00020111, // ' (39)
            0x00150101, // k (40)
            0x001a0108, // ; (41)
            0x0028002f, // \ (42)
            0x0012000c, // , (43)
            0x001f0209, // / (44)
            0x0010010a, // n (45)
            0x00110113, // m (46)
            0x0013000e, // . (47)
            0x00000000,
            0x00000000,
            0x002a0026, // ` (50)
        }
    },

    {
        @"org.cocomelo.inputmethod.Hanulim.3noshift",
        HNKeyboardLayoutTypeJaso,
        HNKeyboardLayoutScopeModern,
        {
            0x03150315, // a (00)
            0x00210304, // s (01)
            0x00230215, // d (02)
            0x02010201, // f (03)
            0x00070103, // h (04)
            0x000f0213, // g (05)
            0x000d0310, // z (06)
            0x001d0301, // x (07)
            0x002f0206, // c (08)
            0x02090209, // v (09)
            0x00000000,
            0x0001020e, // b (11)
            0x03130313, // q (12)
            0x03080308, // w (13)
            0x02070207, // e (14)
            0x02020202, // r (15)
            0x001c0106, // y (16)
            0x001b0205, // t (17)
            0x0001031b, // 1 (18)
            0x00200314, // 2 (19)
            0x00030311, // 3 (20)
            0x0004020d, // 4 (21)
            0x00240203, // 6 (22)
            0x00050212, // 5 (23)
            0x000b0317, // = (24)
            0x00080110, // 9 (25)
            0x00060208, // 7 (26)
            0x00250316, // - (27)
            0x000a0214, // 8 (28)
            0x00090204, // 0 (29)
            0x0029031a, // ] (30)
            0x0019010f, // o (31)
            0x00170104, // u (32)
            0x00270319, // [ (33)
            0x00180107, // i (34)
            0x001e0112, // p (35)
            0x00000000,
            0x0016010d, // l (37)
            0x0014010c, // j (38)
            0x00020111, // ' (39)
            0x00150101, // k (40)
            0x001a0108, // ; (41)
            0x00280318, // \ (42)
            0x0012000c, // , (43)
            0x001f0307, // / (44)
            0x0010010a, // n (45)
            0x00110113, // m (46)
            0x0013000e, // . (47)
            0x00000000,
            0x00000000,
            0x002a0026, // ` (50)
        }
    },

    {
        @"org.cocomelo.inputmethod.Hanulim.393",
        HNKeyboardLayoutTypeJaso,
        HNKeyboardLayoutScopeArchaic,
        {
            0x03070315, // a (00)
            0x03060304, // s (01)
            0x03090215, // d (02)
            0x03020201, // f (03)
            0x00070103, // h (04)
            0x023e0213, // g (05)
            0x03170310, // z (06)
            0x03120301, // x (07)
            0x030a0206, // c (08)
            0x030f0209, // v (09)
            0x00000000,
            0x0001020e, // b (11)
            0x031a0313, // q (12)
            0x03190308, // w (13)
            0x03180207, // e (14)
            0x02040202, // r (15)
            0x04020106, // y (16)
            0x001b0205, // t (17)
            0x0316031b, // 1 (18)
            0x03440314, // 2 (19)
            0x00030311, // 3 (20)
            0x0004020d, // 4 (21)
            0x00240203, // 6 (22)
            0x00050212, // 5 (23)
            0x000b001d, // = (24)
            0x0008020e, // 9 (25)
            0x00060208, // 7 (26)
            0x0025000d, // - (27)
            0x000a0214, // 8 (28)
            0x00090110, // 0 (29)
            0x00290023, // ] (30)
            0x0156010f, // o (31)
            0x04010104, // u (32)
            0x00270021, // [ (33)
            0x01550107, // i (34)
            0x001e0112, // p (35)
            0x00000000,
            0x0151010d, // l (37)
            0x014d010c, // j (38)
            0x00020111, // ' (39)
            0x014f0101, // k (40)
            0x001a0108, // ; (41)
            0x0028002f, // \ (42)
            0x013d000c, // , (43)
            0x001f0209, // / (44)
            0x0141010a, // n (45)
            0x015a0113, // m (46)
            0x013f000e, // . (47)
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
    0x00, // 00
    0x01, // 01 ㄱ
    0x02, // 02 ㄱㄱ
    0x04, // 03 ㄴ
    0x07, // 04 ㄷ
    0x5b, // 05 ㄷㄷ
    0x08, // 06 ㄹ
    0x10, // 07 ㅁ
    0x11, // 08 ㅂ
    0x74, // 09 ㅂㅂ
    0x13, // 0a ㅅ
    0x14, // 0b ㅅㅅ
    0x15, // 0c ㅇ
    0x16, // 0d ㅈ
    0x87, // 0e ㅈㅈ
    0x17, // 0f ㅊ
    0x18, // 10 ㅋ
    0x19, // 11 ㅌ
    0x1a, // 12 ㅍ
    0x1b, // 13 ㅎ
    0x1e, // 14 ㄴㄱ
    0x58, // 15 ㄴㄴ
    0x1f, // 16 ㄴㄷ
    0x00, // 17 ㄴㅂ
    0x23, // 18 ㄷㄱ
    0x26, // 19 ㄹㄴ
    0x29, // 1a ㄹㄹ
    0x0f, // 1b ㄹㅎ
    0x6b, // 1c ㄹㅇ
    0x35, // 1d ㅁㅂ
    0x3b, // 1e ㅁㅇ
    0x00, // 1f ㅂㄱ
    0x00, // 20 ㅂㄴ
    0x71, // 21 ㅂㄷ
    0x12, // 22 ㅂㅅ
    0x00, // 23 ㅂㅅㄱ
    0x75, // 24 ㅂㅅㄷ
    0x00, // 25 ㅂㅅㅂ
    0x00, // 26 ㅂㅅㅅ
    0x00, // 27 ㅂㅅㅈ
    0x76, // 28 ㅂㅈ
    0x77, // 29 ㅂㅊ
    0x00, // 2a ㅂㅌ
    0x3d, // 2b ㅂㅍ
    0x3f, // 2c ㅂㅇ
    0x00, // 2d ㅂㅂㅇ
    0x40, // 2e ㅅㄱ
    0x00, // 2f ㅅㄴ
    0x41, // 30 ㅅㄷ
    0x42, // 31 ㅅㄹ
    0x78, // 32 ㅅㅁ
    0x43, // 33 ㅅㅂ
    0x00, // 34 ㅅㅂㄱ
    0x00, // 35 ㅅㅅㅅ
    0x00, // 36 ㅅㅇ
    0x7d, // 37 ㅅㅈ
    0x7e, // 38 ㅅㅊ
    0x00, // 39 ㅅㅋ
    0x7f, // 3a ㅅㅌ
    0x00, // 3b ㅅㅍ
    0x80, // 3c ㅅㅎ
    0x00, // 3d ᄼᅠ
    0x00, // 3e ᄽᅠ
    0x00, // 3f ᄾᅠ
    0x00, // 40 ᄿᅠ
    0x44, // 41 ㅿ
    0x00, // 42 ㅇㄱ
    0x00, // 43 ㅇㄷ
    0x00, // 44 ㅇㅁ
    0x00, // 45 ㅇㅂ
    0x00, // 46 ㅇㅅ
    0x00, // 47 ㅇㅿ
    0x00, // 48 ㅇㅇ
    0x00, // 49 ㅇㅈ
    0x00, // 4a ㅇㅊ
    0x00, // 4b ㅇㅌ
    0x00, // 4c ㅇㅍ
    0x49, // 4d ㆁ
    0x00, // 4e ㅈㅇ
    0x00, // 4f ᅎᅠ
    0x00, // 50 ᅏᅠ
    0x00, // 51 ᅐᅠ
    0x00, // 52 ᅑᅠ
    0x00, // 53 ㅊㅋ
    0x00, // 54 ㅊㅎ
    0x00, // 55 ᅔᅠ
    0x00, // 56 ᅕᅠ
    0x4c, // 57 ㅍㅂ
    0x4d, // 58 ㅍㅇ
    0x00, // 59 ㅎㅎ
    0x52, // 5a ㆆ
    0x00, // 5b ㄱㄷ
    0x20, // 5c ㄴㅅ
    0x05, // 5d ㄴㅈ
    0x06, // 5e ㄴㅎ
    0x24, // 5f ㄷㄹ
    0x00, // 60 ㄷㅁ
    0x5d, // 61 ㄷㅂ
    0x5e, // 62 ㄷㅅ
    0x60, // 63 ㄷㅈ
    0x09, // 64 ㄹㄱ
    0x63, // 65 ㄹㄱㄱ
    0x27, // 66 ㄹㄷ
    0x00, // 67 ㄹㄷㄷ
    0x0a, // 68 ㄹㅁ
    0x0b, // 69 ㄹㅂ
    0x00, // 6a ㄹㅂㅂ
    0x2e, // 6b ㄹㅂㅇ
    0x0c, // 6c ㄹㅅ
    0x00, // 6d ㄹㅈ
    0x31, // 6e ㄹㅋ
    0x33, // 6f ㅁㄱ
    0x00, // 70 ㅁㄷ
    0x36, // 71 ㅁㅅ
    0x00, // 72 ㅂㅅㅌ
    0x00, // 73 ㅂㅋ
    0x3e, // 74 ㅂㅎ
    0x00, // 75 ㅅㅅㅂ
    0x00, // 76 ㅇㄹ
    0x00, // 77 ㅇㅎ
    0x00, // 78 ㅈㅈㅎ
    0x00, // 79 ㅌㅌ
    0x00, // 7a ㅍㅎ
    0x00, // 7b ㅎㅅ
    0x00, // 7c ㆆㆆ
};


/*
 * Jaso Composition Table
 */
typedef struct HNJasoComposition
{
    int             mCount[HNKeyboardLayoutScopeMax];
    unsigned short *mIn;
    unsigned char  *mOut;
} HNJasoComposition;

static unsigned short HNJasoCompositionInInitial[] =
{
    0x0101, 0x0404, 0x0808, 0x0a0a, 0x0d0d,
    // archaic
    0x0301, 0x0303, 0x0304, 0x0308, 0x0401, 0x0603, 0x0606, 0x0613, 0x060c, 0x0708,
    0x070c, 0x0801, 0x0803, 0x0804, 0x080a, 0x2201, 0x2204, 0x2208, 0x220a, 0x080b,
    0x220d, 0x080d, 0x080f, 0x0811, 0x0812, 0x080c, 0x090c, 0x0a01, 0x0a03, 0x0a04,
    0x0a06, 0x0a07, 0x0a08, 0x3301, 0x0a0b, 0x0b0a, 0x0a0c, 0x0a0d, 0x0a0f, 0x0a10,
    0x0a11, 0x0a12, 0x0a13, 0x3d3d, 0x3f3f, 0x0c01, 0x0c04, 0x0c07, 0x0c08, 0x0c0a,
    0x0c41, 0x0c0c, 0x0c0d, 0x0c0f, 0x0c11, 0x0c12, 0x0d0c, 0x4f4f, 0x5151, 0x0f10,
    0x0f13, 0x1208, 0x120c, 0x1313, 0x0104, 0x030a, 0x030d, 0x0313, 0x0406, 0x0407,
    0x0408, 0x040a, 0x040d, 0x0601, 0x0602, 0x6401, 0x0604, 0x0605, 0x6604, 0x0607,
    0x0608, 0x0609, 0x6908, 0x690c, 0x060a, 0x060d, 0x0610, 0x0701, 0x0704, 0x070a,
    0x2211, 0x0810, 0x0813, 0x0b08, 0x0c06, 0x0c13, 0x0e13, 0x1111, 0x1213, 0x130a,
    0x5a5a,
};

static unsigned char HNJasoCompositionOutInitial[] =
{
    0x02, 0x05, 0x09, 0x0b, 0x0e,
    // archaic
    0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1a, 0x1b, 0x1c, 0x1d,
    0x1e, 0x1f, 0x20, 0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x26,
    0x27, 0x28, 0x29, 0x2a, 0x2b, 0x2c, 0x2d, 0x2e, 0x2f, 0x30,
    0x31, 0x32, 0x33, 0x34, 0x35, 0x35, 0x36, 0x37, 0x38, 0x39,
    0x3a, 0x3b, 0x3c, 0x3e, 0x40, 0x42, 0x43, 0x44, 0x45, 0x46,
    0x47, 0x48, 0x49, 0x4a, 0x4b, 0x4c, 0x4e, 0x50, 0x52, 0x53,
    0x54, 0x57, 0x58, 0x59, 0x5b, 0x5c, 0x5d, 0x5e, 0x5f, 0x60,
    0x61, 0x62, 0x63, 0x64, 0x65, 0x65, 0x66, 0x67, 0x67, 0x68,
    0x69, 0x6a, 0x6a, 0x6b, 0x6c, 0x6d, 0x6e, 0x6f, 0x70, 0x71,
    0x72, 0x73, 0x74, 0x75, 0x76, 0x77, 0x78, 0x79, 0x7a, 0x7b,
    0x7c
};

static unsigned short HNJasoCompositionInMedial[] =
{
    0x0115, 0x0315, 0x0515, 0x0715, 0x0901, 0x0902, 0x0a15, 0x0915, 0x0e05, 0x0e06,
    0x0f15, 0x0e15, 0x1315,
    // archaic
    0x0109, 0x010e, 0x0309, 0x030d, 0x0509, 0x050e, 0x0513, 0x0709, 0x070e, 0x0905,
    0x0906, 0x1f15, 0x0908, 0x4815, 0x0909, 0x090e, 0x0d03, 0x0d04, 0x2415, 0x0d07,
    0x0d09, 0x0d15, 0x0e01, 0x0e02, 0x2915, 0x0f13, 0x0e08, 0x4d15, 0x0e0e, 0x1201,
    0x1205, 0x1206, 0x2f15, 0x1207, 0x1208, 0x3115, 0x120e, 0x1215, 0x130e, 0x1313,
    0x140e, 0x1501, 0x1503, 0x1509, 0x150e, 0x1513, 0x153e, 0x3e05, 0x3e0e, 0x3e15,
    0x3e3e, 0x0113, 0x030e, 0x0703, 0x0903, 0x0904, 0x4615, 0x0907, 0x2215, 0x0d01,
    0x0d02, 0x4a15, 0x0d05, 0x0e07, 0x1115, 0x1202, 0x2e15, 0x1209, 0x1301, 0x1305,
    0x1306, 0x5215, 0x1309, 0x3909, 0x3915, 0x1504, 0x1507, 0x1508, 0x5715, 0x3a15,
    0x150d, 0x1512, 0x1515, 0x3e01, 0x3e06, 0x3f15
};

static unsigned char HNJasoCompositionOutMedial[] =
{
    0x02, 0x04, 0x06, 0x08, 0x0a, 0x0b, 0x0b, 0x0c, 0x0f, 0x10,
    0x10, 0x11, 0x14,
    // archaic
    0x16, 0x17, 0x18, 0x19, 0x1a, 0x1b, 0x1c, 0x1d, 0x1e, 0x1f,
    0x20, 0x20, 0x21, 0x21, 0x22, 0x23, 0x24, 0x25, 0x25, 0x26,
    0x27, 0x28, 0x29, 0x2a, 0x2a, 0x2b, 0x2c, 0x2c, 0x2d, 0x2e,
    0x2f, 0x30, 0x30, 0x31, 0x32, 0x32, 0x33, 0x34, 0x35, 0x36,
    0x37, 0x38, 0x39, 0x3a, 0x3b, 0x3c, 0x3d, 0x3f, 0x40, 0x41,
    0x42, 0x43, 0x44, 0x45, 0x46, 0x47, 0x47, 0x48, 0x49, 0x4a,
    0x4b, 0x4b, 0x4c, 0x4d, 0x4e, 0x4f, 0x4f, 0x50, 0x51, 0x52,
    0x53, 0x53, 0x54, 0x55, 0x56, 0x56, 0x57, 0x58, 0x58, 0x59,
    0x5a, 0x5b, 0x5c, 0x5d, 0x5e, 0x5e
};

static unsigned short HNJasoCompositionInFinal[] =
{
    0x0101, 0x0113, 0x0416, 0x041b, 0x0801, 0x0810, 0x0811, 0x0813, 0x0819, 0x081a,
    0x081b, 0x1113, 0x1313,
    // archaic
    0x0108, 0x0301, 0x0401, 0x0407, 0x0413, 0x0444, 0x0419, 0x0701, 0x0708, 0x0803,
    0x0913, 0x0804, 0x0807, 0x271b, 0x0808, 0x0a01, 0x0a13, 0x0812, 0x0b13, 0x0b1b,
    0x0b15, 0x0814, 0x0844, 0x0818, 0x0852, 0x1001, 0x1008, 0x1011, 0x1013, 0x1014,
    0x3613, 0x1044, 0x1017, 0x101b, 0x1015, 0x1108, 0x111a, 0x111b, 0x1115, 0x1301,
    0x1307, 0x1308, 0x1311, 0x4901, 0x4902, 0x4501, 0x4949, 0x4918, 0x4913, 0x4944,
    0x1a11, 0x1a15, 0x1b04, 0x1b08, 0x1b10, 0x1b11, 0x0104, 0x0111, 0x0117, 0x0118,
    0x011b, 0x0404, 0x0408, 0x0417, 0x0707, 0x5b11, 0x0711, 0x0713, 0x5e01, 0x0716,
    0x0717, 0x0719, 0x0802, 0x0901, 0x091b, 0x2918, 0x0a1b, 0x0b07, 0x0b1a, 0x0849,
    0x321b, 0x0815, 0x1004, 0x6c04, 0x1010, 0x1012, 0x3513, 0x1016, 0x1107, 0x110e,
    0x3c1a, 0x1110, 0x1111, 0x1207, 0x1116, 0x1117, 0x1310, 0x4315, 0x1401, 0x1407,
    0x1344, 0x1316, 0x1317, 0x1319, 0x131b, 0x4411, 0x8115, 0x4910, 0x491b, 0x1611,
    0x1674, 0x8511, 0x1616, 0x1a13, 0x1a19
};

static unsigned char HNJasoCompositionOutFinal[] =
{
    0x02, 0x03, 0x05, 0x06, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e,
    0x0f, 0x12, 0x14,
    // archaic
    0x1c, 0x1d, 0x1e, 0x1f, 0x20, 0x21, 0x22, 0x23, 0x24, 0x25,
    0x25, 0x26, 0x27, 0x28, 0x29, 0x2a, 0x2b, 0x2c, 0x2c, 0x2d,
    0x2e, 0x2f, 0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37,
    0x37, 0x38, 0x39, 0x3a, 0x3b, 0x3c, 0x3d, 0x3e, 0x3f, 0x40,
    0x41, 0x42, 0x43, 0x45, 0x46, 0x46, 0x47, 0x48, 0x4a, 0x4b,
    0x4c, 0x4d, 0x4e, 0x4f, 0x50, 0x51, 0x53, 0x54, 0x55, 0x56,
    0x57, 0x58, 0x59, 0x5a, 0x5b, 0x5c, 0x5d, 0x5e, 0x5f, 0x60,
    0x61, 0x62, 0x63, 0x63, 0x64, 0x65, 0x66, 0x67, 0x68, 0x69,
    0x6a, 0x6b, 0x6c, 0x6d, 0x6e, 0x6f, 0x6f, 0x70, 0x71, 0x72,
    0x72, 0x73, 0x74, 0x75, 0x76, 0x77, 0x78, 0x79, 0x7a, 0x7b,
    0x7c, 0x7d, 0x7e, 0x7f, 0x80, 0x81, 0x82, 0x83, 0x84, 0x85,
    0x86, 0x86, 0x87, 0x88, 0x89
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
            106
        },
        HNJasoCompositionInInitial,
        HNJasoCompositionOutInitial
    },
    {
        {
            13,
            99
        },
        HNJasoCompositionInMedial,
        HNJasoCompositionOutMedial
    },
    {
        {
            13,
            128
        },
        HNJasoCompositionInFinal,
        HNJasoCompositionOutFinal
    }
};


/*
 * Unicode Table
 */
#define HNUnicodeSymbolMax 0x30

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
};

static unichar HNUnicodeJamoInitial[] =
{
    0x0000, // 00
    0x3131, // 01 ㄱ
    0x3132, // 02 ㄲ
    0x3134, // 03 ㄴ
    0x3137, // 04 ㄷ
    0x3138, // 05 ㄸ
    0x3139, // 06 ㄹ
    0x3141, // 07 ㅁ
    0x3142, // 08 ㅂ
    0x3143, // 09 ㅃ
    0x3145, // 0a ㅅ
    0x3146, // 0b ㅆ
    0x3147, // 0c ㅇ
    0x3148, // 0d ㅈ
    0x3149, // 0e ㅉ
    0x314a, // 0f ㅊ
    0x314b, // 10 ㅋ
    0x314c, // 11 ㅌ
    0x314d, // 12 ㅍ
    0x314e, // 13 ㅎ
};

static unichar HNUnicodeJamoMedial[] =
{
    0x0000, // 00
    0x314f, // 01 ㅏ
    0x3150, // 02 ㅐ
    0x3151, // 03 ㅑ
    0x3152, // 04 ㅒ
    0x3153, // 05 ㅓ
    0x3154, // 06 ㅔ
    0x3155, // 07 ㅕ
    0x3156, // 08 ㅖ
    0x3157, // 09 ㅗ
    0x3158, // 0a ㅘ
    0x3159, // 0b ㅙ
    0x315a, // 0c ㅚ
    0x315b, // 0d ㅛ
    0x315c, // 0e ㅜ
    0x315d, // 0f ㅝ
    0x315e, // 10 ㅞ
    0x315f, // 11 ㅟ
    0x3160, // 12 ㅠ
    0x3161, // 13 ㅡ
    0x3162, // 14 ㅢ
    0x3163, // 15 ㅣ
};

static unichar HNUnicodeJamoFinal[] =
{
    0x0000, // 00
    0x3131, // 01 ㄱ
    0x3132, // 02 ㄲ
    0x3133, // 03 ㄳ
    0x3134, // 04 ㄴ
    0x3135, // 05 ㄵ
    0x3136, // 06 ㄶ
    0x3137, // 07 ㄷ
    0x3139, // 08 ㄹ
    0x313a, // 09 ㄺ
    0x313b, // 0a ㄻ
    0x313c, // 0b ㄼ
    0x313d, // 0c ㄽ
    0x313e, // 0d ㄾ
    0x313f, // 0e ㄿ
    0x3140, // 0f ㅀ
    0x3141, // 10 ㅁ
    0x3142, // 11 ㅂ
    0x3144, // 12 ㅄ
    0x3145, // 13 ㅅ
    0x3146, // 14 ㅆ
    0x3147, // 15 ㅇ
    0x3148, // 16 ㅈ
    0x314a, // 17 ㅊ
    0x314b, // 18 ㅋ
    0x314c, // 19 ㅌ
    0x314d, // 1a ㅍ
    0x314e, // 1b ㅎ
};

static unichar *HNUnicodeJamo[] =
{
    NULL,
    HNUnicodeJamoInitial,
    HNUnicodeJamoMedial,
    HNUnicodeJamoFinal
};

static unichar HNUnicodeJasoInitial[] =
{
    0x115f, // 00
    0x1100, // 01 ㄱ
    0x1101, // 02 ㄱㄱ
    0x1102, // 03 ㄴ
    0x1103, // 04 ㄷ
    0x1104, // 05 ㄷㄷ
    0x1105, // 06 ㄹ
    0x1106, // 07 ㅁ
    0x1107, // 08 ㅂ
    0x1108, // 09 ㅂㅂ
    0x1109, // 0a ㅅ
    0x110a, // 0b ㅅㅅ
    0x110b, // 0c ㅇ
    0x110c, // 0d ㅈ
    0x110d, // 0e ㅈㅈ
    0x110e, // 0f ㅊ
    0x110f, // 10 ㅋ
    0x1110, // 11 ㅌ
    0x1111, // 12 ㅍ
    0x1112, // 13 ㅎ
    0x1113, // 14 ㄴㄱ
    0x1114, // 15 ㄴㄴ
    0x1115, // 16 ㄴㄷ
    0x1116, // 17 ㄴㅂ
    0x1117, // 18 ㄷㄱ
    0x1118, // 19 ㄹㄴ
    0x1119, // 1a ㄹㄹ
    0x111a, // 1b ㄹㅎ
    0x111b, // 1c ㄹㅇ
    0x111c, // 1d ㅁㅂ
    0x111d, // 1e ㅁㅇ
    0x111e, // 1f ㅂㄱ
    0x111f, // 20 ㅂㄴ
    0x1120, // 21 ㅂㄷ
    0x1121, // 22 ㅂㅅ
    0x1122, // 23 ㅂㅅㄱ
    0x1123, // 24 ㅂㅅㄷ
    0x1124, // 25 ㅂㅅㅂ
    0x1125, // 26 ㅂㅅㅅ
    0x1126, // 27 ㅂㅅㅈ
    0x1127, // 28 ㅂㅈ
    0x1128, // 29 ㅂㅊ
    0x1129, // 2a ㅂㅌ
    0x112a, // 2b ㅂㅍ
    0x112b, // 2c ㅂㅇ
    0x112c, // 2d ㅂㅂㅇ
    0x112d, // 2e ㅅㄱ
    0x112e, // 2f ㅅㄴ
    0x112f, // 30 ㅅㄷ
    0x1130, // 31 ㅅㄹ
    0x1131, // 32 ㅅㅁ
    0x1132, // 33 ㅅㅂ
    0x1133, // 34 ㅅㅂㄱ
    0x1134, // 35 ㅅㅅㅅ
    0x1135, // 36 ㅅㅇ
    0x1136, // 37 ㅅㅈ
    0x1137, // 38 ㅅㅊ
    0x1138, // 39 ㅅㅋ
    0x1139, // 3a ㅅㅌ
    0x113a, // 3b ㅅㅍ
    0x113b, // 3c ㅅㅎ
    0x113c, // 3d ᄼᅠ
    0x113d, // 3e ᄽᅠ
    0x113e, // 3f ᄾᅠ
    0x113f, // 40 ᄿᅠ
    0x1140, // 41 ㅿ
    0x1141, // 42 ㅇㄱ
    0x1142, // 43 ㅇㄷ
    0x1143, // 44 ㅇㅁ
    0x1144, // 45 ㅇㅂ
    0x1145, // 46 ㅇㅅ
    0x1146, // 47 ㅇㅿ
    0x1147, // 48 ㅇㅇ
    0x1148, // 49 ㅇㅈ
    0x1149, // 4a ㅇㅊ
    0x114a, // 4b ㅇㅌ
    0x114b, // 4c ㅇㅍ
    0x114c, // 4d ㆁ
    0x114d, // 4e ㅈㅇ
    0x114e, // 4f ᅎᅠ
    0x114f, // 50 ᅏᅠ
    0x1150, // 51 ᅐᅠ
    0x1151, // 52 ᅑᅠ
    0x1152, // 53 ㅊㅋ
    0x1153, // 54 ㅊㅎ
    0x1154, // 55 ᅔᅠ
    0x1155, // 56 ᅕᅠ
    0x1156, // 57 ㅍㅂ
    0x1157, // 58 ㅍㅇ
    0x1158, // 59 ㅎㅎ
    0x1159, // 5a ㆆ
    0x115a, // 5b ㄱㄷ
    0x115b, // 5c ㄴㅅ
    0x115c, // 5d ㄴㅈ
    0x115d, // 5e ㄴㅎ
    0x115e, // 5f ㄷㄹ
    0xa960, // 60 ㄷㅁ
    0xa961, // 61 ㄷㅂ
    0xa962, // 62 ㄷㅅ
    0xa963, // 63 ㄷㅈ
    0xa964, // 64 ㄹㄱ
    0xa965, // 65 ㄹㄱㄱ
    0xa966, // 66 ㄹㄷ
    0xa967, // 67 ㄹㄷㄷ
    0xa968, // 68 ㄹㅁ
    0xa969, // 69 ㄹㅂ
    0xa96a, // 6a ㄹㅂㅂ
    0xa96b, // 6b ㄹㅂㅇ
    0xa96c, // 6c ㄹㅅ
    0xa96d, // 6d ㄹㅈ
    0xa96e, // 6e ㄹㅋ
    0xa96f, // 6f ㅁㄱ
    0xa970, // 70 ㅁㄷ
    0xa971, // 71 ㅁㅅ
    0xa972, // 72 ㅂㅅㅌ
    0xa973, // 73 ㅂㅋ
    0xa974, // 74 ㅂㅎ
    0xa975, // 75 ㅅㅅㅂ
    0xa976, // 76 ㅇㄹ
    0xa977, // 77 ㅇㅎ
    0xa978, // 78 ㅈㅈㅎ
    0xa979, // 79 ㅌㅌ
    0xa97a, // 7a ㅍㅎ
    0xa97b, // 7b ㅎㅅ
    0xa97c, // 7c ㆆㆆ
};

static unichar HNUnicodeJasoMedial[] =
{
    0x1160, // 00
    0x1161, // 01 ㅏ
    0x1162, // 02 ㅏㅣ (ㅐ)
    0x1163, // 03 ㅑ
    0x1164, // 04 ㅑㅣ (ㅒ)
    0x1165, // 05 ㅓ
    0x1166, // 06 ㅓㅣ (ㅔ)
    0x1167, // 07 ㅕ
    0x1168, // 08 ㅕㅣ (ㅖ)
    0x1169, // 09 ㅗ
    0x116a, // 0a ㅗㅏ (ㅘ)
    0x116b, // 0b ㅗㅏㅣ (ㅙ)
    0x116c, // 0c ㅗㅣ (ㅚ)
    0x116d, // 0d ㅛ
    0x116e, // 0e ㅜ
    0x116f, // 0f ㅜㅓ (ㅝ)
    0x1170, // 10 ㅜㅓㅣ (ㅞ)
    0x1171, // 11 ㅜㅣ (ㅟ)
    0x1172, // 12 ㅠ
    0x1173, // 13 ㅡ
    0x1174, // 14 ㅡㅣ (ㅢ)
    0x1175, // 15 ㅣ
    0x1176, // 16 ㅏㅗ
    0x1177, // 17 ㅏㅜ
    0x1178, // 18 ㅑㅗ
    0x1179, // 19 ㅑㅛ
    0x117a, // 1a ㅓㅗ
    0x117b, // 1b ㅓㅜ
    0x117c, // 1c ㅓㅡ
    0x117d, // 1d ㅕㅗ
    0x117e, // 1e ㅕㅜ
    0x117f, // 1f ㅗㅓ
    0x1180, // 20 ㅗㅓㅣ
    0x1181, // 21 ㅗㅕㅣ
    0x1182, // 22 ㅗㅗ
    0x1183, // 23 ㅗㅜ
    0x1184, // 24 ㅛㅑ
    0x1185, // 25 ㅛㅏㅣ
    0x1186, // 26 ㅛㅕ
    0x1187, // 27 ㅛㅗ
    0x1188, // 28 ㅛㅣ
    0x1189, // 29 ㅜㅏ
    0x118a, // 2a ㅜㅏㅣ
    0x118b, // 2b ㅜㅓㅡ
    0x118c, // 2c ㅜㅕㅣ
    0x118d, // 2d ㅜㅜ
    0x118e, // 2e ㅠㅏ
    0x118f, // 2f ㅠㅓ
    0x1190, // 30 ㅠㅓㅣ
    0x1191, // 31 ㅠㅕ
    0x1192, // 32 ㅠㅕㅣ
    0x1193, // 33 ㅠㅜ
    0x1194, // 34 ㅠㅣ
    0x1195, // 35 ㅡㅜ
    0x1196, // 36 ㅡㅡ
    0x1197, // 37 ㅡㅣㅜ
    0x1198, // 38 ㅣㅏ
    0x1199, // 39 ㅣㅑ
    0x119a, // 3a ㅣㅗ
    0x119b, // 3b ㅣㅜ
    0x119c, // 3c ㅣㅡ
    0x119d, // 3d ㅣㆍ
    0x119e, // 3e ㆍ
    0x119f, // 3f ㆍㅓ
    0x11a0, // 40 ㆍㅜ
    0x11a1, // 41 ㆍㅣ
    0x11a2, // 42 ㆍㆍ
    0x11a3, // 43 ㅏㅡ
    0x11a4, // 44 ㅑㅜ
    0x11a5, // 45 ㅕㅑ
    0x11a6, // 46 ㅗㅑ
    0x11a7, // 47 ㅗㅑㅣ
    0xd7b0, // 48 ㅗㅕ
    0xd7b1, // 49 ㅗㅗㅣ
    0xd7b2, // 4a ㅛㅏ
    0xd7b3, // 4b ㅛㅏㅣ
    0xd7b4, // 4c ㅛㅓ
    0xd7b5, // 4d ㅜㅕ
    0xd7b6, // 4e ㅜㅣㅣ
    0xd7b7, // 4f ㅠㅏㅣ
    0xd7b8, // 50 ㅠㅗ
    0xd7b9, // 51 ㅡㅏ
    0xd7ba, // 52 ㅡㅓ
    0xd7bb, // 53 ㅡㅓㅣ
    0xd7bc, // 54 ㅡㅗ
    0xd7bd, // 55 ㅣㅑㅗ
    0xd7be, // 56 ㅣㅑㅣ
    0xd7bf, // 57 ㅣㅕ
    0xd7c0, // 58 ㅣㅕㅣ
    0xd7c1, // 59 ㅣㅗㅣ
    0xd7c2, // 5a ㅣㅛ
    0xd7c3, // 5b ㅣㅠ
    0xd7c4, // 5c ㅣㅣ
    0xd7c5, // 5d ㆍㅏ
    0xd7c6, // 5e ㆍㅓㅣ
};

static unichar HNUnicodeJasoFinal[] =
{
    0x0000, // 00
    0x11a8, // 01 ㄱ
    0x11a9, // 02 ㄱㄱ
    0x11aa, // 03 ㄱㅅ
    0x11ab, // 04 ㄴ
    0x11ac, // 05 ㄴㅈ
    0x11ad, // 06 ㄴㅎ
    0x11ae, // 07 ㄷ
    0x11af, // 08 ㄹ
    0x11b0, // 09 ㄹㄱ
    0x11b1, // 0a ㄹㅁ
    0x11b2, // 0b ㄹㅂ
    0x11b3, // 0c ㄹㅅ
    0x11b4, // 0d ㄹㅌ
    0x11b5, // 0e ㄹㅍ
    0x11b6, // 0f ㄹㅎ
    0x11b7, // 10 ㅁ
    0x11b8, // 11 ㅂ
    0x11b9, // 12 ㅂㅅ
    0x11ba, // 13 ㅅ
    0x11bb, // 14 ㅅㅅ
    0x11bc, // 15 ㅇ
    0x11bd, // 16 ㅈ
    0x11be, // 17 ㅊ
    0x11bf, // 18 ㅋ
    0x11c0, // 19 ㅌ
    0x11c1, // 1a ㅍ
    0x11c2, // 1b ㅎ
    0x11c3, // 1c ㄱㄹ
    0x11c4, // 1d ㄱㅅㄱ
    0x11c5, // 1e ㄴㄱ
    0x11c6, // 1f ㄴㄷ
    0x11c7, // 20 ㄴㅅ
    0x11c8, // 21 ㄴㅿ
    0x11c9, // 22 ㅅㅌ
    0x11ca, // 23 ㄷㄱ
    0x11cb, // 24 ㄷㄹ
    0x11cc, // 25 ㄹㄱㅅ
    0x11cd, // 26 ㄹㄴ
    0x11ce, // 27 ㄹㄷ
    0x11cf, // 28 ㄹㄷㅎ
    0x11d0, // 29 ㄹㄹ
    0x11d1, // 2a ㄹㅁㄱ
    0x11d2, // 2b ㄹㅁㅅ
    0x11d3, // 2c ㄹㅂㅅ
    0x11d4, // 2d ㄹㅂㅎ
    0x11d5, // 2e ㄹㅂㅇ
    0x11d6, // 2f ㄹㅅㅅ
    0x11d7, // 30 ㄹㅿ
    0x11d8, // 31 ㄹㅋ
    0x11d9, // 32 ㄹㆆ
    0x11da, // 33 ㅁㄱ
    0x11db, // 34 ㅁㄹ
    0x11dc, // 35 ㅁㅂ
    0x11dd, // 36 ㅁㅅ
    0x11de, // 37 ㅁㅅㅅ
    0x11df, // 38 ㅁㅿ
    0x11e0, // 39 ㅁㅊ
    0x11e1, // 3a ㅁㅎ
    0x11e2, // 3b ㅁㅇ
    0x11e3, // 3c ㅂㄹ
    0x11e4, // 3d ㅂㅍ
    0x11e5, // 3e ㅂㅎ
    0x11e6, // 3f ㅂㅇ
    0x11e7, // 40 ㅅㄱ
    0x11e8, // 41 ㅅㄷ
    0x11e9, // 42 ㅅㄹ
    0x11ea, // 43 ㅅㅂ
    0x11eb, // 44 ㅿ
    0x11ec, // 45 ㆁㄱ
    0x11ed, // 46 ㆁㄱㄱ
    0x11ee, // 47 ㆁㆁ
    0x11ef, // 48 ㆁㅋ
    0x11f0, // 49 ㆁ
    0x11f1, // 4a ㆁㅅ
    0x11f2, // 4b ㆁㅿ
    0x11f3, // 4c ㅍㅂ
    0x11f4, // 4d ㅍㅇ
    0x11f5, // 4e ㅎㄴ
    0x11f6, // 4f ㅎㄹ
    0x11f7, // 50 ㅎㅁ
    0x11f8, // 51 ㅎㅂ
    0x11f9, // 52 ㆆ
    0x11fa, // 53 ㄱㄴ
    0x11fb, // 54 ㄱㅂ
    0x11fc, // 55 ㄱㅊ
    0x11fd, // 56 ㄱㅋ
    0x11fe, // 57 ㄱㅎ
    0x11ff, // 58 ㄴㄴ
    0xd7cb, // 59 ㄴㄹ
    0xd7cc, // 5a ㄴㅊ
    0xd7cd, // 5b ㄷㄷ
    0xd7ce, // 5c ㄷㄷㅂ
    0xd7cf, // 5d ㄷㅂ
    0xd7d0, // 5e ㄷㅅ
    0xd7d1, // 5f ㄷㅅㄱ
    0xd7d2, // 60 ㄷㅈ
    0xd7d3, // 61 ㄷㅊ
    0xd7d4, // 62 ㄷㅌ
    0xd7d5, // 63 ㄹㄱㄱ
    0xd7d6, // 64 ㄹㄱㅎ
    0xd7d7, // 65 ㄹㄹㅋ
    0xd7d8, // 66 ㄹㅁㅎ
    0xd7d9, // 67 ㄹㅂㄷ
    0xd7da, // 68 ㄹㅂㅍ
    0xd7db, // 69 ㄹㆁ
    0xd7dc, // 6a ㄹㆆㅎ
    0xd7dd, // 6b ㄹㅇ
    0xd7de, // 6c ㅁㄴ
    0xd7df, // 6d ㅁㄴㄴ
    0xd7e0, // 6e ㅁㅁ
    0xd7e1, // 6f ㅁㅂㅅ
    0xd7e2, // 70 ㅁㅈ
    0xd7e3, // 71 ㅂㄷ
    0xd7e4, // 72 ㅂㄹㅍ
    0xd7e5, // 73 ㅂㅁ
    0xd7e6, // 74 ㅂㅂ
    0xd7e7, // 75 ㅂㅅㄷ
    0xd7e8, // 76 ㅂㅈ
    0xd7e9, // 77 ㅂㅊ
    0xd7ea, // 78 ㅅㅁ
    0xd7eb, // 79 ㅅㅂㅇ
    0xd7ec, // 7a ㅅㅅㄱ
    0xd7ed, // 7b ㅅㅅㄷ
    0xd7ee, // 7c ㅅㅿ
    0xd7ef, // 7d ㅅㅈ
    0xd7f0, // 7e ㅅㅊ
    0xd7f1, // 7f ㅅㅌ
    0xd7f2, // 80 ㅅㅎ
    0xd7f3, // 81 ㅿㅂ
    0xd7f4, // 82 ㅿㅂㅇ
    0xd7f5, // 83 ㆁㅁ
    0xd7f6, // 84 ㆁㅎ
    0xd7f7, // 85 ㅈㅂ
    0xd7f8, // 86 ㅈㅂㅂ
    0xd7f9, // 87 ㅈㅈ
    0xd7fa, // 88 ㅍㅅ
    0xd7fb, // 89 ㅍㅌ
};

static unichar *HNUnicodeJaso[] =
{
    NULL,
    HNUnicodeJasoInitial,
    HNUnicodeJasoMedial,
    HNUnicodeJasoFinal
};


/*
 * Character Composition Buffer
 */
typedef union HNCharacter
{
    struct
    {
        unsigned char mType;
        unsigned char mInitial;
        unsigned char mMedial;
        unsigned char mFinal;
        unsigned char mDiacritic;
    } mByKey;

    struct
    {
        unsigned char mValue[5];
    } mByIndex;

#define CH_TYPE mByKey.mType
#define CH_CHO  mByKey.mInitial
#define CH_JUNG mByKey.mMedial
#define CH_JONG mByKey.mFinal
#define CH_BANG mByKey.mDiacritic
#define CH_VAL  mByIndex.mValue
#define CH_NIL  ((unsigned char)0xff)

} HNCharacter;


/*
 * Key Code Extraction Functions
 */
static BOOL HNCouldHandleKey(NSUInteger aModifiers)
{
    static NSUInteger sMask = NSDeviceIndependentModifierFlagsMask & ~(NSAlphaShiftKeyMask | NSShiftKeyMask);

    return (aModifiers & sMask) ? NO : YES;
}

static unsigned short HNKeyboardGetCode(HNInputContext *aContext, NSInteger aKeyCode, NSUInteger aModifiers)
{
    unsigned int   sShift;
    unsigned short sKeyConv;
    unsigned char  sType;
    unsigned char  sValue;

    if ((aModifiers & NSShiftKeyMask) || ((aModifiers & NSAlphaShiftKeyMask) && [aContext->mUserDefaults handlesCapsLockAsShift]))
    {
        sShift = 16;
    }
    else
    {
        sShift = 0;
    }

    if ((aKeyCode >= 0) && (aKeyCode < HNKeyCodeMax))
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
static unsigned char HNJasoCompose(HNInputContext *aContext, unsigned char aType, char aValue1, char aValue2)
{
    if ((aType >= HNKeyTypeInitial) && (aType <= HNKeyTypeFinal))
    {
        HNJasoComposition *sTable = &HNJasoCompositionTable[aType];
        unsigned short     sIn;
        int                sCount;
        int                i;

        sCount = sTable->mCount[aContext->mKeyboardLayout->mScope];
        sIn    = (aValue1 << 8) | aValue2;

        for (i = 0; i < sCount; i++)
        {
            if (sTable->mIn[i] == sIn)
            {
                return sTable->mOut[i];
            }
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
    aChar->CH_BANG = CH_NIL;
}

static void HNCharacterCopy(HNCharacter *aSrcChar, HNCharacter *aDstChar)
{
    *aDstChar = *aSrcChar;
}

static void HNCharacterSet(HNCharacter *aChar, unsigned char aType, unsigned char aValue)
{
    aChar->CH_TYPE       = aType;
    aChar->CH_VAL[aType] = aValue;
}

static NSUInteger HNCharacterCompose(HNInputContext *aContext, HNCharacter *aChar, unichar *aOutput)
{
    static const unsigned char sMaxNFC[]    = { 0x00, 0x13, 0x15, 0x1b };
    static const unsigned char sMaxNFD[]    = { 0x00, 0x7c, 0x5e, 0x89 };
    static const unichar       sDiacritic[] = { 0x0000, 0x302e, 0x302f };
    NSUInteger                 sLength    = 0;
    int                        i;

    if ((aContext->mKeyboardLayout->mScope == HNKeyboardLayoutScopeArchaic) || [aContext->mUserDefaults usesDecomposedUnicode])
    {
        /*
         * Unicode NFD (첫가끝코드)
         */

        for (i = HNKeyTypeInitial; i <= HNKeyTypeFinal; i++)
        {
            if (aChar->CH_VAL[i] <= sMaxNFD[i])
            {
                aOutput[i - 1] = HNUnicodeJaso[i][aChar->CH_VAL[i]];
                sLength = i;
            }
            else
            {
                aOutput[i - 1] = HNUnicodeJaso[i][0];
            }
        }

        /*
         * 초성만 있을 경우에는 중성채움이 들어가야함
         */
        if (sLength == 1)
        {
            /*
             * 터미널 사용시 초성입력후 Tab키를 이용한 자동완성을 위해 초성만 있을경우의 중성 채움을 넣지 않음 by gulbee
             */
//            sLength = 2;
        }

        if (aChar->CH_BANG != CH_NIL)
        {
            /*
             * 방점은 반드시 다음과 같은 형태로 나와야함: 초성(채움)+중성(채움)+종성(생략가능)+방점
             */
            if (sLength < 2)
            {
                sLength = 2;
            }

            aOutput[sLength] = sDiacritic[aChar->CH_BANG];
            sLength++;
        }
    }
    else
    {
        /*
         * Unicode NFC
         */

        HNCharacter   sChar;
        unsigned char sCount = 0;
        unsigned char sType  = 0;

        HNCharacterCopy(aChar, &sChar);

        for (i = HNKeyTypeInitial; i <= HNKeyTypeFinal; i++)
        {
            if (sChar.CH_VAL[i] <= sMaxNFC[i])
            {
                sCount++;
                sType = i;
            }
        }

        if (sCount == 3)
        {
            /*
             * 초성+중성+종성
             */
            *aOutput = 0xac00 + ((sChar.CH_CHO - 1) * 21 * 28) + ((sChar.CH_JUNG - 1) * 28) + sChar.CH_JONG;
            sLength  = 1;
        }
        else if ((sCount == 2) && (sType < HNKeyTypeFinal))
        {
            /*
             * 초성+중성
             */
            *aOutput = 0xac00 + ((sChar.CH_CHO - 1) * 21 * 28) + ((sChar.CH_JUNG - 1) * 28);
            sLength  = 1;
        }
        else if (sCount == 1)
        {
            /*
             * 자모
             */
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

    if (aChar == 0x27)
    {
        /*
         * single quotation mark
         */
        aContext->mSingleQuot ^= 1;

        return sSingleQuots[aContext->mSingleQuot];
    }
    else if (aChar == 0x22)
    {
        /*
         * double quotation mark
         */
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
static void HNCommitBuffer(HNInputContext *aContext, id<IMKTextInput> aClient, const unichar *aBuffer, NSUInteger aLength, unsigned int aProcessedKeyCount)
{
    NSString     *sString;
    unsigned int  i;

    aContext->mKeyCount -= aProcessedKeyCount;

    for (i = 0; i < aContext->mKeyCount; i++)
    {
        aContext->mKeyBuffer[i] = aContext->mKeyBuffer[i + aProcessedKeyCount];
    }

    sString = [[NSString alloc] initWithCharacters:aBuffer length:aLength];

    HNLog(@"HNInputContext(%p) HNCommitBuffer ## inputText:(%@)", aContext, sString);

    [aClient insertText:sString replacementRange:NSMakeRange(NSNotFound, NSNotFound)];

    [sString release];
}


/*
 * Hangul Composition Functions
 */
static void HNCompose(HNInputContext *aContext, id<IMKTextInput> aClient)
{
    HNCharacter   sChar;
    unichar       sCharBuffer[HNBufferSize];
    unichar      *sCharPtr = sCharBuffer;
    unichar      *sCharLmt = sCharPtr + (HNBufferSize - 5);
    NSUInteger    sCharCnt = 0;
    NSUInteger    sLength;
    unsigned int  i;

    HNCharacterClear(&sChar);

    for (i = 0; i < aContext->mKeyCount; i++)
    {
        unsigned short sCode  = aContext->mKeyBuffer[i];
        unsigned char  sType  = HNKeyType(sCode);
        unsigned char  sValue = HNKeyValue(sCode);

        if (aContext->mKeyboardLayout->mType == HNKeyboardLayoutTypeJamo)
        {
            /*
             * 두벌식
             *
             * - 자음과 모음으로 구성되어 있으며 자음은 초성이나 종성이 될 수 있음
             * - 자음은 초성으로, 모음은 중성으로 들어옴
             */

            if ((sType == HNKeyTypeInitial) && (sChar.CH_TYPE > sType))
            {
                /*
                 * 자음을 종성으로 사용할 수 있으면 종성코드로 변환
                 */

                unsigned char sFinal = HNJasoInitialToFinal[sValue];

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
                /*
                 * 초성이 비어있는 상태에서 중성이 들어오면 앞글자의 마지막 종성을 초성으로 가져옴
                 */

                unsigned char sInitial;
                unsigned char sFinal;

                sInitial = HNKeyValue(aContext->mKeyBuffer[i - 1]);

                if ((i > 1) && (HNKeyType(aContext->mKeyBuffer[i - 2]) == HNKeyTypeInitial))
                {
                    if ((i > 2) && (HNKeyType(aContext->mKeyBuffer[i - 3]) == HNKeyTypeInitial))
                    {
                        /*
                         * 앞글자의 남은 종성이 겹받침임 (옛한글일 경우 발생)
                         */
                        sFinal = HNJasoCompose(aContext,
                                               HNKeyTypeFinal,
                                               HNJasoInitialToFinal[HNKeyValue(aContext->mKeyBuffer[i - 3])],
                                               HNJasoInitialToFinal[HNKeyValue(aContext->mKeyBuffer[i - 2])]);
                    }
                    else
                    {
                        sFinal = HNJasoInitialToFinal[HNKeyValue(aContext->mKeyBuffer[i - 2])];
                    }
                }
                else
                {
                    sFinal = CH_NIL;
                }

                sChar.CH_JONG = sFinal;
                sLength       = HNCharacterCompose(aContext, &sChar, sCharPtr);

                if ([aContext->mUserDefaults commitsImmediately])
                {
                    HNCommitBuffer(aContext, aClient, sCharBuffer, sLength, i - 1);

                    i = 1;
                }
                else
                {
                    sCharCnt += sLength;
                    sCharPtr += sLength;

                    if (sCharPtr > sCharLmt)
                    {
                        fprintf(stderr, "HANULIM ERROR: Buffer overflow. composition stopped.\n");
                        break;
                    }
                }

                HNCharacterClear(&sChar);
                HNCharacterSet(&sChar, HNKeyTypeInitial, sInitial);
            }
        }

        if (sChar.CH_TYPE <= sType)
        {
            unsigned char sNewValue;

            if (sChar.CH_VAL[sType] != CH_NIL)
            {
                sNewValue = HNJasoCompose(aContext, sType, sChar.CH_VAL[sType], sValue);
            }
            else
            {
                sNewValue = sValue;
            }

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
            if ([aContext->mUserDefaults commitsImmediately])
            {
                HNCommitBuffer(aContext, aClient, sCharBuffer, sLength, i);

                i = 0;
            }
            else
            {
                sCharCnt += sLength;
                sCharPtr += sLength;

                if (sCharPtr > sCharLmt)
                {
                    fprintf(stderr, "HANULIM ERROR: Buffer overflow. composition stopped.\n");
                    break;
                }
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
    aContext->mUserDefaults   = nil;

    aContext->mComposedString = nil;

    aContext->mSingleQuot     = 1;
    aContext->mDoubleQuot     = 1;

    aContext->mKeyCount       = 0;
}

void HNICFinalize(HNInputContext *aContext)
{
    [aContext->mComposedString release];
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

void HNICSetUserDefaults(HNInputContext *aContext, id<HNICUserDefaults> aUserDefaults)
{
    aContext->mUserDefaults = aUserDefaults;
}

BOOL HNICHandleKey(HNInputContext *aContext, NSString *aString, NSInteger aKeyCode, NSUInteger aModifiers, id<IMKTextInput> aClient)
{
    BOOL           sCouldHandle;
    unsigned short sKeyConv;
    unichar        sSymbol;

    sCouldHandle = HNCouldHandleKey(aModifiers);
    
    if (sCouldHandle)
    {
        sKeyConv = HNKeyboardGetCode(aContext, aKeyCode, aModifiers);
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

            if ([aContext->mUserDefaults usesSmartQuotationMarks])
            {
                sSymbol = HNQuotationMark(aContext, sSymbol);
            }

            if ([aContext->mUserDefaults inputsBackSlashInsteadOfWon] && (sSymbol == 0xffe6))
            {
                sSymbol = 0x5c;
            }

            HNICCommitComposition(aContext, aClient);
            HNCommitBuffer(aContext, aClient, &sSymbol, 1, 0);
        }
        else if (aContext->mKeyCount < HNBufferSize)
        {
            aContext->mKeyBuffer[aContext->mKeyCount] = sKeyConv;
            aContext->mKeyCount++;

            HNCompose(aContext, aClient);
            HNICUpdateComposition(aContext, aClient);
        }
        else
        {
            fprintf(stderr, "HANULIM ERROR: Buffer overflow. Key ignored.\n");
        }
        
        return YES;
    }
    else if (sCouldHandle && aContext->mKeyCount)
    {
        if ([aString length] > 0)
        {
            unichar sCharacter = [aString characterAtIndex:0];
            
            switch (sCharacter)
            {
                case 0x08: /* delete */
                    aContext->mKeyCount--;

                    HNCompose(aContext, aClient);
                    HNICUpdateComposition(aContext, aClient);

                    return YES;
                case 0x09: /* tab key */
                    if ([[aClient bundleIdentifier] isEqualToString:@"com.apple.Terminal"]) {
                        HNLog(@"Terminal Tab");
                        HNICCommitComposition(aContext, aClient);
                        return NO;
                    }
                case 0x1c: /* arrow left */
                case 0x1d: /* arrow right */
                case 0x1e: /* arrow up */
                case 0x1f: /* arrow down */
                    if ([[aClient bundleIdentifier] isEqualToString:@"com.microsoft.Word"])
                    {
                        HNICCommitComposition(aContext, aClient);
                        return YES;
                    }
                    break;

                default:
                    HNLog(@"HNInputContext(%p) HNICHandleKey character:%#x", aContext, sCharacter);
                    break;
            }
        }
    }

    HNICCommitComposition(aContext, aClient);

    return NO;
}

void HNICCommitComposition(HNInputContext *aContext, id<IMKTextInput> aClient)
{
    if (aContext->mComposedString)
    {
        HNLog(@"HNInputContext(%p) HNICCommitComposition ## inputText:(%@)", aContext, aContext->mComposedString);

        [aClient insertText:aContext->mComposedString replacementRange:NSMakeRange(NSNotFound, NSNotFound)];

        [aContext->mComposedString release];

        aContext->mComposedString = nil;
        aContext->mKeyCount       = 0;
    }
}

void HNICUpdateComposition(HNInputContext *aContext, id<IMKTextInput> aClient)
{
    NSString *sString = aContext->mComposedString;

    if (sString)
    {
        HNLog(@"HNInputContext(%p) HNICUpdateComposition ## setMarkedText:(%@)", aContext, sString);

        [aClient setMarkedText:sString selectionRange:NSMakeRange([sString length], 0) replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
    }
}

void HNICCancelComposition(HNInputContext *aContext)
{
    [aContext->mComposedString release];

    aContext->mComposedString = nil;
    aContext->mKeyCount       = 0;
}

NSString *HNICComposedString(HNInputContext *aContext)
{
    return aContext->mComposedString;
}
