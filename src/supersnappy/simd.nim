type
  m128i* {.importc: "__m128i", header: "emmintrin.h".} = object

func mm_loadu_si128*(dst: pointer): m128i
  {.importc: "_mm_loadu_si128", header: "emmintrin.h".}

func mm_storeu_si128*(dst: pointer, v: m128i)
  {.importc: "_mm_storeu_si128", header: "emmintrin.h".}
