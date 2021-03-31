import std / [strutils, strformat, json, sequtils]

const mac_separators_remove = {":": "", "-": "", ".": ""}

type AlgorithmMode = enum
  ALGO_MAC,
  ALGO_EMPTY,
  ALGO_STATIC

type Algorithm = object
  id: string
  name: string
  mode: AlgorithmMode
  mac_substr: seq[string]
  generator: proc(mac: string): string


proc reverse(input: string): string =
  result = ""
  for index in countdown(input.high, 0):
    result.add(input[index])

proc pin_checksum(pincode: uint32): int =
  #[
  Standard WPS checksum algorithm.
  @pin — A 7 digit pin to calculate the checksum for.
  Returns the checksum value.
  ]#
  var pin = int(pincode)
  var accum = 0
  while pin != 0:
    accum += 3 * (pin mod 10)
    pin = int(pin / 10)
    accum += pin mod 10
    pin = int(pin / 10)
  return int((10 - accum mod 10) mod 10)

proc add_checksum(pin: uint32): int = int(pin) * 10 + pin_checksum(pin)

proc finalize_pin(pin: uint32): string = intToStr(add_checksum(pin), 8)

const algorithms = [
  Algorithm(
    id: "pin24",
    name: "24-bit PIN",
    mode: ALGO_MAC,
    mac_substr: @["04BF6D", "0E5D4E", "107BEF", "14A9E3", "28285D", "2A285D",
        "32B2DC", "381766", "404A03", "4E5D4E", "5067F0", "5CF4AB", "6A285D",
        "8E5D4E", "AA285D", "B0B2DC", "C86C87", "CC5D4E", "CE5D4E", "EA285D",
        "E243F6", "EC43F6", "EE43F6", "F2B2DC", "FCF528", "FEF528", "4C9EFF",
        "0014D1", "D8EB97", "1C7EE5", "84C9B2", "FC7516", "14D64D", "9094E4",
        "BCF685", "C4A81D", "00664B", "087A4C", "14B968", "2008ED", "346BD3",
        "4CEDDE", "786A89", "88E3AB", "D46E5C", "E8CD2D", "EC233D", "ECCB30",
        "F49FF3", "20CF30", "90E6BA", "E0CB4E", "D4BF7F4", "F8C091", "001CDF",
        "002275", "08863B", "00B00C", "081075", "C83A35", "0022F7", "001F1F",
        "00265B", "68B6CF", "788DF7", "BC1401", "202BC1", "308730", "5C4CA9",
        "62233D", "623CE4", "623DFF", "6253D4", "62559C", "626BD3", "627D5E",
        "6296BF", "62A8E4", "62B686", "62C06F", "62C61F", "62C714", "62CBA8",
        "62CDBE", "62E87B", "6416F0", "6A1D67", "6A233D", "6A3DFF", "6A53D4",
        "6A559C", "6A6BD3", "6A96BF", "6A7D5E", "6AA8E4", "6AC06F", "6AC61F",
        "6AC714", "6ACBA8", "6ACDBE", "6AD15E", "6AD167", "721D67", "72233D",
        "723CE4", "723DFF", "7253D4", "72559C", "726BD3", "727D5E", "7296BF",
        "72A8E4", "72C06F", "72C61F", "72C714", "72CBA8", "72CDBE", "72D15E",
        "72E87B", "0026CE", "9897D1", "E04136", "B246FC", "E24136", "00E020",
        "5CA39D", "D86CE9", "DC7144", "801F02", "E47CF9", "000CF6", "00A026",
        "A0F3C1", "647002", "B0487A", "F81A67", "F8D111", "34BA9A", "B4944E"],
    generator:
    proc(mac: string): string =
      let mac_str = mac.multiReplace(mac_separators_remove)
      finalize_pin(uint32(fromHex[uint32](mac_str[6..11]) mod 10_000_000))
  ),
  Algorithm(
    id: "pin28",
    name: "28-bit PIN",
    mode: ALGO_MAC,
    mac_substr: @["200BC7", "4846FB", "D46AA8", "F84ABF"],
    generator:
    proc(mac: string): string =
      let mac_str = mac.multiReplace(mac_separators_remove)
      finalize_pin(uint32(fromHex[uint32](mac_str[5..11]) mod 10_000_000))
  ),
  Algorithm(
    id: "pin32",
    name: "32-bit PIN",
    mode: ALGO_MAC,
    mac_substr: @["000726", "D8FEE3", "FC8B97", "1062EB", "1C5F2B", "48EE0C",
        "802689", "908D78", "E8CC18", "2CAB25", "10BF48", "14DAE9", "3085A9",
        "50465D", "5404A6", "C86000", "F46D04", "3085A9", "801F02"],
    generator:
    proc(mac: string): string =
      let mac_str = mac.multiReplace(mac_separators_remove)
      finalize_pin(uint32(fromHex[uint32](mac_str[4..11]) mod 10_000_000))
  ),
  Algorithm(
    id: "pin36",
    name: "36-bit PIN",
    mode: ALGO_MAC,
    mac_substr: @[],
    generator:
    proc(mac: string): string =
      let mac_str = mac.multiReplace(mac_separators_remove)
      finalize_pin(uint32(fromHex[uint64](mac_str[3..11]) mod 10_000_000))
  ),
  Algorithm(
    id: "pin40",
    name: "40-bit PIN",
    mode: ALGO_MAC,
    mac_substr: @[],
    generator:
    proc(mac: string): string =
      let mac_str = mac.multiReplace(mac_separators_remove)
      finalize_pin(uint32(fromHex[uint64](mac_str[2..11]) mod 10_000_000))
  ),
  Algorithm(
    id: "pin44",
    name: "44-bit PIN",
    mode: ALGO_MAC,
    mac_substr: @[],
    generator:
    proc(mac: string): string =
      let mac_str = mac.multiReplace(mac_separators_remove)
      finalize_pin(uint32(fromHex[uint64](mac_str[1..11]) mod 10_000_000))
  ),
  Algorithm(
    id: "pin48",
    name: "48-bit PIN",
    mode: ALGO_MAC,
    mac_substr: @[],
    generator:
    proc(mac: string): string =
      let mac_str = mac.multiReplace(mac_separators_remove)
      finalize_pin(uint32(fromHex[uint64](mac_str) mod 10_000_000))
  ),
  Algorithm(
    id: "pin24rh",
    name: "Reverse byte 24-bit",
    mode: ALGO_MAC,
    mac_substr: @["D8EB97", "0014D1", "3C8CF8"],
    generator:
    proc(mac: string): string =
      let t = mac.multiReplace(mac_separators_remove)[6..11]
      finalize_pin(uint32(fromHex[uint32](t[4..5] & t[2..3] & t[
          0..1]) mod 10_000_000))
  ),
  Algorithm(
    id: "pin32rh",
    name: "Reverse byte 32-bit",
    mode: ALGO_MAC,
    mac_substr: @[],
    generator:
    proc(mac: string): string =
      let t = mac.multiReplace(mac_separators_remove)[4..11]
      finalize_pin(uint32(fromHex[uint32](t[6..7] & t[4..5] & t[2..3] & t[
          0..1]) mod 10_000_000))
  ),
  Algorithm(
    id: "pin48rh",
    name: "Reverse byte 48-bit",
    mode: ALGO_MAC,
    mac_substr: @[],
    generator:
    proc(mac: string): string =
      let t = mac.multiReplace(mac_separators_remove)
      finalize_pin(uint32(fromHex[uint64](t[10..11] & t[8..9] & t[6..7] & t[
          4..5] & t[2..3] & t[0..1]) mod 10_000_000))
  ),
  Algorithm(
    id: "pin24rn",
    name: "Reverse nibble 24-bit",
    mode: ALGO_MAC,
    mac_substr: @[],
    generator:
    proc(mac: string): string =
      finalize_pin(fromHex[uint32](mac.multiReplace(mac_separators_remove)[
          6..11].reverse()) mod 10_000_000)
  ),
  Algorithm(
    id: "pin32rn",
    name: "Reverse nibble 32-bit",
    mode: ALGO_MAC,
    mac_substr: @[],
    generator:
    proc(mac: string): string =
      finalize_pin(fromHex[uint32](mac.multiReplace(mac_separators_remove)[
          4..11].reverse()) mod 10_000_000)
  ),
  Algorithm(
    id: "pin48rn",
    name: "Reverse nibble 48-bit",
    mode: ALGO_MAC,
    mac_substr: @[],
    generator:
    proc(mac: string): string =
      finalize_pin(uint32(fromHex[uint64](mac.multiReplace(
          mac_separators_remove).reverse()) mod 10_000_000))
  ),
  Algorithm(
    id: "pin24rb",
    name: "Reverse bits 24-bit",
    mode: ALGO_MAC,
    mac_substr: @[],
    generator:
    proc(mac: string): string =
      let t = fromHex[BiggestInt](mac.multiReplace(mac_separators_remove)[6..11])
      finalize_pin(uint32(fromBin[uint32](t.toBin(24).reverse()) mod 10_000_000))
  ),
  Algorithm(
    id: "pin32rb",
    name: "Reverse bits 32-bit",
    mode: ALGO_MAC,
    mac_substr: @[],
    generator:
    proc(mac: string): string =
      let t = fromHex[BiggestInt](mac.multiReplace(mac_separators_remove)[4..11])
      finalize_pin(uint32(fromBin[uint32](t.toBin(32).reverse()) mod 10_000_000))
  ),
  Algorithm(
    id: "pin48rb",
    name: "Reverse bits 48-bit",
    mode: ALGO_MAC,
    mac_substr: @[],
    generator:
    proc(mac: string): string =
      let t = fromHex[BiggestInt](mac.multiReplace(mac_separators_remove))
      finalize_pin(uint32(fromBin[uint64](t.toBin(48).reverse()) mod 10_000_000))
  ),
  Algorithm(
    id: "pinDLink",
    name: "D-Link PIN",
    mode: ALGO_MAC,
    mac_substr: @["14D64D", "1C7EE5", "28107B", "84C9B2", "A0AB1B", "B8A386",
        "C0A0BB", "CCB255", "FC7516", "0014D1", "D8EB97"],
    generator:
    proc(mac: string): string =
      let nic = fromHex[uint32](mac.multiReplace(mac_separators_remove)[6..11])
      var pin: uint32 = nic xor 0x55AA55
      pin = pin xor (((pin and 0xF) shl 4) +
                      ((pin and 0xF) shl 8) +
                      ((pin and 0xF) shl 12) +
                      ((pin and 0xF) shl 16) +
                      ((pin and 0xF) shl 20))
      pin = pin mod 10_000_000
      if pin < 1000000:
        pin += ((pin mod 9) * 1000000) + 1000000
      return finalize_pin(pin)
  ),
  Algorithm(
    id: "pinDLink1",
    name: "D-Link PIN +1",
    mode: ALGO_MAC,
    mac_substr: @["0018E7", "00195B", "001CF0", "001E58", "002191", "0022B0",
        "002401", "00265A", "14D64D", "1C7EE5", "340804", "5CD998", "84C9B2",
        "B8A386", "C8BE19", "C8D3A3", "CCB255", "0014D1"],
    generator:
    proc(mac: string): string =
      var nic = fromHex[uint32](mac.multiReplace(mac_separators_remove)[6..11])
      var pin: uint32 = (nic + 1) xor 0x55AA55
      pin = pin xor (((pin and 0xF) shl 4) +
                      ((pin and 0xF) shl 8) +
                      ((pin and 0xF) shl 12) +
                      ((pin and 0xF) shl 16) +
                      ((pin and 0xF) shl 20))
      pin = pin mod 10_000_000
      if pin < 1000000:
        pin += ((pin mod 9) * 1000000) + 1000000
      return finalize_pin(pin)
  ),
  Algorithm(
    id: "pinASUS",
    name: "ASUS PIN",
    mode: ALGO_MAC,
    mac_substr: @["049226", "04D9F5", "08606E", "0862669", "107B44", "10BF48",
        "10C37B", "14DDA9", "1C872C", "1CB72C", "2C56DC", "2CFDA1", "305A3A",
        "382C4A", "38D547", "40167E", "50465D", "54A050", "6045CB", "60A44C",
        "704D7B", "74D02B", "7824AF", "88D7F6", "9C5C8E", "AC220B", "AC9E17",
        "B06EBF", "BCEE7B", "C860007", "D017C2", "D850E6", "E03F49", "F0795978",
        "F832E4", "00072624", "0008A1D3", "00177C", "001EA6", "00304FB",
        "00E04C0", "048D38", "081077", "081078", "081079", "083E5D", "10FEED3C",
        "181E78", "1C4419", "2420C7", "247F20", "2CAB25", "3085A98C", "3C1E04",
        "40F201", "44E9DD", "48EE0C", "5464D9", "54B80A", "587BE906",
        "60D1AA21", "64517E", "64D954", "6C198F", "6C7220", "6CFDB9", "78D99FD",
        "7C2664", "803F5DF6", "84A423", "88A6C6", "8C10D4", "8C882B00",
        "904D4A", "907282", "90F65290", "94FBB2", "A01B29", "A0F3C1E",
        "A8F7E00", "ACA213", "B85510", "B8EE0E", "BC3400", "BC9680", "C891F9",
        "D00ED90", "D084B0", "D8FEE3", "E4BEED", "E894F6F6", "EC1A5971",
        "EC4C4D", "F42853", "F43E61", "F46BEF", "F8AB05", "FC8B97", "7062B8",
        "78542E", "C0A0BB8C", "C412F5", "C4A81D", "E8CC18", "EC2280",
        "F8E903F4"],
    generator:
    proc(mac: string): string =
      var b: array[6, uint16]
      var i: int = 0
      for e in mac.split(':'):
        b[i] = fromHex[uint16](e)
        i.inc()
      var pin_code: string = ""
      for i in 0'u16..<7'u16:
        pin_code.addInt int((b[i mod 6] + b[5]) mod (10'u16 - (i + b[1] + b[2] +
            b[3] + b[4] + b[5]) mod 7'u16))
      return finalize_pin(uint32(parseInt(pin_code)))
  ),
  Algorithm(
    id: "pinAirocon",
    name: "Airocon Realtek",
    mode: ALGO_MAC,
    mac_substr: @["0007262F", "000B2B4A", "000EF4E7", "001333B", "00177C",
        "001AEF", "00E04BB3", "02101801", "0810734", "08107710", "1013EE0",
        "2CAB25C7", "788C54", "803F5DF6", "94FBB2", "BC9680", "F43E61",
        "FC8B97"],
    generator:
    proc(mac: string): string =
      var b: array[6, uint32]
      var i: int = 0
      for e in mac.split(':'):
        b[i] = fromHex[uint32](e)
        i.inc()
      let pin = ((b[0] + b[1]) mod 10'u32) +
                (((b[5] + b[0]) mod 10) * 10'u32) +
                (((b[4] + b[5]) mod 10) * 100'u32) +
                (((b[3] + b[4]) mod 10) * 1000'u32) +
                (((b[2] + b[3]) mod 10) * 10000'u32) +
                (((b[1] + b[2]) mod 10) * 100000'u32) +
                (((b[0] + b[1]) mod 10) * 1000000'u32)
      return finalize_pin(pin)
  ),
  Algorithm(
    id: "pinInvNIC",
    name: "Inv NIC to PIN",
    mode: ALGO_MAC,
    mac_substr: @[],
    generator:
    proc(mac: string): string =
      let nic = fromHex[uint32](mac.multiReplace(mac_separators_remove)[6..11])
      return finalize_pin(uint32((not nic and 0xFFFFFF) mod 10_000_000))
  ),
  Algorithm(
    id: "pinNIC2",
    name: "NIC * 2",
    mode: ALGO_MAC,
    mac_substr: @[],
    generator:
    proc(mac: string): string =
      let nic = fromHex[uint32](mac.multiReplace(mac_separators_remove)[6..11])
      return finalize_pin(uint32((nic * 2) mod 10_000_000))
  ),
  Algorithm(
    id: "pinNIC3",
    name: "NIC * 3",
    mode: ALGO_MAC,
    mac_substr: @[],
    generator:
    proc(mac: string): string =
      let nic = fromHex[uint32](mac.multiReplace(mac_separators_remove)[6..11])
      return finalize_pin(uint32((nic * 3) mod 10_000_000))
  ),
  Algorithm(
    id: "pinOUIaddNIC",
    name: "OUI + NIC",
    mode: ALGO_MAC,
    mac_substr: @[],
    generator:
    proc(mac: string): string =
      let oui = fromHex[uint32](mac.multiReplace(mac_separators_remove)[0..5])
      let nic = fromHex[uint32](mac.multiReplace(mac_separators_remove)[6..11])
      return finalize_pin(((oui + nic) mod 0x1000000) mod 10_000_000)
  ),
  Algorithm(
    id: "pinOUIsubNIC",
    name: "OUI - NIC",
    mode: ALGO_MAC,
    mac_substr: @[],
    generator:
    proc(mac: string): string =
      let oui = fromHex[uint32](mac.multiReplace(mac_separators_remove)[0..5])
      let nic = fromHex[uint32](mac.multiReplace(mac_separators_remove)[6..11])
      var pin: uint32
      if nic < oui:
        pin = oui - nic
      else:
        pin = (oui + 0x1000000 - nic) and 0xFFFFFF
      return finalize_pin(pin mod 10_000_000)
  ),
  Algorithm(
    id: "pinOUIxorNIC",
    name: "OUI ^ NIC",
    mode: ALGO_MAC,
    mac_substr: @[],
    generator:
    proc(mac: string): string =
      let oui = fromHex[uint32](mac.multiReplace(mac_separators_remove)[0..5])
      let nic = fromHex[uint32](mac.multiReplace(mac_separators_remove)[6..11])
      return finalize_pin((oui xor nic) mod 10_000_000)
  ),
  Algorithm(
    id: "pinEmpty",
    name: "Empty PIN",
    mode: ALGO_EMPTY,
    mac_substr: @["E46F13", "EC2280", "58D56E", "1062EB", "10BEF5", "1C5F2B",
        "802689", "A0AB1B", "74DADA", "9CD643", "68A0F6", "0C96BF", "20F3A3",
        "ACE215", "C8D15E", "000E8F", "D42122", "3C9872", "788102", "7894B4",
        "D460E3", "E06066", "004A77", "2C957F", "64136C", "74A78E", "88D274",
        "702E22", "74B57E", "789682", "7C3953", "8C68C8", "D476EA", "344DEA",
        "38D82F", "54BE53", "709F2D", "94A7B7", "981333", "CAA366", "D0608C"],
    generator: proc(mac: string): string = ""
  ),
  Algorithm(
    id: "pinCisco",
    name: "Cisco",
    mode: ALGO_STATIC,
    mac_substr: @["001A2B", "00248C", "002618", "344DEB", "7071BC", "E06995",
        "E0CB4E", "7054F5"],
    generator: proc (mac: string): string = "12345670"
  ),
  Algorithm(
    id: "pinBrcm1",
    name: "Broadcom 1",
    mode: ALGO_STATIC,
    mac_substr: @["ACF1DF", "BCF685", "C8D3A3", "988B5D", "001AA9", "14144B",
        "EC6264"],
    generator: proc (mac: string): string = "20172527"
  ),
  Algorithm(
    id: "pinBrcm2",
    name: "Broadcom 2",
    mode: ALGO_STATIC,
    mac_substr: @["14D64D", "1C7EE5", "28107B", "84C9B2", "B8A386", "BCF685",
        "C8BE19"],
    generator: proc (mac: string): string = "46264848"
  ),
  Algorithm(
    id: "pinBrcm3",
    name: "Broadcom 3",
    mode: ALGO_STATIC,
    mac_substr: @["14D64D", "1C7EE5", "28107B", "B8A386", "BCF685", "C8BE19",
        "7C034C"],
    generator: proc (mac: string): string = "76229909"
  ),
  Algorithm(
    id: "pinBrcm4",
    name: "Broadcom 4",
    mode: ALGO_STATIC,
    mac_substr: @["14D64D", "1C7EE5", "28107B", "84C9B2", "B8A386", "BCF685",
        "C8BE19", "C8D3A3", "CCB255", "FC7516", "204E7F", "4C17EB", "18622C",
        "7C03D8", "D86CE9"],
    generator: proc (mac: string): string = "62327145"
  ),
  Algorithm(
    id: "pinBrcm5",
    name: "Broadcom 5",
    mode: ALGO_STATIC,
    mac_substr: @["14D64D", "1C7EE5", "28107B", "84C9B2", "B8A386", "BCF685",
        "C8BE19", "C8D3A3", "CCB255", "FC7516", "204E7F", "4C17EB", "18622C",
        "7C03D8", "D86CE9"],
    generator: proc (mac: string): string = "10864111"
  ),
  Algorithm(
    id: "pinBrcm6",
    name: "Broadcom 6",
    mode: ALGO_STATIC,
    mac_substr: @["14D64D", "1C7EE5", "28107B", "84C9B2", "B8A386", "BCF685",
        "C8BE19", "C8D3A3", "CCB255", "FC7516", "204E7F", "4C17EB", "18622C",
        "7C03D8", "D86CE9"],
    generator: proc (mac: string): string = "31957199"
  ),
  Algorithm(
    id: "pinAirc1",
    name: "Airocon 1",
    mode: ALGO_STATIC,
    mac_substr: @["181E78", "40F201", "44E9DD", "D084B0"],
    generator: proc (mac: string): string = "30432031"
  ),
  Algorithm(
    id: "pinAirc2",
    name: "Airocon 2",
    mode: ALGO_STATIC,
    mac_substr: @["84A423", "8C10D4", "88A6C6"],
    generator: proc (mac: string): string = "71412252"
  ),
  Algorithm(
    id: "pinDSL2740R",
    name: "DSL-2740R",
    mode: ALGO_STATIC,
    mac_substr: @["00265A", "1CBDB9", "340804", "5CD998", "84C9B2", "FC7516"],
    generator: proc (mac: string): string = "68175542"
  ),
  Algorithm(
    id: "pinRealtek1",
    name: "Realtek 1",
    mode: ALGO_STATIC,
    mac_substr: @["0014D1", "000C42", "000EE8"],
    generator: proc (mac: string): string = "95661469"
  ),
  Algorithm(
    id: "pinRealtek2",
    name: "Realtek 2",
    mode: ALGO_STATIC,
    mac_substr: @["007263", "E4BEED"],
    generator: proc (mac: string): string = "95719115"
  ),
  Algorithm(
    id: "pinRealtek3",
    name: "Realtek 3",
    mode: ALGO_STATIC,
    mac_substr: @["08C6B3"],
    generator: proc (mac: string): string = "48563710"
  ),
  Algorithm(
    id: "pinUpvel",
    name: "Upvel",
    mode: ALGO_STATIC,
    mac_substr: @["784476", "D4BF7F0", "F8C091"],
    generator: proc (mac: string): string = "20854836"
  ),
  Algorithm(
    id: "pinUR814AC",
    name: "UR-814AC",
    mode: ALGO_STATIC,
    mac_substr: @["D4BF7F60"],
    generator: proc (mac: string): string = "43977680"
  ),
  Algorithm(
    id: "pinUR825AC",
    name: "UR-825AC",
    mode: ALGO_STATIC,
    mac_substr: @["D4BF7F5"],
    generator: proc (mac: string): string = "05294176"
  ),
  Algorithm(
    id: "pinOnlime",
    name: "Onlime",
    mode: ALGO_STATIC,
    mac_substr: @["D4BF7F", "F8C091", "144D67", "784476", "0014D1"],
    generator: proc (mac: string): string = "99956042"
  ),
  Algorithm(
    id: "pinEdimax",
    name: "Edimax",
    mode: ALGO_STATIC,
    mac_substr: @["801F02", "00E04C"],
    generator: proc (mac: string): string = "35611530"
  ),
  Algorithm(
    id: "pinThomson",
    name: "Thomson",
    mode: ALGO_STATIC,
    mac_substr: @["002624", "4432C8", "88F7C7", "CC03FA"],
    generator: proc (mac: string): string = "67958146"
  ),
  Algorithm(
    id: "pinHG532x",
    name: "HG532x",
    mode: ALGO_STATIC,
    mac_substr: @["00664B", "086361", "087A4C", "0C96BF", "14B968", "2008ED",
        "2469A5", "346BD3", "786A89", "88E3AB", "9CC172", "ACE215", "D07AB5",
        "CCA223", "E8CD2D", "F80113", "F83DFF"],
    generator: proc (mac: string): string = "34259283"
  ),
  Algorithm(
    id: "pinH108L",
    name: "H108L",
    mode: ALGO_STATIC,
    mac_substr: @["4C09B4", "4CAC0A", "84742A4", "9CD24B", "B075D5", "C864C7",
        "DC028E", "FCC897"],
    generator: proc (mac: string): string = "94229882"
  ),
  Algorithm(
    id: "pinONO",
    name: "CBN ONO",
    mode: ALGO_STATIC,
    mac_substr: @["5C353B", "DC537C"],
    generator: proc (mac: string): string = "95755212"
  )
]

type PinCode = object
  algo_id: string
  name: string
  mode: AlgorithmMode
  pin: string

proc generateSuggested(mac: string): seq[PinCode] =
  let blank_mac = mac.multiReplace(mac_separators_remove)
  var pins: seq[PinCode] = @[]
  for algo in algorithms:
    for mask in algo.mac_substr:
      if blank_mac.startswith(mask):
        pins.add(
          PinCode(
            algo_id: algo.id,
            name: algo.name,
            mode: algo.mode,
            pin: algo.generator(mac)
          )
        )
        break
  return pins

proc generateAll(mac: string, testing: bool = false): seq[PinCode] =
  var pins = generateSuggested(mac)
  var algos: seq[string] = @[]
  for pin in pins:
    algos.add(pin.algo_id)
  for algo in algorithms:
    if not testing and (algo.mac_substr == @[]):
      continue
    if algo.id notin algos:
      pins.add(
        PinCode(
          algo_id: algo.id,
          name: algo.name,
          mode: algo.mode,
          pin: algo.generator(mac)
        )
      )
  return pins

proc prepareMac(mac: string): string =
  ## Checks if MAC address is valid and prepares it. Takes a MAC address without separators.
  ## Returns prepared MAC address with a ":" separator if it's valid, otherwise an empty string.
  var prepared_mac = mac.multiReplace(mac_separators_remove)
  if prepared_mac.len != 12:
    return ""
  if not all(prepared_mac, proc(c: char): bool = c in
      HexDigits): # Checks if each char of prepared_mac is hexdigit
    return ""
  prepared_mac = prepared_mac.toUpperAscii()
  for i in countdown(10, 2, 2):
    prepared_mac.insert(":", i)
  return prepared_mac


when is_main_module:
  import argparse

  const p = newParser("wpspin"):
    help("WPS PIN generator which uses known MAC address based algorithms commonly found in Wi-Fi routers firmware to generate their default PINs.")
    flag("-A", "--gen-all", help = "generate all PIN codes in addition to the suggested ones")
    flag("-J", "--json", help = "return results in JSON representation")
    flag("-T", "--gen-testing", help = "generate pin codes obtained by algorithms for testing (no use cases on real devices)")
    arg("mac", help = "target MAC address to generate PIN code. Example: 11:22:33:44:55:66 or 11-22-33-44-55-66")

  try:
    let args = p.parse(commandLineParams())
    let mac = prepareMac(args.mac)
    if mac == "":
      echo &"Error: \"{args.mac}\" isn't a valid MAC address"
      quit(1)
    let pins = if args.gen_all: generateAll(mac,
        args.gen_testing) else: generateSuggested(mac)
    if args.json:
      echo $(%*pins)
    else:
      if pins.len != 0:
        if not args.gen_all:
          echo &"Found {pins.len} PIN(s)"
        echo &"""{"PIN":<8}   {"Name"}"""

        for pin in pins:
          let pin_name = if pin.mode == ALGO_STATIC: "Static PIN -- " &
              pin.name else: pin.name
          let pin_value = if pin.mode == ALGO_EMPTY: "<empty>" else: pin.pin
          echo &"{pin_value:<8} | {pin_name}"
      else:
        echo "No PINs found -- try to get all PINs (-A)"
  except ShortCircuit as e:
    if e.flag == "argparse_help":
      quit(p.help)
  except UsageError:
    echo "Error: invalid arguments. Use -h to get help"
    quit(QuitFailure)
