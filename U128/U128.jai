U128 :: struct {
    high : u64;
    low : u64;
}

u128 :: (value: $T) -> U128
#modify {
    if T.type != .INTEGER  T = null;
} {
    result : U128 = ---;
    result.high = 0;
    result.low = cast(u64)value;
    return result;
}

u128 :: (high: $T, low: T) -> U128
#modify {
    if T.type != .INTEGER  T = null;
} {
    result : U128 = ---;
    result.high = cast(u64)high;
    result.low = cast(u64)low;
    return result;
}


format :: (value: U128, $base := 16, $fill := false, $separator := "") -> string {
    #import "Basic";

    #if fill {
        return sprint("%1%3%2", formatInt(value.high, base = base, minimum_digits = 256 / base),
                                formatInt(value.low, base = base, minimum_digits = 256 / base),
                                separator);
    }
    else {
        if value.high  return sprint("%1%3%2", formatInt(value.high, base = base),
                                formatInt(value.low, base = base, minimum_digits = 256 / base),
                                separator);
        else  return sprint("%", formatInt(value.low, base = base));
    }
}


operator<< :: (a: U128, b: $T) -> U128
#modify {
    if T.type != .INTEGER  T = null;
} {
    result := a;
    if b <= 0   return result;
    if b > 127  return .{0, 0};

    for 1 .. b {
        result.high <<= 1;
        if result.low & (1 << 63)
            result.high |= 1;
        result.low <<= 1;
    }
    return result;
}

operator>> :: (a: U128, b: $T) -> U128
#modify {
    if T.type != .INTEGER  T = null;
} {
    result := a;
    if b <= 0   return result;
    if b > 127  return .{0, 0};

    for 1 .. b {
        result.low >>= 1;
        if result.high & 1
            result.low |= 1;
        result.high >>= 1;
    }
    return result;
}


operator<<< :: (a: U128, b: $T) -> U128
#modify {
    if T.type != .INTEGER  T = null;
} {
    result := a;
    b %= 128;
    if b <= 0  return result;

    for 1 .. b {
        set_lowest : u64 = (result.high & (1 << 63)) <<< 1;
        result.high <<= 1;
        if result.low & (1 << 63)
            result.high |= 1;
        result.low <<= 1;
        result.low |= set_lowest;
    }
    return result;
}

operator>>> :: (a: U128, b: $T) -> U128
#modify {
    if T.type != .INTEGER  T = null;
} {
    result := a;
    b %= 128;
    if b <= 0  return result;

    for 1 .. b {
        set_highest : u64 = (result.low & 1) >>> 1;
        result.low >>= 1;
        if result.high & 1
            result.low |= (1 << 63);
        result.high >>= 1;
        result.high |= set_highest;
    }
    return result;
}


operator| :: (a: U128, b: U128) -> U128 {
    result := a;
    result.high |= b.high;
    result.low  |= b.low;
    return result;
}

operator| :: (a: U128, b: $T) -> U128 #symmetric
#modify {
    if T.type != .INTEGER {
        T = null;
        return;
    }
    t := cast(*Type_Info_Integer)T;
    if t.signed  T = null;
} {
    result := a;
    result.low |= b;
    return result;
}


operator& :: (a: U128, b: U128) -> U128 {
    result := a;
    result.high &= b.high;
    result.low  &= b.low;
    return result;
}

operator& :: (a: U128, b: $T) -> U128 #symmetric
#modify {
    if T.type != .INTEGER {
        T = null;
        return;
    }
    t := cast(*Type_Info_Integer)T;
    if t.signed  T = null;
} {
    result := a;
    result.high = 0;
    result.low &= b;
    return result;
}


operator~ :: (a: U128) -> U128 {
    result : U128 = ---;
    result.high = ~a.high;
    result.low  = ~a.low;
    return result;
}



operator== :: (a: U128, b: U128) -> bool {
    return a.low == b.low && a.high == b.high;
}

operator!= :: (a: U128, b: U128) -> bool {
    return a.low != b.low || a.high != b.high;
}

operator< :: (a: U128, b: U128) -> bool {
    return a.high < b.high
        || a.high == b.high && a.low < b.low;
}

operator<= :: (a: U128, b: U128) -> bool {
    return a.high < b.high
        || a.high == b.high && a.low < b.low
        || a.high == b.high && a.low == b.low;
}

operator> :: (a: U128, b: U128) -> bool {
    return a.high > b.high
        || a.high == b.high && a.low > b.low;
}

operator>= :: (a: U128, b: U128) -> bool {
    return a.high > b.high
        || a.high == b.high && a.low > b.low
        || a.high == b.high && a.low == b.low;
}
