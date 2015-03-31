module BitTwiddle
  # 64 bit hamming weight
  M1  = 0x5555555555555555
  M2  = 0x3333333333333333
  M4  = 0x0f0f0f0f0f0f0f0f
  M8  = 0x00ff00ff00ff00ff
  M16 = 0x0000ffff0000ffff
  M32 = 0x00000000ffffffff
  def self.bits_set_in(i)
    i -= (i >> 1) & M1
    i = (i & M2) + ((i >> 2) & M2)
    i = (i + (i >> 4)) & M4
    i += i >> 8
    i += i >> 16
    i += i >> 32
    i & 0x7f
  end
end
